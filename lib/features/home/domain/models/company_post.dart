<<<<<<< HEAD
enum PostType {
  job,
  event,
  tip,
  announcement,
}

class CompanyPost {
  final String id;
  final String companyName;
  final String title;
  final String content;
  final String publishedAt;
  final String? location;
  final PostType type;
  final bool verified;

  const CompanyPost({
    required this.id,
    required this.companyName,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.type,
    this.location,
    this.verified = false,
  });
=======
enum PostType {
  job,
  event,
  tip,
  announcement,
}

class CompanyPost {
  final String id;
  final String companyName;
  final String title;
  final String content;
  final String publishedAt;
  final String? location;
  final PostType type;
  final bool verified;

  const CompanyPost({
    required this.id,
    required this.companyName,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.type,
    this.location,
    this.verified = false,
  });
>>>>>>> 6975be9 ( segundo commit)
}