// Run: node tests/plans-per-role.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:900}});const errs=[];p.on('pageerror',e=>errs.push(e.message));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);await p.click('[data-v=match]');
for(const r of ['#asCo','#asCand','#asTutor']){await p.click(r);await p.waitForTimeout(150);
 const tabs=await p.$$eval('#planTabs button',x=>x.filter(b=>b.offsetParent).map(b=>b.textContent));
 console.log(r,'|',await p.textContent('#planTitle'),'| tabs:',tabs.join(', ')||'(none)','| cards:',(await p.$$eval('#plans>div .note:first-child',d=>d.map(x=>x.textContent))).join(', '));
 await p.screenshot({path:`/tmp/claude-0/role${r.slice(3)}.png`,clip:{x:0,y:60,width:1280,height:640}});}
await p.click('#billChips [data-b=m]');await p.waitForTimeout(100);console.log('tutor monthly:',(await p.textContent('#plans')).replace(/\s+/g,' ').slice(0,200));
await p.evaluate(()=>{ADMIN_OK=true;adminUi()});await p.check('#adminMode');console.log('admin tutor tabs:',await p.$$eval('#planTabs button',x=>x.length),'cards',await p.$$eval('#plans>div',d=>d.length));
await p.click('#asCo');console.log('admin co tabs:',await p.$$eval('#planTabs button',x=>x.map(b=>b.textContent).join(', ')));
console.log('errors:',errs);await b.close()})();
