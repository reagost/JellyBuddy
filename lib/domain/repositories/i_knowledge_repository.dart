abstract class IKnowledgeRepository {
  Future<KnowledgeDocument?> getDocument(String documentId);
  Future<List<KnowledgeDocument>> searchDocuments(String query);
}

class KnowledgeDocument {
  final String id;
  final String title;
  final String content;
  final String domain;
  final String level;

  const KnowledgeDocument({
    required this.id,
    required this.title,
    required this.content,
    required this.domain,
    required this.level,
  });
}
