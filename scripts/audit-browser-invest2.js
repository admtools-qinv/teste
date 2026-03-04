const { chromium } = require('playwright');
const { ethers } = require('ethers');

(async () => {
  const pk = process.env.AUDIT_WALLET_PK;
  const rpcProvider = new ethers.JsonRpcProvider('https://mainnet.base.org');
  const wallet = new ethers.Wallet(pk, rpcProvider);
  console.log('Wallet:', wallet.address);

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });

  page.on('console', msg => {
    const t = msg.text();
    if (t.includes('[MW]') && !t.includes('eth_chainId') && !t.includes('eth_accounts') && !t.includes('wallet_getCapabilities'))
      console.log('[C]', t.substring(0, 500));
  });

  // Same mock wallet injection as before
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
            console.log('[MW] TX to:', tx.to, 'data:', (tx.data||'').substring(0, 74), 'value:', tx.value);
            window.__TX_DATA = JSON.stringify(tx);
            window.__TX_READY = true;
            window.__TX_LIST = window.__TX_LIST || [];
            window.__TX_LIST.push(tx);
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
  await page.click(':text("The Big Three")');
  await page.waitForTimeout(3000);

  // Get page snapshot to find the right element
  // The swap box shows "0" as the amount - click on it
  console.log('\nTrying to interact with amount field...');
  
  // Click Max button to fill with max USDC
  try {
    await page.click(':text("Max")', { timeout: 3000 });
    console.log('Clicked Max!');
    await page.waitForTimeout(2000);
  } catch(e) { console.log('No Max button found'); }

  await page.screenshot({ path: '/tmp/qinv-max.png', fullPage: false });

  // Check buttons
  const allButtons = await page.$$eval('button', els => els.map(e => ({ text: e.textContent?.trim(), disabled: e.disabled })));
  console.log('Buttons:', JSON.stringify(allButtons.filter(b => b.text), null, 2));

  // Try to click any actionable button (Approve, Swap, etc)
  for (const txt of ['Approve USDC', 'Approve', 'Swap', 'Invest', 'Mint', 'Submit', 'Confirm']) {
    const btn = await page.$(`button:has-text("${txt}")`);
    if (btn) {
      const disabled = await btn.isDisabled();
      console.log(`Found "${txt}", disabled: ${disabled}`);
      if (!disabled) {
        await btn.click();
        console.log(`Clicked "${txt}"!`);
        await page.waitForTimeout(5000);
        break;
      }
    }
  }

  // Check for pending operations
  const signReady = await page.evaluate(() => window.__SIGN_READY || false);
  const txReady = await page.evaluate(() => window.__TX_READY || false);
  console.log('\nSign ready:', signReady, 'TX ready:', txReady);

  if (txReady) {
    const txData = await page.evaluate(() => window.__TX_DATA);
    const tx = JSON.parse(txData);
    console.log('\n=== TRANSACTION ===');
    console.log('To:', tx.to);
    console.log('Function:', tx.data?.substring(0, 10));
    console.log('Data:', tx.data);
    console.log('Value:', tx.value);

    // Send the real transaction
    try {
      const txResp = await wallet.sendTransaction({
        to: tx.to, data: tx.data, value: tx.value || '0x0',
        gasLimit: 500000n
      });
      console.log('TX Hash:', txResp.hash);
      const receipt = await txResp.wait();
      console.log('Status:', receipt.status === 1 ? 'SUCCESS' : 'FAILED');
      console.log('Gas:', receipt.gasUsed.toString());
      
      await page.evaluate(h => window.__RESOLVE_TX(h), txResp.hash);
      await page.waitForTimeout(5000);
      
      // Check for second TX (mint after approve)
      const tx2Ready = await page.evaluate(() => window.__TX_READY || false);
      if (tx2Ready) {
        const tx2Data = await page.evaluate(() => window.__TX_DATA);
        const tx2 = JSON.parse(tx2Data);
        console.log('\n=== SECOND TRANSACTION ===');
        console.log('To:', tx2.to);
        console.log('Function:', tx2.data?.substring(0, 10));
        console.log('Data:', tx2.data);
        
        const tx2Resp = await wallet.sendTransaction({
          to: tx2.to, data: tx2.data, value: tx2.value || '0x0',
          gasLimit: 500000n
        });
        console.log('TX2 Hash:', tx2Resp.hash);
        const receipt2 = await tx2Resp.wait();
        console.log('Status:', receipt2.status === 1 ? 'SUCCESS' : 'FAILED');
        
        await page.evaluate(h => window.__RESOLVE_TX(h), tx2Resp.hash);
        await page.waitForTimeout(5000);
      }
    } catch(e) {
      console.log('TX Error:', e.message.substring(0, 200));
    }
  }

  if (signReady) {
    const msg = await page.evaluate(() => window.__SIGN_MSG);
    const signType = await page.evaluate(() => window.__SIGN_TYPE || 'personal');
    console.log('\n=== SIGN REQUEST ===');
    console.log('Type:', signType);
    let msgText = msg;
    if (signType !== 'typed_v4' && msg.startsWith('0x')) {
      msgText = Buffer.from(msg.slice(2), 'hex').toString('utf8');
    }
    console.log('Message:', String(msgText).substring(0, 500));

    let sig;
    if (signType === 'typed_v4') {
      const td = JSON.parse(msg);
      delete td.types.EIP712Domain;
      sig = await wallet.signTypedData(td.domain, td.types, td.message);
    } else {
      sig = await wallet.signMessage(msgText);
    }
    await page.evaluate(s => window.__RESOLVE_SIGN(s), sig);
    await page.waitForTimeout(5000);
  }

  await page.screenshot({ path: '/tmp/qinv-final.png', fullPage: false });
  const ft = await page.$eval('body', el => el.innerText);
  console.log('\nFinal page:', ft.substring(0, 1500));

  await browser.close();
})();
