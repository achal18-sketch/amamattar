// Run: node tests/resume-upgrade.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:1100}});const errs=[];p.on('pageerror',e=>errs.push(e.message));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);await p.click('[data-v=match]');await p.click('#asCand');
console.log('plans:',(await p.textContent('#plans')).replace(/\s+/g,' ').match(/AI resume[^₹]*₹\d+|✨[^•]{0,50}/g));
await p.setInputFiles('#resFile',require('path').resolve(__dirname,'fixtures/resume.txt'));await p.waitForTimeout(200);console.log('score:',await p.textContent('#resScore'),'| tips:',(await p.textContent('#resTips')).slice(0,120),'| gate:',await p.textContent('#resGate'));
await p.click('#resBtn');await p.waitForTimeout(200);console.log('free click:',(await p.textContent('#resGate')).slice(0,60));
await p.click('#resGate >> text=/Buy 1 upgrade/');await p.waitForTimeout(500);console.log('after buy:',await p.isVisible('#resOutWrap'),await p.textContent('#resNew'));console.log((await p.inputValue('#resOut')).slice(0,420));
await p.click('#resUse');console.log('headline:',await p.inputValue('#pHead'),'| skills:',await p.inputValue('#pSkills'));
await p.click('text=Choose >> nth=1');await p.waitForTimeout(100);console.log('gold gate:',await p.textContent('#resGate'));await p.click('#resBtn');await p.waitForTimeout(300);console.log('gold after:',await p.textContent('#resGate'));
await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png'),fullPage:true});console.log('errors:',errs);await b.close()})();
