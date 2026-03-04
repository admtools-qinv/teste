const { chromium } = require('playwright');
const { ethers } = require('ethers');

(async () => {
  const pk = process.env.AUDIT_WALLET_PK;
  const rpcProvider = new ethers.JsonRpcProvider('https://mainnet.base.org');
  const wallet = new ethers.Wallet(pk, rpcProvider);
  console.log('Wallet:', wallet.address);

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  page.on('console', msg => console.log('[C]', msg.text().substring(0, 200)));

  await page.addInitScript(`
    const addr = '${wallet.address}';
    const mockProvider = {
      isMetaMask: true, isConnected: () => true,
      selectedAddress: addr, chainId: '0x2105', networkVersion: '8453',
      _events: {},
      on(e, cb) { this._events[e] = this._events[e] || []; this._events[e].push(cb); return this; },
      removeListener() { return this; },
      removeAllListeners() { return this; },
      async request({ method, params }) {
        console.log('[MW]', method);
        switch(method) {
          case 'eth_requestAccounts':
          case 'eth_accounts': return [addr];
          case 'eth_chainId': return '0x2105';
          case 'net_version': return '8453';
          case 'wallet_switchEthereumChain': return null;
          case 'wallet_addEthereumChain': return null;
          case 'wallet_getCapabilities': return {};
          case 'wallet_getPermissions': return [{ parentCapability: 'eth_accounts' }];
          case 'wallet_requestPermissions': return [{ parentCapability: 'eth_accounts' }];
          case 'personal_sign': {
            window.__SIGN_MSG = params[0]; window.__SIGN_READY = true;
            return new Promise(r => { window.__RESOLVE_SIGN = r; });
          }
          case 'eth_signTypedData_v4': {
            window.__SIGN_MSG = params[1]; window.__SIGN_TYPE = 'typed_v4'; window.__SIGN_READY = true;
            return new Promise(r => { window.__RESOLVE_SIGN = r; });
          }
          case 'eth_sendTransaction': {
            window.__TX_DATA = JSON.stringify(params[0]); window.__TX_READY = true;
            return new Promise(r => { window.__RESOLVE_TX = r; });
          }
          default: {
            const r = await fetch('https://mainnet.base.org', {
              method: 'POST', headers: {'Content-Type':'application/json'},
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
    const info = { uuid: 'a1b2', name: 'MetaMask', icon: 'data:image/png;base64,iVBOR', rdns: 'io.metamask' };
    window.addEventListener('eip6963:requestProvider', () => {
      window.dispatchEvent(new CustomEvent('eip6963:announceProvider', {
        detail: Object.freeze({ info, provider: mockProvider })
      }));
    });
    window.dispatchEvent(new CustomEvent('eip6963:announceProvider', {
      detail: Object.freeze({ info, provider: mockProvider })
    }));
  `);

  await page.goto('https://app.qinv.ai', { waitUntil: 'networkidle', timeout: 30000 });
  await page.waitForTimeout(3000);
  await page.screenshot({ path: '/tmp/qinv-a.png', fullPage: false });
  console.log('\n--- Screenshot A saved ---');

  // Check if already connected (look for address display)
  const bodyText = await page.$eval('body', el => el.innerText);
  const connected = bodyText.includes('0x85') || bodyText.includes('c6E603');
  console.log('Connected:', connected);
  console.log('Body preview:', bodyText.substring(0, 500));

  // Click Big Three
  const card = await page.$(':text("The Big Three")');
  if (card) { await card.click(); await page.waitForTimeout(2000); }
  await page.screenshot({ path: '/tmp/qinv-b.png', fullPage: false });
  console.log('\n--- Screenshot B saved ---');

  // Now look for Sign In or Invest or Swap button
  const allButtons = await page.$$eval('button', els => els.map(e => e.textContent?.trim()).filter(t => t));
  console.log('Buttons:', allButtons.slice(0, 15));

  // Try clicking Sign In
  try {
    await page.click('button:has-text("Sign In")', { timeout: 3000 });
    await page.waitForTimeout(2000);
    
    // Try clicking MetaMask
    try {
      await page.click(':text("MetaMask")', { timeout: 3000 });
      await page.waitForTimeout(3000);
    } catch(e) { console.log('No MetaMask button'); }
    
    // Check for sign request
    const signReady = await page.evaluate(() => window.__SIGN_READY || false);
    console.log('Sign ready:', signReady);
    
    if (signReady) {
      const msg = await page.evaluate(() => window.__SIGN_MSG);
      const signType = await page.evaluate(() => window.__SIGN_TYPE || 'personal');
      console.log('Type:', signType, 'Msg:', String(msg).substring(0, 300));
      
      let signature;
      if (signType === 'typed_v4') {
        const typedData = JSON.parse(msg);
        const { domain, types, message } = typedData;
        delete types.EIP712Domain;
        signature = await wallet.signTypedData(domain, types, message);
      } else {
        let msgText = msg;
        if (msg.startsWith('0x')) msgText = Buffer.from(msg.slice(2), 'hex').toString('utf8');
        console.log('Text to sign:', msgText.substring(0, 300));
        signature = await wallet.signMessage(msgText);
      }
      
      await page.evaluate(s => window.__RESOLVE_SIGN(s), signature);
      console.log('Signed! Waiting for app response...');
      await page.waitForTimeout(5000);
    }
  } catch(e) { console.log('Sign In flow:', e.message.substring(0, 100)); }

  await page.screenshot({ path: '/tmp/qinv-c.png', fullPage: false });
  console.log('\n--- Screenshot C saved ---');
  const finalText = await page.$eval('body', el => el.innerText);
  console.log('Final page:', finalText.substring(0, 1500));

  await browser.close();
})();
