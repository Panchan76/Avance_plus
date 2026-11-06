// Run only against the local emulator, never a production project.
const fs = require('node:fs');
const path = require('node:path');
const {initializeTestEnvironment, assertSucceeds, assertFails} = require('@firebase/rules-unit-testing');
const {doc, collection, setDoc, getDoc, getDocs, query, where, updateDoc, serverTimestamp} = require('firebase/firestore');
(async () => {
  const env = await initializeTestEnvironment({projectId: 'demo-avance-catalog',
    firestore: {host: '127.0.0.1', port: 8089, rules: fs.readFileSync(path.join(__dirname, '../firestore.rules'), 'utf8')}});
  try {
    await env.clearFirestore();
    await env.withSecurityRulesDisabled(async context => {
      const db = context.firestore();
      for (const [uid, role] of [['candidate-a','candidate'],['candidate-b','candidate'],['company-a','company'],['company-b','company']]) {
        await setDoc(doc(db,'users',uid), {uid,role,...(role==='company'?{cnpjStatus:'active'}:{}),email: `${uid}@example.com`,name: uid});
      }
      await setDoc(doc(db,'career_roles','approved-custom'), {title:'Cargo aprovado',description:'Atividades aprovadas',status:'approved',requestedBy:'company-a'});
    });
    const candidate = env.authenticatedContext('candidate-a', {email:'candidate-a@example.com'}).firestore();
    const other = env.authenticatedContext('candidate-b').firestore();
    const company = env.authenticatedContext('company-a').firestore();
    const otherCompany = env.authenticatedContext('company-b').firestore();
    const anon = env.unauthenticatedContext().firestore();
    const request = {title:'Novo cargo',description:'Descrição das atividades',requestedBy:'company-a',status:'pending',createdAt:serverTimestamp()};
    await assertSucceeds(setDoc(doc(company,'career_roles','new-role'),request));
    await assertFails(setDoc(doc(company,'career_roles','self-approved'),{...request,status:'approved'}));
    await assertFails(setDoc(doc(candidate,'career_roles','candidate-request'),{...request,requestedBy:'candidate-a'}));
    await assertFails(updateDoc(doc(company,'career_roles','new-role'),{status:'approved'}));
    await assertFails(getDoc(doc(otherCompany,'career_roles','new-role')));
    await assertFails(getDoc(doc(candidate,'career_roles','new-role')));
    await assertSucceeds(getDocs(query(collection(company,'career_roles'),where('requestedBy','==','company-a'))));
    await assertSucceeds(getDocs(query(collection(candidate,'career_roles'),where('status','==','approved'))));
    await assertFails(getDocs(collection(candidate,'career_roles')));
    const resume = {uid:'candidate-a',name:'Pessoa candidata',email:'pessoa@example.com',phone:'',city:'Recife / PE',
      summary:'Minha apresentação',experience:'Minha experiência',education:'Meus cursos',skills:'Minhas habilidades',
      roleIds:['jardineiro','approved-custom'],shared:true,updatedAt:serverTimestamp()};
    await assertSucceeds(setDoc(doc(candidate,'resumes','candidate-a'),resume));
    await assertFails(setDoc(doc(candidate,'resumes','candidate-b'),{...resume,uid:'candidate-b'}));
    await assertFails(setDoc(doc(company,'resumes','company-a'),{...resume,uid:'company-a'}));
    await assertFails(updateDoc(doc(candidate,'resumes','candidate-a'),{roleIds:['new-role'],updatedAt:serverTimestamp()}));
    await assertFails(updateDoc(doc(candidate,'resumes','candidate-a'),{roleIds:['unknown-role'],updatedAt:serverTimestamp()}));
    await assertFails(updateDoc(doc(candidate,'resumes','candidate-a'),{admin:true,updatedAt:serverTimestamp()}));
    await assertFails(updateDoc(doc(candidate,'users','candidate-a'),{role:'company'}));
    await assertSucceeds(getDocs(query(collection(company,'resumes'),where('shared','==',true),where('roleIds','array-contains','jardineiro'))));
    await assertFails(getDocs(collection(company,'resumes')));
    await assertFails(getDoc(doc(other,'resumes','candidate-a')));
    await assertFails(getDoc(doc(anon,'resumes','candidate-a')));
    await assertSucceeds(getDoc(doc(candidate,'resumes','candidate-a')));
    await assertSucceeds(updateDoc(doc(candidate,'resumes','candidate-a'),{shared:false,updatedAt:serverTimestamp()}));
    await assertFails(getDoc(doc(company,'resumes','candidate-a')));
    const hidden = await assertSucceeds(getDocs(query(collection(company,'resumes'),where('shared','==',true),where('roleIds','array-contains','jardineiro'))));
    if (!hidden.empty) throw Error('Private resume remained visible');
    console.log('PASS: moderation, identity, queries, role validation and consent revocation');
  } finally { await env.cleanup(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
