'use strict';
function normalizeCnpj(value) {
  return typeof value === 'string' ? value.trim().toUpperCase().replace(/[.\/\-\s]/g, '') : '';
}
function validCnpj(value) {
  const s = normalizeCnpj(value);
  if (!/^[A-Z0-9]{12}[0-9]{2}$/.test(s) || /^(.)\1{13}$/.test(s)) return false;
  const digit = (base) => {
    let sum = 0, weight = 2;
    for (let i = base.length - 1; i >= 0; i--) {
      sum += (base.charCodeAt(i) - 48) * weight;
      weight = weight === 9 ? 2 : weight + 1;
    }
    const r = sum % 11;
    return String(r < 2 ? 0 : 11 - r);
  };
  return digit(s.slice(0, 12)) === s[12] && digit(s.slice(0, 13)) === s[13];
}
function verifiedCompany(data, expectedCnpj) {
  if (!data || normalizeCnpj(data.ni) !== expectedCnpj) throw new Error('provider-shape');
  const status = data.situacaoCadastral ?? data.situacao_cadastral;
  if (!status || !Object.hasOwn(status, 'codigo')) throw new Error('provider-shape');
  if (!['2', '02'].includes(String(status.codigo))) throw new Error('inactive');
  const legalName = data.nomeEmpresarial ?? data.nome_empresarial;
  if (typeof legalName !== 'string' || !legalName.trim() || legalName.length > 250) throw new Error('provider-shape');
  return {cnpj: expectedCnpj, legalName: legalName.trim(), cnpjStatus: 'active', cnpjSource: 'serpro'};
}
function chatInput(data) {
  if (!data || !Array.isArray(data.messages) || data.messages.length < 1 || data.messages.length > 12) throw new Error('invalid-messages');
  let total = 0;
  const input = data.messages.map(m => {
    if (!m || !['user', 'assistant'].includes(m.role) || typeof m.content !== 'string' || !m.content.trim() || m.content.length > 4000) throw new Error('invalid-messages');
    total += m.content.length;
    return {role: m.role, content: m.content.trim()};
  });
  if (total > 16000 || input.at(-1).role !== 'user') throw new Error('invalid-messages');
  return input;
}
function responseText(data) {
  if (data?.status !== 'completed') throw new Error('incomplete');
  const text = (data.output ?? []).filter(i => i.type === 'message')
    .flatMap(i => i.content ?? []).filter(c => c.type === 'output_text').map(c => c.text).join('\n').trim();
  if (!text) throw new Error('empty-response');
  return text;
}
module.exports = {normalizeCnpj, validCnpj, verifiedCompany, chatInput, responseText};
