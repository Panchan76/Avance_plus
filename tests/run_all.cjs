const {execFileSync}=require('node:child_process');
const path=require('node:path');
for(const file of ['firestore_rules.cjs','communication_rules.cjs','profile_rules.cjs'])execFileSync(process.execPath,[path.join(__dirname,file)],{stdio:'inherit'});
