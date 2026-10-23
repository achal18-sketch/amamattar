// Run: node tests/gst-invoice.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:1000},acceptDownloads:true});const errs=[];p.on('pageerror',e=>errs.push(e.message));
let n=0;p.on('dialog',d=>{n++;d.accept(d.message().includes('salary')?'600000':d.message().includes('state')?'Maharashtra':'27ABCDE1234F1Z5')});
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);await p.click('[data-v=match]');await p.waitForTimeout(200);
console.log((await p.textContent('#plans')).replace(/\s+/g,' ').slice(0,300));
await p.click('#planTabs >> text=Pay as you go');await p.click('#plans >> text=Buy (demo) >> nth=1');console.log('purchases:',(await p.textContent('#purchases')).slice(0,90));
await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png'),clip:{x:0,y:250,width:1280,height:600}});
await p.click('#planTabs >> text=Subscription plans');await p.click('#plans >> text=Choose >> nth=2');await p.check('#mQuiet');await p.click('#mFind');for(let i=0;i<3;i++)await p.click('#profiles >> text=💌 Send interest >> nth=0');await p.waitForTimeout(2800);
const mh=await p.$('#pipeList >> text=Mark hired');if(mh){await mh.click();await p.waitForTimeout(200)}console.log('hires:',(await p.textContent('#hires')).slice(-90));
const [d]=await Promise.all([p.waitForEvent('download',{timeout:4000}),p.click('text=🧾 Download tax invoice')]);const path=await d.path();console.log(require('fs').readFileSync(path,'utf8'));
console.log('errors:',errs);await b.close()})();
