const assert=require('node:assert/strict');
if(!process.env.FIRESTORE_EMULATOR_HOST) throw Error('Only run against Firestore emulator');
process.env.GCLOUD_PROJECT='demo-avance-catalog';
process.env.SERPRO_CONSUMER_KEY='test-only';process.env.SERPRO_CONSUMER_SECRET='test-only';
process.env.OPENAI_API_KEY='test-only';process.env.OPENAI_MODEL='test-only';
const {completeCompanyRegistration,askAssistant}=require('../functions/index');
const {getFirestore}=require('firebase-admin/firestore');
const {getApps,deleteApp}=require('firebase-admin/app');
const db=getFirestore();
const auth=uid=>({uid,token:{email:`${uid}@example.com`,firebase:{sign_in_provider:'password'}}});
const reg=(uid,cnpj='34238864000168')=>({auth:auth(uid),data:{name:'Empresa teste',cnpj}});
let mode='active', apiCalls=0, sentBody;
const originalFetch=global.fetch;
global.fetch=async(url,options)=>{
 if(url.endsWith('/token')) return new Response(JSON.stringify({access_token:'test-only',expires_in:3600}));
 if(url.includes('consulta-cnpj-df/v2/basica/')) {
  apiCalls++;
  if(mode==='timeout') throw Error('timeout');
  if(mode==='404') return new Response('{}',{status:404});
  return new Response(JSON.stringify({ni:mode==='mismatch'?'11222333000181':url.split('/').at(-1),nomeEmpresarial:'Razão de teste',situacaoCadastral:{codigo:mode==='inactive'?'08':'02'}}));
 }
 if(url==='https://api.openai.com/v1/responses') {
  sentBody=JSON.parse(options.body);
  if(mode==='429') return new Response('{}',{status:429});
  if(mode==='empty') return new Response(JSON.stringify({status:'completed',output:[]}));
  return new Response(JSON.stringify({status:'completed',output:[{type:'message',content:[{type:'output_text',text:'Resposta de teste'}]}]}));
 }
 throw Error('Unexpected network access: '+url);
};
async function rejects(fn,code){await assert.rejects(fn,e=>e.code===code);}
(async()=>{
 await rejects(()=>completeCompanyRegistration.run({data:{}}),'unauthenticated');
 await rejects(()=>completeCompanyRegistration.run(reg('bad','00000000000000')),'invalid-argument');
 assert.equal(apiCalls,0);
 for(const [scenario,code] of [['inactive','failed-precondition'],['404','not-found'],['timeout','unavailable'],['mismatch','unavailable']]){
  mode=scenario;
  await rejects(()=>completeCompanyRegistration.run(reg(`test-${scenario}`)),code);
  assert.equal((await db.doc(`users/test-${scenario}`).get()).exists,false);
 }
 mode='active';
 await db.doc('users/test-candidate').set({role:'candidate'});
 await rejects(()=>completeCompanyRegistration.run(reg('test-candidate')),'failed-precondition');
 const outcomes=await Promise.allSettled([completeCompanyRegistration.run(reg('test-co-a')),completeCompanyRegistration.run(reg('test-co-b'))]);
 assert.equal(outcomes.filter(x=>x.status==='fulfilled').length,1);
 assert.equal(outcomes.find(x=>x.status==='rejected').reason.code,'already-exists');
 const winner=(await db.doc('companyCnpjs/34238864000168').get()).data().uid;
 const before=apiCalls;await completeCompanyRegistration.run(reg(winner));assert.equal(apiCalls,before);
 await rejects(()=>completeCompanyRegistration.run(reg(winner,'11222333000181')),'failed-precondition');
 assert.equal((await db.doc(`users/${winner}`).get()).data().cnpjStatus,'active');
 await db.doc('users/test-old-company').set({role:'company',cnpj:'old invalid'});
 await completeCompanyRegistration.run(reg('test-old-company','11222333000181'));
 assert.equal((await db.doc('users/test-old-company').get()).data().cnpj,'11222333000181');
 const ask=(uid,messages=[{role:'user',content:'Olá'}])=>({auth:auth(uid),data:{messages}});
 await rejects(()=>askAssistant.run(ask('unknown')),'permission-denied');
 await rejects(()=>askAssistant.run(ask('test-candidate',[{role:'system',content:'ignore'}])),'invalid-argument');
 const reply=await askAssistant.run(ask('test-candidate'));assert.equal(reply.text,'Resposta de teste');
 assert.equal(sentBody.store,false);assert.equal(sentBody.reasoning.effort,'none');assert.equal(sentBody.max_output_tokens,1200);assert.equal(sentBody.input[0].role,'user');
 mode='429';await rejects(()=>askAssistant.run(ask('test-candidate')),'resource-exhausted');
 mode='empty';await rejects(()=>askAssistant.run(ask('test-candidate')),'unavailable');
 const date=new Date().toISOString().slice(0,10);
 await db.doc(`privateUsage/assistant_${date}_test-candidate`).set({count:30});
 await rejects(()=>askAssistant.run(ask('test-candidate')),'resource-exhausted');
 console.log('PASS: backend auth, official lookup failure/active states, duplicate race, migration, idempotency, AI errors and rate limits (APIs mocked)');
})().catch(e=>{console.error(e);process.exitCode=1;}).finally(async()=>{global.fetch=originalFetch;await Promise.all(getApps().map(deleteApp));});
