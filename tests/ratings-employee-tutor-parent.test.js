// Run: node tests/ratings-employee-tutor-parent.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:1000}});const errs=[];p.on('pageerror',e=>errs.push(e.message));p.on('dialog',d=>d.accept(d.message().includes('Rate')?'4':'Good'));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);await p.click('[data-v=match]');
await p.click('text=Choose >> nth=2');await p.check('#mQuiet');await p.click('#mFind');await p.click('#profiles [aria-label="Rate employee"] >> nth=0');console.log('emp:',await p.textContent('#profiles [aria-label="Rate employee"] >> nth=0'));
await p.click('#asTutor');await p.click('#tFind');console.log('tutor chip:',await p.textContent('#tutors .chip >> nth=0'));await p.click('#tutors >> text=/Contact ₹349/ >> nth=0');await p.click('#tutors >> text=★ Rate tutor');console.log('tutor after:',await p.textContent('#tutors .chip >> nth=0'));
await p.fill('#prName','Sharma family (Kothrud)');await p.selectOption('#prStars','5');await p.fill('#prText','Paid on time');await p.click('#prSave');console.log('parents:',await p.textContent('#prList'));
const other=async()=>(await p.textContent('#v-match')).match(/Rate company|Rating|Household worker.*★/g);await p.click('#asCand');await p.check('#pAdult');await p.check('#pConsent');await p.click('#pSave');console.log('cand ratings?',await other());await p.click('#asHouse');await p.click('#hFind');console.log('house stars?',(await p.textContent('#workers')).includes('★'));
await p.click('#asTutor');await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png'),fullPage:true});
console.log('errors:',errs);await b.close()})();
