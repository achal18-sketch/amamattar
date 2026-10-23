// Run: node tests/ai-off-scheduling.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:1000},acceptDownloads:true});const errs=[];p.on('pageerror',e=>errs.push(e.message));
p.on('dialog',d=>d.accept(d.message().includes('date')?'2026-10-20 11:00':d.message().includes('Meet')?'https://meet.google.com/abc-defg-hij':''));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);
console.log('nav:',await p.$$eval('#nav button',x=>x.filter(b=>b.offsetParent).map(b=>b.textContent).join(' | ')));
const vis=async s=>p.isVisible(s);console.log('persona',await vis('#persona'),'genBtn',await vis('#genBtn'),'dur',await vis('#dur'),'rubric',await vis('#rubricCard'),'need',await vis('#need'),'langs',await vis('#langChips'));
await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png')});
await p.click('[data-v=match]');await p.click('text=Choose >> nth=2');await p.check('#mQuiet');await p.click('#mFind');
console.log('badge:',await p.textContent('#profiles .chip >> nth=1'));
for(let i=0;i<3;i++)await p.click('#profiles >> text=💌 Send interest >> nth=0');await p.waitForTimeout(2800);
console.log('AI btn visible',await p.isVisible('text=Invite to AI interview'));
const [d]=await Promise.all([p.waitForEvent('download',{timeout:4000}),p.click('#profiles >> text=📅 Schedule interview >> nth=0')]);console.log(require('fs').readFileSync(await d.path(),'utf8').split('\n').filter(l=>/SUMMARY|LOCATION|DTSTART/.test(l)).join(' | '));
console.log('stage:',(await p.textContent('#pipeList')).match(/Interview scheduled/)?'ok':'missing');
await p.click('#planTabs >> text=Pay as you go');await p.evaluate(()=>{ADMIN_OK=true;adminUi()});await p.check('#adminMode');await p.click('#planTabs >> text=Extras');console.log('ai addon present',(await p.textContent('#plans')).includes('AI interviewer'));
await p.click('#asCand');console.log('practice btn visible',await p.isVisible('text=Practice this interview'));
await p.selectOption('#uiLang','hi');console.log('hi nav:',await p.$$eval('#nav button',x=>x.filter(b=>b.offsetParent).map(b=>b.textContent).join(' | ')));
console.log('errors:',errs);await b.close()})();
