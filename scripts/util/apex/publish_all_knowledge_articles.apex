for (Knowledge__kav article : [
    SELECT KnowledgeArticleId
    FROM Knowledge__kav
    WHERE PublishStatus IN ('Draft') AND IsLatestVersion = TRUE
    LIMIT 50
]) {
    KbManagement.PublishingService.publishArticle(article.KnowledgeArticleId, true);
}
