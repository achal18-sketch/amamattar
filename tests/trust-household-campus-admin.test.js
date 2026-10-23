// Run: node tests/trust-household-campus-admin.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:1000}});const errs=[];p.on('pageerror',e=>errs.push(e.message));
p.on('dialog',d=>d.accept(d.message().includes('salary')?'600000':d.message().includes('Rate')?'5':'fake'));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);await p.click('[data-v=match]');
// company trust
await p.fill('#coGst','27ABCDE1234F1Z5');await p.click('#coVerify');await p.fill('#coWa','9800000010');await p.check('#coWaOn');console.log('badges:',await p.textContent('#coBadges'),'| free banner',await p.isVisible('#firstFree'));
await p.fill('#mBud','');await p.click('#mFind');console.log('no salary:',(await p.textContent('#profiles')).slice(0,60));await p.fill('#mBud','35');
await p.click('text=Choose >> nth=2');await p.check('#mQuiet');await p.click('#mFind');for(let i=0;i<3;i++)await p.click('#profiles >> text=💌 Send interest >> nth=0');await p.waitForTimeout(2800);
await p.click('#pipeList >> text=Mark hired >> nth=0');await p.waitForTimeout(200);console.log('first hire:',(await p.textContent('#hires')).slice(0,80),'| banner',await p.isVisible('#firstFree'),'| badges',await p.textContent('#coBadges'));
console.log('bell list:',(await p.evaluate(()=>M.notes.slice(0,2).map(n=>n.t))).join(' || '));
// candidate
await p.click('#asCand');await p.check('#pAdult');await p.check('#pConsent');await p.click('#pSave');await p.check('#cWaOn');await p.fill('#cMinSal','30');await p.waitForTimeout(100);console.log('jobs:',(await p.textContent('#jobsFor')).replace(/\s+/g,' ').slice(0,200));
await p.click('#jobsFor >> text=⚑ Report job >> nth=0');console.log('inbox:',(await p.textContent('#inbox')).slice(0,100));
// household
await p.click('#asHouse');await p.selectOption('#hType','Cook');await p.selectOption('#hCity','Mumbai');await p.click('#hFind');console.log('workers',await p.$$eval('#workers>div',d=>d.length),'| plans:',await p.textContent('#planTitle'),(await p.textContent('#plans')).replace(/\s+/g,' ').slice(0,120));
await p.click('#workers >> text=Contact ₹199 + GST >> nth=0');await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png')});
// campus
await p.click('#asCampus');await p.click('#cUpload');await p.click('#dCreate');console.log('campus:',await p.textContent('#cCount'),'|',await p.textContent('#drives'));await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png'),fullPage:true});
// admin
await p.click('[data-v=admin]');await p.fill('#admPin','2468');await p.click('#admGo');await p.waitForTimeout(200);console.log('admin rows',await p.$$eval('#cityRows tr',d=>d.length),'| first:',await p.textContent('#cityRows tr'),'| inv:',(await p.textContent('#ivOut')).replace(/\s+/g,' '));
await p.fill('#iv_h','200');console.log('inv 200 hires:',(await p.textContent('#ivOut')).replace(/\s+/g,' ').slice(-60));await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png'),fullPage:true});
console.log('errors:',errs);await b.close()})();
