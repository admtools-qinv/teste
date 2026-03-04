const { chromium } = require('playwright');
const { ethers } = require('ethers');

(async () => {
  const pk = process.env.AUDIT_WALLET_PK;
  const wallet = new ethers.Wallet(pk, new ethers.JsonRpcProvider('https://mainnet.base.org'));
  const addr = wallet.address;
  console.log('Wallet:', addr);

  const browser = await chromium.launch({ headless: true });
  const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });
  
  page.on('console', msg => {
    const t = msg.text();
    if (t.includes('[MW]') && (t.includes('TX') || t.includes('SIGN')))
      console.log('[C]', t.substring(0, 500));
  });

  const initScript = `
    const addr = "${addr}";
    const mp = {
      isMetaMask:true, isConnected:()=>true, selectedAddress:addr, chainId:'0x2105', networkVersion:'8453',
      _events:{}, on(e,cb){this._events[e]=this._events[e]||[];this._events[e].push(cb);return this},
      removeListener(){return this}, removeAllListeners(){return this},
      async request({method,params}){
        switch(method){
          case 'eth_requestAccounts':case 'eth_accounts':return[addr];
          case 'eth_chainId':return'0x2105';case 'net_version':return'8453';
          case 'wallet_switchEthereumChain':case 'wallet_addEthereumChain':return null;
          case 'wallet_getCapabilities':return{};
          case 'wallet_getPermissions':return[{parentCapability:'eth_accounts'}];
          case 'personal_sign':{
            console.log('[MW] SIGN:',params[0].substring(0,100));
            window.__SIGN_MSG=params[0];window.__SIGN_READY=true;
            return new Promise(r=>{window.__RESOLVE_SIGN=r});
          }
          case 'eth_signTypedData_v4':{
            console.log('[MW] TYPED_SIGN');
            window.__SIGN_MSG=params[1];window.__SIGN_TYPE='typed_v4';window.__SIGN_READY=true;
            return new Promise(r=>{window.__RESOLVE_SIGN=r});
          }
          case 'eth_sendTransaction':{
            const tx=params[0];
            console.log('[MW] TX to:',tx.to,'func:',(tx.data||'').substring(0,10));
            window.__TX_DATA=JSON.stringify(tx);window.__TX_READY=true;
            return new Promise(r=>{window.__RESOLVE_TX=r});
          }
          default:{
            const r=await fetch('https://mainnet.base.org',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({jsonrpc:'2.0',id:1,method,params})});
            const d=await r.json();if(d.error)throw new Error(d.error.message);return d.result;
          }
        }
      }
    };
    window.ethereum=mp;
    const info={uuid:'a1b2',name:'MetaMask',icon:'data:image/png;base64,iVBOR',rdns:'io.metamask'};
    window.addEventListener('eip6963:requestProvider',()=>{
      window.dispatchEvent(new CustomEvent('eip6963:announceProvider',{detail:Object.freeze({info,provider:mp})}));
    });
    window.dispatchEvent(new CustomEvent('eip6963:announceProvider',{detail:Object.freeze({info,provider:mp})}));
  `;
  await page.addInitScript(initScript);

  await page.goto('https://app.qinv.ai', { waitUntil: 'networkidle', timeout: 30000 });
  await page.waitForTimeout(3000);
  await page.click(':text("The Big Three")');
  await page.waitForTimeout(3000);

  // Click Max
  const maxBtns = await page.$$('button');
  for (const btn of maxBtns) {
    if ((await btn.textContent())?.trim() === 'Max') {
      await btn.click();
      console.log('Clicked Max');
      break;
    }
  }
  await page.waitForTimeout(2000);
  await page.screenshot({ path: '/tmp/qinv-maxed.png', fullPage: false });

  // List buttons
  const btns = await page.$$('button');
  for (const btn of btns) {
    const txt = (await btn.textContent())?.trim();
    if (txt && !txt.includes('?') && txt.length < 40) {
      const dis = await btn.isDisabled();
      console.log('Btn:', txt, dis ? '(disabled)' : '');
    }
  }

  // Click Approve/Swap/Mint
  for (const btn of btns) {
    const txt = (await btn.textContent())?.trim();
    if (txt && (txt.includes('Approve') || txt.includes('Swap') || txt.includes('Mint'))) {
      if (!(await btn.isDisabled())) {
        console.log('\nClicking:', txt);
        await btn.click();
        await page.waitForTimeout(5000);
        break;
      }
    }
  }

  // Handle sign
  let signReady = await page.evaluate(() => window.__SIGN_READY || false);
  if (signReady) {
    const msg = await page.evaluate(() => window.__SIGN_MSG);
    const signType = await page.evaluate(() => window.__SIGN_TYPE || 'personal');
    console.log('\nSign type:', signType);
    
    let sig;
    if (signType === 'typed_v4') {
      const td = JSON.parse(msg);
      delete td.types.EIP712Domain;
      sig = await wallet.signTypedData(td.domain, td.types, td.message);
    } else {
      let mt = msg.startsWith('0x') ? Buffer.from(msg.slice(2), 'hex').toString('utf8') : msg;
      console.log('Signing:', mt.substring(0, 200));
      sig = await wallet.signMessage(mt);
    }
    await page.evaluate(s => window.__RESOLVE_SIGN(s), sig);
    console.log('Signed!');
    await page.waitForTimeout(5000);
  }

  // Handle TX
  let txReady = await page.evaluate(() => window.__TX_READY || false);
  if (txReady) {
    const txJson = await page.evaluate(() => window.__TX_DATA);
    const tx = JSON.parse(txJson);
    console.log('\n=== TRANSACTION ===');
    console.log('To:', tx.to);
    console.log('Function sig:', tx.data?.substring(0, 10));
    console.log('Data:', tx.data);
    console.log('Value:', tx.value);

    // Execute real TX
    const resp = await wallet.sendTransaction({ to: tx.to, data: tx.data, value: tx.value || '0x0', gasLimit: 300000n });
    console.log('TX Hash:', resp.hash);
    const receipt = await resp.wait();
    console.log('Status:', receipt.status === 1 ? 'SUCCESS' : 'FAILED');
    console.log('Gas:', receipt.gasUsed.toString());

    await page.evaluate(h => window.__RESOLVE_TX(h), resp.hash);
    await page.waitForTimeout(5000);

    // Check for second TX (e.g., approve then mint)
    await page.screenshot({ path: '/tmp/qinv-after-tx1.png', fullPage: false });
    
    txReady = await page.evaluate(() => window.__TX_READY || false);
    signReady = await page.evaluate(() => window.__SIGN_READY || false);
    console.log('\nSecond round - TX:', txReady, 'Sign:', signReady);

    if (txReady) {
      const tx2Json = await page.evaluate(() => window.__TX_DATA);
      const tx2 = JSON.parse(tx2Json);
      console.log('\n=== TX 2 ===');
      console.log('To:', tx2.to);
      console.log('Function:', tx2.data?.substring(0, 10));
      console.log('Data:', tx2.data);

      const resp2 = await wallet.sendTransaction({ to: tx2.to, data: tx2.data, value: tx2.value || '0x0', gasLimit: 500000n });
      console.log('Hash:', resp2.hash);
      const rcpt2 = await resp2.wait();
      console.log('Status:', rcpt2.status === 1 ? 'SUCCESS' : 'FAILED');
      await page.evaluate(h => window.__RESOLVE_TX(h), resp2.hash);
      await page.waitForTimeout(5000);
    }
  }

  await page.screenshot({ path: '/tmp/qinv-final.png', fullPage: false });
  const ft = await page.$eval('body', el => el.innerText);
  console.log('\nFinal:', ft.substring(0, 1500));
  await browser.close();
})();
