// Run: node tests/plans-credits-tutors.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:1100}});const errs=[];p.on('pageerror',e=>errs.push(e.message));p.on('dialog',d=>d.accept('600000'));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);await p.click('[data-v=match]');await p.waitForTimeout(200);
const cards=async()=>p.$$eval('#plans>div',d=>d.length);
console.log('tabs',await p.$$eval('#planTabs button',x=>x.map(b=>b.textContent).join(' | ')),'cards',await cards());
await p.evaluate(()=>{ADMIN_OK=true;adminUi()});await p.check('#adminMode');console.log('admin tabs',await p.$$eval('#planTabs button',x=>x.length),'cards',await cards());await p.uncheck('#adminMode');
await p.click('#billChips [data-b=y]');await p.waitForTimeout(100);await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png')});
await p.click('#planTabs >> text=Pay as you go');await p.click('#plans >> text=Buy (demo) >> nth=1');console.log(await p.textContent('#wallet'));
await p.check('#mQuiet');await p.click('#mFind');await p.click('text=💌 Send interest >> nth=0');await p.waitForTimeout(2800);
const mh=await p.$('text=Mark hired');if(mh){await mh.click();await p.waitForTimeout(200)}console.log('hires:',await p.textContent('#hires'));
await p.click('#asTutor');await p.click('#tFind');await p.click('#tutors >> text=Contact ₹349 >> nth=0');await p.waitForTimeout(200);await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png'),fullPage:true});
console.log('tutor tab cards',await cards());console.log('errors:',errs);await b.close()})();
