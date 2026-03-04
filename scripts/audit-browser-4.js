const { chromium } = require('playwright');
const { ethers } = require('ethers');

(async () => {
  const pk = process.env.AUDIT_WALLET_PK;
  const rpcProvider = new ethers.JsonRpcProvider('https://mainnet.base.org');
  const wallet = new ethers.Wallet(pk, rpcProvider);
  console.log('Wallet:', wallet.address);

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  page.on('console', msg => {
    const t = msg.text();
    if (t.includes('[MW]') || t.includes('error') || t.includes('Error') || t.includes('SIGN') || t.includes('TX'))
      console.log('[Console]', t.substring(0, 300));
  });

  // Inject mock wallet that responds to EIP-6963
  await page.addInitScript(`
    const addr = '${wallet.address}';
    
    const mockProvider = {
      isMetaMask: true,
      isConnected: () => true,
      selectedAddress: addr,
      chainId: '0x2105',
      networkVersion: '8453',
      _events: {},
      on(e, cb) { this._events[e] = this._events[e] || []; this._events[e].push(cb); return this; },
      removeListener() { return this; },
      removeAllListeners() { return this; },
      emit(e, ...a) { (this._events[e]||[]).forEach(cb => cb(...a)); },
      async request({ method, params }) {
        console.log('[MW]', method);
        switch(method) {
          case 'eth_requestAccounts':
          case 'eth_accounts': return [addr];
          case 'eth_chainId': return '0x2105';
          case 'net_version': return '8453';
          case 'wallet_switchEthereumChain': return null;
          case 'wallet_addEthereumChain': return null;
          case 'personal_sign': {
            console.log('[MW] SIGN:', params[0].substring(0, 100));
            window.__SIGN_MSG = params[0];
            window.__SIGN_READY = true;
            return new Promise(r => { window.__RESOLVE_SIGN = r; });
          }
          case 'eth_signTypedData_v4': {
            console.log('[MW] TYPED_SIGN:', JSON.stringify(params).substring(0, 200));
            window.__SIGN_MSG = params[1];
            window.__SIGN_TYPE = 'typed_v4';
            window.__SIGN_READY = true;
            return new Promise(r => { window.__RESOLVE_SIGN = r; });
          }
          case 'eth_sendTransaction': {
            console.log('[MW] TX:', JSON.stringify(params[0]).substring(0, 300));
            window.__TX_DATA = JSON.stringify(params[0]);
            window.__TX_READY = true;
            return new Promise(r => { window.__RESOLVE_TX = r; });
          }
          default: {
            const r = await fetch('https://mainnet.base.org', {
              method: 'POST',
              headers: {'Content-Type':'application/json'},
              body: JSON.stringify({jsonrpc:'2.0',id:1,method,params})
            });
            const d = await r.json();
            if (d.error) throw new Error(d.error.message);
            return d.result;
          }
        }
      }
    };
    
    window.ethereum = mockProvider;
    
    // EIP-6963 announceProvider
    const info = { uuid: 'a1b2c3d4', name: 'MetaMask', icon: 'data:image/svg+xml,<svg></svg>', rdns: 'io.metamask' };
    
    // Announce immediately
    window.dispatchEvent(new CustomEvent('eip6963:announceProvider', {
      detail: Object.freeze({ info, provider: mockProvider })
    }));
    
    // Also respond to requests
    window.addEventListener('eip6963:requestProvider', () => {
      window.dispatchEvent(new CustomEvent('eip6963:announceProvider', {
        detail: Object.freeze({ info, provider: mockProvider })
      }));
    });
  `);

  console.log('\nNavigating...');
  await page.goto('https://app.qinv.ai', { waitUntil: 'networkidle', timeout: 30000 });
  await page.waitForTimeout(2000);

  // Click The Big Three
  const card = await page.$('text=The Big Three');
  if (card) { await card.click(); await page.waitForTimeout(2000); }

  // Click Sign In
  const signIn = await page.$('button:has-text("Sign In")');
  if (signIn) {
    await signIn.click();
    await page.waitForTimeout(1500);
    
    // Click MetaMask in modal
    console.log('Looking for MetaMask option...');
    const mm = await page.$('text=MetaMask');
    if (mm) {
      console.log('Clicking MetaMask...');
      await mm.click();
      await page.waitForTimeout(5000);
      
      // Check if sign request appeared
      const signReady = await page.evaluate(() => window.__SIGN_READY);
      console.log('Sign ready:', signReady);
      
      if (signReady) {
        const msg = await page.evaluate(() => window.__SIGN_MSG);
        const signType = await page.evaluate(() => window.__SIGN_TYPE);
        console.log('Sign type:', signType || 'personal_sign');
        console.log('Message:', typeof msg === 'string' ? msg.substring(0, 500) : JSON.stringify(msg).substring(0, 500));
        
        let signature;
        if (signType === 'typed_v4') {
          // EIP-712 typed data signing
          const typedData = JSON.parse(msg);
          const { domain, types, message: msgData } = typedData;
          delete types.EIP712Domain;
          signature = await wallet.signTypedData(domain, types, msgData);
        } else {
          // personal_sign
          let msgText = msg;
          if (msg.startsWith('0x')) {
            msgText = Buffer.from(msg.slice(2), 'hex').toString('utf8');
          }
          console.log('Decoded msg:', msgText.substring(0, 300));
          signature = await wallet.signMessage(msgText);
        }
        
        console.log('Signature:', signature.substring(0, 20) + '...');
        await page.evaluate((sig) => { window.__RESOLVE_SIGN(sig); }, signature);
        console.log('Signature sent to app, waiting...');
        
        await page.waitForTimeout(5000);
        await page.screenshot({ path: '/tmp/qinv-signed.png', fullPage: true });
        
        const bodyText = await page.$eval('body', el => el.innerText);
        console.log('\nPage after sign:\n', bodyText.substring(0, 2000));
      } else {
        console.log('No sign request - checking page state...');
        await page.screenshot({ path: '/tmp/qinv-after-mm.png', fullPage: true });
        const bodyText = await page.$eval('body', el => el.innerText);
        console.log('\nPage:\n', bodyText.substring(0, 1000));
      }
    } else {
      console.log('MetaMask option not found');
      await page.screenshot({ path: '/tmp/qinv-modal.png', fullPage: true });
    }
  }

  await browser.close();
})();
