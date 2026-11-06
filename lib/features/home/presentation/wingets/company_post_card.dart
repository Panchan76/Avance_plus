import 'package:flutter/material.dart';

import 'package:avance_plus/features/home/domain/models/company_post.dart';

class CompanyPostCard extends StatelessWidget {
  final CompanyPost post;
  final VoidCallback? onViewJob;

  const CompanyPostCard({
    super.key,
    required this.post,
    this.onViewJob,
  });

  IconData get postIcon {
    switch (post.type) {
      case PostType.job:
        return Icons.work_outline;

      case PostType.event:
        return Icons.event_outlined;

      case PostType.tip:
        return Icons.lightbulb_outline;

      case PostType.announcement:
        return Icons.campaign_outlined;
    }
  }

  String get postTypeName {
    switch (post.type) {
      case PostType.job:
        return 'Vaga';

      case PostType.event:
        return 'Evento';

      case PostType.tip:
        return 'Dica';

      case PostType.announcement:
        return 'Comunicado';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Publicação da empresa ${post.companyName}',
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: Color(0xFFE4E8EE),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      post.companyName.substring(0, 1),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.companyName,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium,
                              ),
                            ),

                            if (post.verified) ...[
                              const SizedBox(width: 6),
                              Icon(
                                Icons.verified,
                                size: 20,
                                color:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 3),

                        Text(
                          post.publishedAt,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      postIcon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      postTypeName,
                      style:
                          Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                post.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 10),

              Text(
                post.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              if (post.location != null) ...[
                const SizedBox(height: 18),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        post.location!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],

              if (post.type == PostType.job) ...[
                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onViewJob,
                    icon: const Icon(
                      Icons.work_outline,
                    ),
                    label: const Text(
                      'Ver oportunidade',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
} 