const { chromium } = require('playwright');
const { ethers } = require('ethers');

(async () => {
  const pk = process.env.AUDIT_WALLET_PK;
  if (!pk) { console.error('AUDIT_WALLET_PK not set'); process.exit(1); }

  const provider = new ethers.JsonRpcProvider('https://mainnet.base.org');
  const wallet = new ethers.Wallet(pk, provider);
  console.log('Wallet address:', wallet.address);

  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  // Inject a mock EIP-1193 provider before any page scripts run
  await page.addInitScript(`
    window.__MOCK_WALLET_ADDRESS = '${wallet.address}';
    window.__MOCK_CHAIN_ID = '0x2105'; // Base = 8453
    
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
        console.log('[MockWallet] request:', method, JSON.stringify(params || []));
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
          case 'eth_getBalance':
            return '0x0';
          case 'personal_sign':
          case 'eth_signTypedData_v4':
            // We'll need to handle signing server-side
            window.__PENDING_SIGN = { method, params };
            // Wait for the signed result
            return new Promise((resolve) => {
              window.__RESOLVE_SIGN = resolve;
            });
          case 'eth_sendTransaction':
            window.__PENDING_TX = params[0];
            return new Promise((resolve) => {
              window.__RESOLVE_TX = resolve;
            });
          case 'eth_estimateGas':
            return '0x30000';
          case 'eth_blockNumber':
            return '0x' + (30000000).toString(16);
          case 'eth_call':
            // Forward to real RPC
            const resp = await fetch('https://mainnet.base.org', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ jsonrpc: '2.0', id: 1, method: 'eth_call', params })
            });
            const data = await resp.json();
            return data.result;
          default:
            // Forward unknown calls to real RPC
            const resp2 = await fetch('https://mainnet.base.org', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ jsonrpc: '2.0', id: 1, method, params })
            });
            const data2 = await resp2.json();
            return data2.result;
        }
      }
    };
    
    window.ethereum = mockProvider;
    
    // Also handle EIP-6963 provider discovery
    window.addEventListener('eip6963:requestProvider', () => {
      window.dispatchEvent(new CustomEvent('eip6963:announceProvider', {
        detail: {
          info: { uuid: 'mock-wallet', name: 'MockWallet', icon: '', rdns: 'io.metamask' },
          provider: mockProvider
        }
      }));
    });
  `);

  // Navigate to app
  console.log('\\nNavigating to app.qinv.ai...');
  await page.goto('https://app.qinv.ai', { waitUntil: 'networkidle', timeout: 30000 });
  
  // Take screenshot
  await page.screenshot({ path: '/tmp/qinv-app-1.png', fullPage: true });
  console.log('Screenshot saved: /tmp/qinv-app-1.png');
  
  // Get page content
  const title = await page.title();
  console.log('Page title:', title);
  
  // Look for connect wallet button
  const buttons = await page.$$eval('button', els => els.map(e => ({ text: e.textContent?.trim(), class: e.className })));
  console.log('\\nButtons found:', JSON.stringify(buttons.slice(0, 10), null, 2));

  // Check console for any contract addresses or errors
  page.on('console', msg => {
    const text = msg.text();
    if (text.includes('0x') || text.includes('MockWallet') || text.includes('error') || text.includes('Error')) {
      console.log('[Console]', text);
    }
  });

  // Try to find and click connect wallet
  const connectBtn = await page.$('button:has-text("Connect"), button:has-text("connect"), button:has-text("Wallet"), button:has-text("wallet")');
  if (connectBtn) {
    console.log('\\nFound connect button, clicking...');
    await connectBtn.click();
    await page.waitForTimeout(3000);
    await page.screenshot({ path: '/tmp/qinv-app-2.png', fullPage: true });
    console.log('Screenshot after connect: /tmp/qinv-app-2.png');
  } else {
    console.log('\\nNo connect button found - may already be connected or different UI');
  }

  // Get all visible text
  const bodyText = await page.$eval('body', el => el.innerText);
  console.log('\\nPage text (first 2000 chars):', bodyText.substring(0, 2000));

  await browser.close();
})();
