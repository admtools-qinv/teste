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

  const consoleLogs = [];
  page.on('console', msg => consoleLogs.push(msg.text()));

  // Inject mock wallet WITH real signing
  await page.addInitScript(`
    window.__MOCK_WALLET_ADDRESS = '${wallet.address}';
    
    const mockProvider = {
      isMetaMask: true,
      isConnected: () => true,
      selectedAddress: '${wallet.address}',
      chainId: '0x2105',
      networkVersion: '8453',
      _events: {},
      on: function(event, cb) { 
        this._events[event] = this._events[event] || [];
        this._events[event].push(cb);
        return this;
      },
      removeListener: function() { return this; },
      removeAllListeners: function() { return this; },
      request: async function({ method, params }) {
        console.log('[MW]', method);
        switch(method) {
          case 'eth_requestAccounts':
          case 'eth_accounts':
            return ['${wallet.address}'];
          case 'eth_chainId':
            return '0x2105';
          case 'net_version':
            return '8453';
          case 'wallet_switchEthereumChain':
            return null;
          case 'personal_sign': {
            // Store the message to be signed server-side
            const msg = params[0];
            console.log('[MW] SIGN REQUEST:', msg);
            window.__SIGN_MESSAGE = msg;
            window.__SIGN_READY = true;
            // Wait for server to provide signature
            return new Promise((resolve) => {
              const check = setInterval(() => {
                if (window.__SIGN_RESULT) {
                  clearInterval(check);
                  const result = window.__SIGN_RESULT;
                  window.__SIGN_RESULT = null;
                  window.__SIGN_READY = false;
                  resolve(result);
                }
              }, 100);
            });
          }
          case 'eth_sendTransaction': {
            const tx = params[0];
            console.log('[MW] TX REQUEST:', JSON.stringify(tx));
            window.__TX_REQUEST = JSON.stringify(tx);
            window.__TX_READY = true;
            return new Promise((resolve) => {
              const check = setInterval(() => {
                if (window.__TX_RESULT) {
                  clearInterval(check);
                  const result = window.__TX_RESULT;
                  window.__TX_RESULT = null;
                  window.__TX_READY = false;
                  resolve(result);
                }
              }, 100);
            });
          }
          default:
            const resp = await fetch('https://mainnet.base.org', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ jsonrpc: '2.0', id: 1, method, params })
            });
            const data = await resp.json();
            if (data.error) throw new Error(data.error.message);
            return data.result;
        }
      }
    };
    window.ethereum = mockProvider;
  `);

  console.log('\nNavigating to app.qinv.ai...');
  await page.goto('https://app.qinv.ai', { waitUntil: 'networkidle', timeout: 30000 });
  await page.waitForTimeout(2000);

  // Click The Big Three
  const bigThree = await page.$('text=The Big Three');
  if (bigThree) {
    await bigThree.click();
    await page.waitForTimeout(2000);
  }

  // Click Sign In
  console.log('\nLooking for Sign In button...');
  const signInBtn = await page.$('button:has-text("Sign In")');
  if (signInBtn) {
    console.log('Found Sign In, clicking...');
    await signInBtn.click();
    await page.waitForTimeout(2000);
    
    // Check if a signing request appeared
    const signReady = await page.evaluate(() => window.__SIGN_READY);
    if (signReady) {
      const message = await page.evaluate(() => window.__SIGN_MESSAGE);
      console.log('\n=== SIGN REQUEST ===');
      console.log('Message to sign:', message);
      
      // Decode hex message if needed
      let msgText = message;
      if (message.startsWith('0x')) {
        msgText = Buffer.from(message.slice(2), 'hex').toString('utf8');
      }
      console.log('Decoded:', msgText);
      
      // Actually sign it
      const signature = await wallet.signMessage(msgText);
      console.log('Signature:', signature);
      
      // Send signature back to page
      await page.evaluate((sig) => { window.__SIGN_RESULT = sig; }, signature);
      console.log('Signature injected, waiting for response...');
      
      await page.waitForTimeout(5000);
      await page.screenshot({ path: '/tmp/qinv-signed.png', fullPage: true });
      console.log('Screenshot: /tmp/qinv-signed.png');
      
      const text = await page.$eval('body', el => el.innerText);
      console.log('\nPage text after sign:\n', text.substring(0, 3000));
    } else {
      console.log('No signing request triggered');
      await page.screenshot({ path: '/tmp/qinv-after-signin-click.png', fullPage: true });
    }
  }

  // Check for TX requests
  const txReady = await page.evaluate(() => window.__TX_READY);
  if (txReady) {
    const tx = await page.evaluate(() => window.__TX_REQUEST);
    console.log('\n=== TX REQUEST ===');
    console.log(tx);
  }

  // Print filtered console logs
  console.log('\n=== Key Console Logs ===');
  consoleLogs.filter(l => l.includes('[MW]') || l.includes('0x') && l.length < 200)
    .slice(0, 30)
    .forEach(l => console.log(l));

  await browser.close();
})();
