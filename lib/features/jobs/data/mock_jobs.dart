import '../domain/models/job.dart';

const List<Job> mockJobs = [
  Job(
    id: '1',
    title: 'Recepcionista',
    company: 'Clínica Vida',
    location: 'Americana - SP',
    description:
        'Atendimento aos clientes, organização da recepção e apoio administrativo.',
    workType: 'Meio período',
    salary: 'R\$ 1.500',
  ),
  Job(
    id: '2',
    title: 'Atendente',
    company: 'Mercado Central',
    location: 'Americana - SP',
    description:
        'Atendimento aos clientes e auxílio na organização do estabelecimento.',
    workType: 'Meio período',
    salary: 'R\$ 1.650',
  ),
  Job(
    id: '3',
    title: 'Auxiliar Administrativo',
    company: 'Empresa Horizonte',
    location: 'Santa Bárbara d\'Oeste - SP',
    description:
        'Auxílio com documentos, atendimento telefônico e organização administrativa.',
    workType: 'Presencial',
    salary: 'R\$ 1.800',
  ),
  Job(
    id: '4',
    title: 'Consultor de Atendimento',
    company: 'Conecta Serviços',
    location: 'Remoto',
    description:
        'Atendimento aos clientes através de telefone e canais digitais.',
    workType: 'Remoto',
    salary: 'R\$ 1.700',
  ),
];