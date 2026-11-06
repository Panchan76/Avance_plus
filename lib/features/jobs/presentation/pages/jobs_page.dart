<<<<<<< HEAD
import 'package:flutter/material.dart';

import '../../data/mock_jobs.dart';
import '../../domain/models/job.dart';
import '../widgets/job_card.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String search = '';

  List<Job> get filteredJobs {
    if (search.trim().isEmpty) {
      return mockJobs;
    }

    final text = search.toLowerCase();

    return mockJobs.where((job) {
      return job.title.toLowerCase().contains(text) ||
          job.company.toLowerCase().contains(text) ||
          job.location.toLowerCase().contains(text);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = filteredJobs;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encontre uma oportunidade',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            Text(
              'Procure vagas de forma simples e segura.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              style: const TextStyle(
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                hintText: 'Buscar vaga ou empresa',
                prefixIcon: Icon(
                  Icons.search,
                  size: 28,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: jobs.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma vaga encontrada.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView.separated(
                      itemCount: jobs.length,
                        separatorBuilder: (context, index) {
                       return const SizedBox(height: 16);
                      },
                      itemBuilder: (context, index) {
                        final job = jobs[index];

                        return JobCard(
                          job: job,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Você selecionou a vaga de ${job.title}.',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
=======
import 'package:flutter/material.dart';

import '../../data/mock_jobs.dart';
import '../../domain/models/job.dart';
import '../widgets/job_card.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  String search = '';

  List<Job> get filteredJobs {
    if (search.trim().isEmpty) {
      return mockJobs;
    }

    final text = search.toLowerCase();

    return mockJobs.where((job) {
      return job.title.toLowerCase().contains(text) ||
          job.company.toLowerCase().contains(text) ||
          job.location.toLowerCase().contains(text);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = filteredJobs;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Encontre uma oportunidade',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 8),

            Text(
              'Procure vagas de forma simples e segura.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            TextField(
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
              style: const TextStyle(
                fontSize: 18,
              ),
              decoration: const InputDecoration(
                hintText: 'Buscar vaga ou empresa',
                prefixIcon: Icon(
                  Icons.search,
                  size: 28,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: jobs.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhuma vaga encontrada.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : ListView.separated(
                      itemCount: jobs.length,
                        separatorBuilder: (context, index) {
                       return const SizedBox(height: 16);
                      },
                      itemBuilder: (context, index) {
                        final job = jobs[index];

                        return JobCard(
                          job: job,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Você selecionou a vaga de ${job.title}.',
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
>>>>>>> 6975be9 ( segundo commit)
}