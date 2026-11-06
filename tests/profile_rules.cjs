const fs=require('node:fs'),path=require('node:path');
const {initializeTestEnvironment,assertSucceeds,assertFails}=require('@firebase/rules-unit-testing');
const {doc,setDoc,getDoc,updateDoc,serverTimestamp}=require('firebase/firestore');
(async()=>{
 const env=await initializeTestEnvironment({projectId:'demo-avance-catalog',firestore:{host:'127.0.0.1',port:8089,rules:fs.readFileSync(path.join(__dirname,'../firestore.rules'),'utf8')}});
 try {
  await env.clearFirestore();
  const user=env.authenticatedContext('new',{email:'new@example.com'}).firestore(), other=env.authenticatedContext('other').firestore();
  const base={uid:'new',email:'new@example.com',name:'Pessoa teste',role:'candidate',createdAt:serverTimestamp()};
  await assertFails(setDoc(doc(user,'users','new'),{...base,role:'company',cnpj:'34238864000168',cnpjStatus:'active'}));
  const company=env.authenticatedContext('new-company',{email:'co@example.com'}).firestore();
  await assertSucceeds(setDoc(doc(company,'users','new-company'),{...base,uid:'new-company',email:'co@example.com',role:'company',cnpj:'informado'}));
  await assertSucceeds(setDoc(doc(user,'users','new'),base));
  const editable={name:'Nome alterado',phone:'11999999999',city:'São Paulo',contactEmail:'contato@example.com',updatedAt:serverTimestamp()};
  await assertSucceeds(updateDoc(doc(user,'users','new'),editable));
  for(const extra of [{role:'company'},{cnpjStatus:'active'},{cnpj:'34238864000168'},{legalName:'Falso'},{email:'outro@example.com'},{createdAt:serverTimestamp()},{name:'x'},{phone:'x'.repeat(33)}]) await assertFails(updateDoc(doc(user,'users','new'),{...editable,...extra}));
  await assertFails(updateDoc(doc(other,'users','new'),editable));
  await assertFails(getDoc(doc(other,'users','new')));
  await assertSucceeds(setDoc(doc(user,'users','new','settings','accessibility'),{largeText:true}));
  await assertFails(setDoc(doc(user,'users','new','settings','accessibility'),{largeText:'yes'}));
  await assertFails(getDoc(doc(other,'users','new','settings','accessibility')));
  await assertFails(setDoc(doc(user,'companyCnpjs','34238864000168'),{uid:'new'}));
  await assertFails(setDoc(doc(user,'privateUsage','cnpj_TEST_new'),{count:0}));
  await env.withSecurityRulesDisabled(async ctx=>{
   const admin=ctx.firestore();
   await setDoc(doc(admin,'users','unverified'),{uid:'unverified',role:'company',name:'Empresa antiga'});
   await setDoc(doc(admin,'users','verified'),{uid:'verified',role:'company',name:'Empresa verificada',cnpjStatus:'active'});
   await setDoc(doc(admin,'resumes','new'),{shared:true,name:'Pessoa teste'});
  });
  await assertSucceeds(getDoc(doc(env.authenticatedContext('unverified').firestore(),'resumes','new')));
  await assertSucceeds(getDoc(doc(env.authenticatedContext('verified').firestore(),'resumes','new')));
  console.log('PASS: profile editing, immutable certification/role, settings ownership, declared company access');
 } finally {await env.cleanup();}
})().catch(error=>{console.error(error);process.exitCode=1;});
