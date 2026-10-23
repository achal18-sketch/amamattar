// Run: node tests/ratings-scope.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:900}});const errs=[];p.on('pageerror',e=>errs.push(e.message));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);await p.click('[data-v=match]');
const has=async()=>(await p.textContent('#v-match')).match(/Rating|Rate |★ \d|★ new/g);
await p.click('text=Choose >> nth=2');await p.check('#mQuiet');await p.click('#mFind');console.log('co',await has());
await p.click('#asCand');await p.check('#pAdult');await p.check('#pConsent');await p.click('#pSave');console.log('cand',await has());
await p.click('#asTutor');await p.click('#tFind');await p.click('#tutors >> text=/Contact ₹349/ >> nth=0');console.log('tutor',await has());
await p.click('#asHouse');await p.click('#hFind');console.log('house',await has());
await p.click('#asCampus');await p.click('#cUpload');console.log('campus',await has());
console.log('errors:',errs);await b.close()})();
