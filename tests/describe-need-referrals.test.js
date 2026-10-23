// Run: node tests/describe-need-referrals.test.js  (needs `npm i playwright`; set CHROME_PATH if Chromium is not installed by Playwright)
const {chromium}=require('playwright');(async()=>{const b=await chromium.launch({executablePath:process.env.CHROME_PATH||undefined});
const p=await b.newPage({viewport:{width:1280,height:1000}});const errs=[];p.on('pageerror',e=>errs.push(e.message));p.on('dialog',d=>d.accept('4'));
await p.goto('file://'+require('path').resolve(__dirname,'../app/index.html'));await p.waitForTimeout(400);
const T=['I need a maths tutor for my Class 9 and 10 kids at home in Pune, 3 evenings a week, Hindi or English','Looking for a senior React web developer, remote or Bengaluru, 5 years','Need a driver for my family in Delhi, full time','We want a singer for weddings in Jaipur on project basis','Urgent: 3 telecallers in Indore, fresher ok, Hindi, 15k per month','Need a nurse to look after my old mother at home in Kochi'];
for(const t of T){await p.fill('#need',t);await p.click('#needBtn');await p.waitForTimeout(250);console.log('>',t.slice(0,40),'=>',(await p.textContent('#needOut')),'| levels:',await p.inputValue('#level'))}
await p.screenshot({path:require('path').resolve(__dirname,'out/'+require('path').basename(__filename)+'.png'),clip:{x:0,y:60,width:1280,height:700}});
await p.click('[data-v=match]');await p.click('text=Choose >> nth=2');await p.fill('#mNeed','Need 2 call-centre agents in Indore or remote, Hindi speaking, 1+ year, up to 3 lakh');await p.click('#mNeedBtn');await p.waitForTimeout(200);
console.log('M:',await p.textContent('#mNeedOut'),'| role',await p.inputValue('#mRole'),'| exp',await p.inputValue('#mExp'),'| bud',await p.inputValue('#mBud'),'| mode',await p.inputValue('#mMode'));
await p.check('#mQuiet');await p.click('#mFind');await p.click('#profiles [aria-label=Shortlist] >> nth=0');
const [dl]=await Promise.all([p.waitForEvent('download',{timeout:3000}).catch(()=>null),p.click('#mExport')]);console.log('csv download',!!dl);
await p.click('#refSim');console.log('bell',await p.textContent('#bellN'),'| ref',await p.textContent('#refStat'));
await p.click('#asTutor');await p.click('#tFind');console.log('tutor btn',await p.textContent('#tutors button >> nth=0'));await p.click('#tutors >> text=Contact ₹349 >> nth=0');
console.log('tutor plans',(await p.textContent('#plans')).replace(/\s+/g,' ').slice(0,220));
console.log('errors:',errs);await b.close()})();
