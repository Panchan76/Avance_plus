import 'package:flutter/material.dart';

import 'package:avance_plus/features/home/data/mock_posts.dart';
import 'package:avance_plus/features/home/presentation/wingets/company_post_card.dart'; 

class HomePage extends StatelessWidget {
  final VoidCallback onViewJobs;

  const HomePage({
    super.key,
    required this.onViewJobs,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
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
                    'Avance+',
                    style: Theme.of(context)
                        .textTheme
                        .headlineLarge
                        ?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Olá! Que bom ter você aqui.',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Acompanhe novidades, oportunidades e informações das empresas.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onViewJobs,
                      icon: const Icon(
                        Icons.search,
                      ),
                      label: const Text(
                        'Procurar vagas',
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'Publicações',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Veja o que as empresas estão compartilhando.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              30,
            ),
            sliver: SliverList.separated(
              itemCount: mockPosts.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 18);
              },
              itemBuilder: (context, index) {
                final post = mockPosts[index];

                return CompanyPostCard(
                  post: post,
                  onViewJob: onViewJobs,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}