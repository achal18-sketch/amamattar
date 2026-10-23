// Run: node tests/locations-languages-chat.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:1100}});const errs=[];p.on('pageerror',e=>errs.push(e.message));p.on('dialog',d=>d.accept('fake'));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);
await p.click('[data-v=match]');await p.click('text=Choose >> nth=2');await p.check('#mQuiet');await p.click('#mFind');await p.waitForTimeout(200);
console.log('cards',await p.$$eval('#profiles>div',d=>d.length),'|',(await p.$$eval('#profiles>div .note:nth-of-type(2)',d=>d.slice(0,3).map(x=>x.textContent))).join(' || '));
await p.uncheck('#mReloc');console.log('no-reloc cards',await p.$$eval('#profiles>div',d=>d.length));await p.check('#mReloc');
await p.fill('#mCities input','Kochi');await p.press('#mCities input','Enter');await p.waitForTimeout(100);console.log('cities',await p.textContent('#mCities'));
await p.click('#profiles [aria-label=Shortlist] >> nth=0');await p.check('#mShort');console.log('short',await p.$$eval('#profiles>div',d=>d.length));await p.uncheck('#mShort');
await p.click('#profiles [aria-label="Report profile"] >> nth=1');console.log('after report',await p.$$eval('#profiles>div',d=>d.length));
await p.click('#mSave');console.log((await p.textContent('#savedSearches')).slice(0,80));
await p.click('text=💌 Send interest >> nth=0');await p.waitForTimeout(2800);const c=await p.$('text=💬 Chat');if(c){await c.click();await p.fill('#chatIn','Hi, free tomorrow 11am?');await p.press('#chatIn','Enter');await p.waitForTimeout(1500);console.log('chat:',await p.textContent('#chatLog'));await p.click('#chatClose')}
await p.selectOption('#uiLang','hi');await p.waitForTimeout(100);console.log('hi nav:',await p.textContent('#nav'));await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png')});
await p.selectOption('#uiLang','ur');console.log('dir',await p.evaluate(()=>document.documentElement.dir));await p.selectOption('#uiLang','en');
await p.click('#themeBtn');console.log('theme',await p.evaluate(()=>document.documentElement.dataset.theme));
await p.click('#asCand');console.log('cand cities',await p.textContent('#pCities'));
console.log('errors:',errs);await b.close()})();
