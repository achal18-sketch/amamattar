// Run: node tests/pipeline-tutor-cities.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:1100}});const errs=[];p.on('pageerror',e=>errs.push(e.message));p.on('dialog',d=>d.accept('900000'));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);await p.click('[data-v=match]');await p.waitForTimeout(200);
console.log('plans:',(await p.textContent('#plans')).replace(/\s+/g,' ').slice(0,260));
await p.click('#planTabs >> text=Pay as you go');console.log('payg:',(await p.textContent('#plans')).replace(/\s+/g,' ').slice(0,400));
await p.click('#planTabs >> text=Subscription plans');await p.click('#plans >> text=Choose >> nth=2');await p.check('#mQuiet');await p.click('#mFind');
for(let i=0;i<3;i++){await p.click('#profiles >> text=💌 Send interest >> nth=0');}
await p.waitForTimeout(2800);console.log('pipe:',(await p.textContent('#pipeKpi')).replace(/\s+/g,' '));
const nx=await p.$('#pipeList >> text=/Next:/');if(nx){await nx.click();await p.waitForTimeout(100)}
await p.click('#pipeList >> text=⏰ Nudge >> nth=0').catch(()=>{});
const sel=await p.$('#pipeList select');if(sel){await sel.selectOption('Joined');await p.waitForTimeout(200)}
console.log('after:',(await p.textContent('#pipeKpi')).replace(/\s+/g,' '),'| bell',await p.textContent('#bellN'));
await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png'),fullPage:true});
await p.click('#asTutor');await p.selectOption('#tCity','Jaipur');await p.click('#tFind');console.log('jaipur tutors',await p.$$eval('#tutors>div',d=>d.length),(await p.textContent('#tutors>div')).slice(0,80));
await p.selectOption('#tCity','Other city…');await p.click('#tFind');console.log('other:',(await p.textContent('#tutors')).slice(0,40));
console.log('errors:',errs);await b.close()})();
