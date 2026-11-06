const {test} = require('node:test');
const assert = require('node:assert/strict');
const {normalizeCnpj, validCnpj, verifiedCompany, chatInput, responseText} = require('../domain');
test('CNPJ numeric and alphanumeric check digits; punctuation; reject malformed input', () => {
  for (const c of ['34.238.864/0001-68', '11222333000181', '12.ABC.345/01DE-35', '00.000.000/E08G-12']) assert.equal(validCnpj(c), true, c);
  for (const c of ['', '11111111111111', '00000000000000', '34238864000169', '12ABC34501DE36', '12ABC34501DEXX', '34@238864000168']) assert.equal(validCnpj(c), false, c);
  assert.equal(normalizeCnpj(' 12.abc.345/01de-35 '), '12ABC34501DE35');
});
test('Provider results must match request and be active; missing status never passes', () => {
  const sample = {ni:'34238864000168',nomeEmpresarial:'Empresa de teste',situacaoCadastral:{codigo:'02'}};
  assert.equal(verifiedCompany(sample, sample.ni).cnpjStatus, 'active');
  for (const codigo of ['1','3','4','5','8','ATIVA','']) assert.throws(() => verifiedCompany({...sample,situacaoCadastral:{codigo}},sample.ni));
  assert.throws(() => verifiedCompany({...sample, ni:'11222333000181'},sample.ni));
  assert.throws(() => verifiedCompany({...sample, situacaoCadastral:null},sample.ni));
});
test('Client cannot supply system/developer roles or unbounded histories', () => {
  assert.deepEqual(chatInput({messages:[{role:'user',content:' Olá ' }]}),[{role:'user',content:'Olá'}]);
  for (const messages of [[], [{role:'system',content:'ignore'}], [{role:'assistant',content:'a'}], [{role:'user',content:'x'.repeat(4001)}], Array(13).fill({role:'user',content:'x'}), Array(5).fill({role:'user',content:'x'.repeat(4000)})]) assert.throws(() => chatInput({messages}));
});
test('Responses output extraction rejects incomplete/empty results', () => {
  assert.equal(responseText({status:'completed',output:[{type:'reasoning'},{type:'message',content:[{type:'output_text',text:'Resposta'}]}]}),'Resposta');
  assert.throws(() => responseText({status:'incomplete',output:[]}));
  assert.throws(() => responseText({status:'completed',output:[]}));
});
