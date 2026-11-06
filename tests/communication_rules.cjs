const fs=require('node:fs'),path=require('node:path');
const {initializeTestEnvironment,assertSucceeds,assertFails}=require('@firebase/rules-unit-testing');
const {doc,collection,setDoc,getDoc,getDocs,query,where,updateDoc,deleteDoc,serverTimestamp,Timestamp,writeBatch,runTransaction}=require('firebase/firestore');
(async()=>{
 const env=await initializeTestEnvironment({projectId:'demo-avance-catalog',firestore:{host:'127.0.0.1',port:8089,rules:fs.readFileSync(path.join(__dirname,'../firestore.rules'),'utf8')}});
 try{
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async ctx=>{
   const admin=ctx.firestore();
   for(const [uid,role,name] of [['co1','company','Empresa A'],['co2','company','Empresa B'],['ca1','candidate','Candidato A'],['ca2','candidate','Candidato B']]){
    await setDoc(doc(admin,'users',uid),{uid,role,name,...(role==='company'?{cnpjStatus:'active'}:{}),email:`${uid}@example.com`});
   }
   await setDoc(doc(admin,'resumes','ca1'),{uid:'ca1',shared:true,name:'Candidato A'});
   await setDoc(doc(admin,'resumes','ca2'),{uid:'ca2',shared:false,name:'Candidato B'});
  });
  const co=env.authenticatedContext('co1').firestore(),ca=env.authenticatedContext('ca1').firestore();
  const stranger=env.authenticatedContext('co2').firestore(),other=env.authenticatedContext('ca2').firestore(),anon=env.unauthenticatedContext().firestore();
  const chat={companyId:'co1',candidateId:'ca1',companyName:'Empresa A',candidateName:'Candidato A',createdAt:serverTimestamp(),updatedAt:serverTimestamp()};
  await assertSucceeds(getDoc(doc(co,'conversations','3_co1_ca1'))); // idempotent creation reads a missing doc
  await assertFails(setDoc(doc(co,'conversations','forged-id'),chat));
  await assertSucceeds(setDoc(doc(co,'conversations','3_co1_ca1'),chat));
  await assertFails(setDoc(doc(ca,'conversations','chat2'),chat));
  await assertFails(setDoc(doc(co,'conversations','3_co1_ca2'),{...chat,candidateId:'ca2',candidateName:'Candidato B'}));
  await assertFails(setDoc(doc(co,'conversations','wrong-company'),{...chat,companyId:'co2'}));
  await assertFails(updateDoc(doc(co,'conversations','3_co1_ca1'),{candidateId:'ca2',updatedAt:serverTimestamp()}));
  await assertSucceeds(getDocs(query(collection(co,'conversations'),where('companyId','==','co1'))));
  await assertSucceeds(getDocs(query(collection(ca,'conversations'),where('candidateId','==','ca1'))));
  await assertFails(getDocs(collection(co,'conversations')));
  for(const db of [stranger,other,anon])await assertFails(getDoc(doc(db,'conversations','3_co1_ca1')));
  await assertSucceeds(getDoc(doc(ca,'conversations','3_co1_ca1','messages','m1')));
  const batch=writeBatch(co);
  batch.set(doc(co,'conversations','3_co1_ca1','messages','m1'),{senderId:'co1',text:'Olá, vamos conversar?',createdAt:serverTimestamp()});
  batch.update(doc(co,'conversations','3_co1_ca1'),{updatedAt:serverTimestamp()});
  await assertSucceeds(batch.commit());
  await assertSucceeds(setDoc(doc(ca,'conversations','3_co1_ca1','messages','m2'),{senderId:'ca1',text:'Olá!',createdAt:serverTimestamp()}));
  await assertFails(setDoc(doc(co,'conversations','3_co1_ca1','messages','spoof'),{senderId:'ca1',text:'Mensagem falsa',createdAt:serverTimestamp()}));
  await assertFails(updateDoc(doc(ca,'conversations','3_co1_ca1','messages','m1'),{text:'Alterado'}));
  await assertFails(deleteDoc(doc(co,'conversations','3_co1_ca1','messages','m1')));
  await assertSucceeds(getDocs(collection(ca,'conversations','3_co1_ca1','messages')));
  await assertFails(getDocs(collection(stranger,'conversations','3_co1_ca1','messages')));
  const future=Timestamp.fromMillis(Date.now()+2*86400000),proposed=Timestamp.fromMillis(Date.now()+3*86400000),offered=Timestamp.fromMillis(Date.now()+4*86400000);
  const invite={conversationId:'3_co1_ca1',companyId:'co1',candidateId:'ca1',companyName:'Empresa A',candidateName:'Candidato A',title:'Entrevista de jardineiro',location:'Rua Exemplo, 123',startAt:future,durationMinutes:30,status:'pending',proposedAt:null,responseNote:'',revision:0,updatedBy:'co1',createdAt:serverTimestamp(),updatedAt:serverTimestamp()};
  await assertSucceeds(getDoc(doc(co,'interviews','i1')));
  await assertSucceeds(setDoc(doc(co,'interviews','i1'),invite));
  await assertFails(setDoc(doc(ca,'interviews','candidate-created'),{...invite,updatedBy:'ca1'}));
  await assertFails(setDoc(doc(stranger,'interviews','other-company'),{...invite,companyId:'co2',updatedBy:'co2'}));
  await assertFails(setDoc(doc(co,'interviews','past'),{...invite,startAt:Timestamp.fromMillis(Date.now()-60000)}));
  await assertFails(setDoc(doc(co,'interviews','preconfirmed'),{...invite,status:'confirmed'}));
  await assertSucceeds(getDocs(query(collection(co,'interviews'),where('companyId','==','co1'))));
  await assertSucceeds(getDocs(query(collection(ca,'interviews'),where('candidateId','==','ca1'))));
  await assertFails(getDocs(collection(co,'interviews')));
  for(const db of [stranger,other,anon])await assertFails(getDoc(doc(db,'interviews','i1')));
  const change=(db,actor,revision,data,id='i1')=>updateDoc(doc(db,'interviews',id),{...data,revision,updatedBy:actor,updatedAt:serverTimestamp()});
  await assertFails(change(co,'co1',1,{status:'confirmed'}));
  await assertFails(change(ca,'ca1',1,{status:'confirmed',startAt:proposed}));
  await assertSucceeds(change(ca,'ca1',1,{status:'confirmed'}));
  await assertFails(change(ca,'ca1',2,{status:'cancelled'}));
  await assertSucceeds(change(ca,'ca1',2,{status:'reschedule_requested',proposedAt:proposed,responseNote:'Posso neste horário.'}));
  await assertFails(change(ca,'ca1',3,{status:'confirmed',startAt:proposed,proposedAt:null}));
  await assertFails(change(co,'co1',3,{status:'confirmed',startAt:offered,proposedAt:null}));
  await assertFails(change(co,'co1',1,{status:'confirmed',startAt:proposed,proposedAt:null}));
  await assertFails(change(co,'co1',3,{status:'confirmed',startAt:proposed,proposedAt:null,candidateId:'ca2'}));
  await assertSucceeds(change(co,'co1',3,{status:'confirmed',startAt:proposed,proposedAt:null}));
  await assertSucceeds(change(co,'co1',4,{status:'pending',startAt:offered,proposedAt:null}));
  await assertSucceeds(change(ca,'ca1',5,{status:'confirmed'}));
  await assertSucceeds(change(ca,'ca1',6,{status:'rejected',proposedAt:null}));
  await assertFails(change(co,'co1',7,{status:'pending',startAt:future}));
  await assertSucceeds(setDoc(doc(co,'interviews','i2'),invite));
  await assertSucceeds(change(co,'co1',1,{status:'cancelled',proposedAt:null},'i2'));
  await assertFails(change(ca,'ca1',2,{status:'confirmed'},'i2'));
  await assertFails(deleteDoc(doc(co,'interviews','i2')));
  await env.withSecurityRulesDisabled(ctx=>updateDoc(doc(ctx.firestore(),'resumes','ca1'),{shared:false}));
  // Existing relationships remain readable; revocation only prevents new approaches.
  await assertSucceeds(setDoc(doc(ca,'conversations','3_co1_ca1','messages','m3'),{senderId:'ca1',text:'Continuamos por aqui.',createdAt:serverTimestamp()}));
  await assertFails(setDoc(doc(stranger,'conversations','3_co2_ca1'),{...chat,companyId:'co2',companyName:'Empresa B'}));
  console.log('PASS: private chats, sender identity, invitations, all response paths, stale revisions, terminal states and consent');
 }finally{await env.cleanup();}
})().catch(error=>{console.error(error);process.exitCode=1;});
