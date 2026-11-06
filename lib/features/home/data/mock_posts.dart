import 'package:avance_plus/features/home/domain/models/company_post.dart';

const List<CompanyPost> mockPosts = [
  CompanyPost(
    id: '1',
    companyName: 'Clínica Vida',
    title: 'Estamos contratando!',
    content:
        'Estamos procurando uma pessoa para atuar como recepcionista em nossa clínica. A vaga é de meio período e buscamos alguém comunicativo e organizado.',
    publishedAt: 'Há 2 horas',
    location: 'Americana - SP',
    type: PostType.job,
    verified: true,
  ),

  CompanyPost(
    id: '2',
    companyName: 'Mercado Central',
    title: 'Oportunidade para atendente',
    content:
        'Temos uma nova oportunidade para atendimento ao público. Experiência anterior é bem-vinda, mas não é obrigatória.',
    publishedAt: 'Hoje',
    location: 'Americana - SP',
    type: PostType.job,
    verified: true,
  ),

  CompanyPost(
    id: '3',
    companyName: 'Instituto Recomeçar',
    title: 'Encontro sobre recolocação profissional',
    content:
        'Nesta sexta-feira teremos um encontro gratuito sobre currículo, entrevistas e retorno ao mercado de trabalho.',
    publishedAt: 'Ontem',
    location: 'Santa Bárbara d\'Oeste - SP',
    type: PostType.event,
    verified: true,
  ),

  CompanyPost(
    id: '4',
    companyName: 'Conecta Serviços',
    title: 'Dica para entrevistas',
    content:
        'Antes de uma entrevista, relembre suas experiências profissionais e pense em situações em que você resolveu problemas ou ajudou outras pessoas.',
    publishedAt: 'Há 2 dias',
    type: PostType.tip,
    verified: true,
  ),
];