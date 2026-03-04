const { chromium } = require('playwright');
const { ethers } = require('ethers');

(async () => {
  const pk = process.env.AUDIT_WALLET_PK;
  const rpcProvider = new ethers.JsonRpcProvider('https://mainnet.base.org');
  const wallet = new ethers.Wallet(pk, rpcProvider);
  console.log('Wallet:', wallet.address);

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage();

  page.on('console', msg => {
    const t = msg.text();
    if (t.includes('[MW]') || t.includes('TX') || t.includes('SIGN') || t.includes('approve') || t.includes('mint'))
      console.log('[C]', t.substring(0, 500));
  });

  await page.addInitScript(`
    const addr = '${wallet.address}';
    const mockProvider = {
      isMetaMask: true, isConnected: () => true,
      selectedAddress: addr, chainId: '0x2105', networkVersion: '8453',
      _events: {},
      on(e, cb) { this._events[e]=this._events[e]||[]; this._events[e].push(cb); return this; },
      removeListener() { return this; }, removeAllListeners() { return this; },
      async request({ method, params }) {
        console.log('[MW]', method);
        switch(method) {
          case 'eth_requestAccounts': case 'eth_accounts': return [addr];
          case 'eth_chainId': return '0x2105';
          case 'net_version': return '8453';
          case 'wallet_switchEthereumChain': case 'wallet_addEthereumChain': return null;
          case 'wallet_getCapabilities': return {};
          case 'wallet_getPermissions': return [{ parentCapability: 'eth_accounts' }];
          case 'wallet_requestPermissions': return [{ parentCapability: 'eth_accounts' }];
          case 'personal_sign': {
            console.log('[MW] SIGN:', params[0].substring(0, 200));
            window.__SIGN_MSG = params[0]; window.__SIGN_READY = true;
            return new Promise(r => { window.__RESOLVE_SIGN = r; });
          }
          case 'eth_signTypedData_v4': {
            console.log('[MW] TYPED_SIGN');
            window.__SIGN_MSG = params[1]; window.__SIGN_TYPE = 'typed_v4'; window.__SIGN_READY = true;
            return new Promise(r => { window.__RESOLVE_SIGN = r; });
          }
          case 'eth_sendTransaction': {
            const tx = params[0];
            console.log('[MW] TX to:', tx.to, 'data:', tx.data?.substring(0, 74), 'value:', tx.value);
            window.__TX_DATA = JSON.stringify(tx);
            window.__TX_READY = true;
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
      window.dispatchEvent(new CustomEvent('eip6963:announceProvider', { detail: Object.freeze({ info, provider: mockProvider }) }));
    });
    window.dispatchEvent(new CustomEvent('eip6963:announceProvider', { detail: Object.freeze({ info, provider: mockProvider }) }));
  `);

  await page.goto('https://app.qinv.ai', { waitUntil: 'networkidle', timeout: 30000 });
  await page.waitForTimeout(3000);

  // Click Big Three
  await page.click(':text("The Big Three")');
  await page.waitForTimeout(3000);

  // Type amount in input - find the USDC input
  console.log('\nLooking for amount input...');
  const inputs = await page.$$('input');
  console.log('Found', inputs.length, 'inputs');
  
  // Try typing in all inputs
  for (const input of inputs) {
    const placeholder = await input.getAttribute('placeholder');
    const type = await input.getAttribute('type');
    console.log('Input:', { placeholder, type });
  }

  // Click on the "0" next to USDC (it's likely an input or editable area)
  // Try clicking on the "You send" area
  try {
    await page.click('text=You send', { timeout: 2000 });
    await page.waitForTimeout(500);
  } catch(e) {}

  // Type 1 in any number input
  const numberInput = await page.$('input[type="number"], input[type="text"], input[inputmode="decimal"]');
  if (numberInput) {
    await numberInput.fill('1');
    console.log('Typed 1 in input');
    await page.waitForTimeout(2000);
  } else {
    // Maybe it's a contenteditable or the 0 is clickable
    console.log('No standard input found, trying to click the 0...');
    const zeroEl = await page.$('text=/^0$/');
    if (zeroEl) {
      await zeroEl.click();
      await page.keyboard.type('1');
      await page.waitForTimeout(2000);
    }
  }

  await page.screenshot({ path: '/tmp/qinv-amount.png', fullPage: false });
  console.log('Screenshot after amount entry');

  // Look for Approve/Swap/Invest button
  const allButtons = await page.$$eval('button', els => els.map(e => e.textContent?.trim()).filter(t => t));
  console.log('Buttons:', allButtons);

  // Click approve/swap button
  for (const btnText of ['Approve', 'Swap', 'Invest', 'Mint', 'Continue', 'Enter Amount']) {
    try {
      const btn = await page.$(`button:has-text("${btnText}")`);
      if (btn) {
        const disabled = await btn.getAttribute('disabled');
        console.log(`Button "${btnText}" found, disabled:`, disabled);
        if (!disabled) {
          await btn.click();
          console.log(`Clicked "${btnText}"`);
          await page.waitForTimeout(3000);
          break;
        }
      }
    } catch(e) {}
  }

  // Check for pending sign or TX
  const signReady = await page.evaluate(() => window.__SIGN_READY || false);
  const txReady = await page.evaluate(() => window.__TX_READY || false);
  console.log('\nSign ready:', signReady, 'TX ready:', txReady);

  if (signReady) {
    const msg = await page.evaluate(() => window.__SIGN_MSG);
    const signType = await page.evaluate(() => window.__SIGN_TYPE || 'personal');
    console.log('Sign type:', signType);
    console.log('Message:', String(msg).substring(0, 500));
    
    let signature;
    if (signType === 'typed_v4') {
      const typedData = JSON.parse(msg);
      const { domain, types, message } = typedData;
      delete types.EIP712Domain;
      signature = await wallet.signTypedData(domain, types, message);
    } else {
      let msgText = msg.startsWith('0x') ? Buffer.from(msg.slice(2), 'hex').toString('utf8') : msg;
      signature = await wallet.signMessage(msgText);
    }
    await page.evaluate(s => window.__RESOLVE_SIGN(s), signature);
    console.log('Signed!');
    await page.waitForTimeout(5000);
  }

  if (txReady) {
    const txData = await page.evaluate(() => window.__TX_DATA);
    console.log('\n=== TRANSACTION REQUEST ===');
    const tx = JSON.parse(txData);
    console.log('To:', tx.to);
    console.log('Data:', tx.data?.substring(0, 74));
    console.log('Value:', tx.value);
    
    // Decode the function call
    const funcSig = tx.data?.substring(0, 10);
    console.log('Function signature:', funcSig);
    
    // Actually send the TX
    console.log('\nSending real transaction...');
    const txResponse = await wallet.sendTransaction({
      to: tx.to,
      data: tx.data,
      value: tx.value || '0x0',
      gasLimit: 500000n
    });
    console.log('TX Hash:', txResponse.hash);
    const receipt = await txResponse.wait();
    console.log('TX Status:', receipt.status === 1 ? 'SUCCESS' : 'FAILED');
    console.log('Gas used:', receipt.gasUsed.toString());
    
    // Return hash to app
    await page.evaluate(h => window.__RESOLVE_TX(h), txResponse.hash);
    await page.waitForTimeout(5000);
  }

  await page.screenshot({ path: '/tmp/qinv-final.png', fullPage: false });
  console.log('\n--- Final screenshot saved ---');
  const finalText = await page.$eval('body', el => el.innerText);
  console.log('Final:', finalText.substring(0, 1000));

  await browser.close();
})();
