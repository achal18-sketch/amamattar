// Run: node tests/find-candidates.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:900}});const errs=[];p.on('pageerror',e=>errs.push(e.message));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(300);await p.fill('#need','Need a nurse in Kochi, 3 years');await p.click('#needBtn');await p.waitForTimeout(200);
await p.click('#findCands');await p.waitForTimeout(200);console.log('role',await p.inputValue('#mRole'),'| visible match',await p.isVisible('#v-match'),'| first card',(await p.textContent('#profiles>div')).slice(0,60));
console.log('errors:',errs);await b.close()})();
