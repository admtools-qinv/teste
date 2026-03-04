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

  // Collect console logs
  const consoleLogs = [];
  page.on('console', msg => {
    consoleLogs.push(msg.text());
  });

  // Collect network requests for contract addresses
  const contractCalls = [];
  page.on('request', req => {
    const url = req.url();
    if (url.includes('base.org') || url.includes('alchemy') || url.includes('infura') || url.includes('rpc')) {
      const body = req.postData();
      if (body) contractCalls.push(body);
    }
  });

  // Inject mock wallet with signing support
  await page.addInitScript(`
    window.__MOCK_WALLET_ADDRESS = '${wallet.address}';
    window.__PENDING_REQUESTS = [];
    
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
      emit: function(event, ...args) {
        (this._events[event] || []).forEach(cb => cb(...args));
      },
      request: async function({ method, params }) {
        console.log('[MockWallet]', method, JSON.stringify(params || []).substring(0, 200));
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
          case 'personal_sign':
          case 'eth_signTypedData_v4':
          case 'eth_signTypedData_v3':
          case 'eth_sign':
            window.__PENDING_REQUESTS.push({ method, params, id: Date.now() });
            return new Promise((resolve, reject) => {
              window.__RESOLVE_SIGN = resolve;
              window.__REJECT_SIGN = reject;
            });
          case 'eth_sendTransaction':
            window.__PENDING_REQUESTS.push({ method, params, id: Date.now() });
            console.log('[MockWallet] TX PENDING:', JSON.stringify(params[0]));
            return new Promise((resolve, reject) => {
              window.__RESOLVE_TX = resolve;
              window.__REJECT_TX = reject;
            });
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

  // Click "The Big Three" portfolio
  console.log('\nLooking for The Big Three...');
  const bigThree = await page.$('text=The Big Three');
  if (bigThree) {
    await bigThree.click();
    console.log('Clicked The Big Three');
    await page.waitForTimeout(3000);
    await page.screenshot({ path: '/tmp/qinv-step2.png', fullPage: true });
    console.log('Screenshot: /tmp/qinv-step2.png');
    
    // Get page text
    const text = await page.$eval('body', el => el.innerText);
    console.log('\nPage text:\n', text.substring(0, 3000));
  }

  // Look for any input fields (amount input)
  const inputs = await page.$$eval('input', els => els.map(e => ({
    type: e.type,
    placeholder: e.placeholder,
    value: e.value,
    name: e.name
  })));
  console.log('\nInputs found:', JSON.stringify(inputs, null, 2));

  // Print collected RPC calls (may contain contract addresses)
  console.log('\n=== RPC Calls (contract addresses) ===');
  const uniqueAddresses = new Set();
  contractCalls.forEach(call => {
    try {
      const parsed = JSON.parse(call);
      if (parsed.params && parsed.params[0] && parsed.params[0].to) {
        uniqueAddresses.add(parsed.params[0].to);
      }
    } catch(e) {}
  });
  console.log('Contract addresses from RPC:', [...uniqueAddresses]);

  // Print relevant console logs
  console.log('\n=== Console Logs (filtered) ===');
  consoleLogs.filter(l => 
    l.includes('0x') || l.includes('MockWallet') || l.includes('contract') || l.includes('vault')
  ).forEach(l => console.log(l));

  await browser.close();
})();
