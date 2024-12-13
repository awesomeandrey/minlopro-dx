for (Knowledge__kav article : [
    SELECT KnowledgeArticleId, PublishStatus
    FROM Knowledge__kav
    WHERE IsLatestVersion = TRUE
    LIMIT 50
]) {
    switch on article.PublishStatus {
        when 'Online' {
            KbManagement.PublishingService.archiveOnlineArticle(article.KnowledgeArticleId, null);
            KbManagement.PublishingService.deleteArchivedArticle(article.KnowledgeArticleId);
        }
        when 'Draft' {
            KbManagement.PublishingService.deleteDraftArticle(article.KnowledgeArticleId);
        }
        when else {
            KbManagement.PublishingService.deleteArchivedArticle(article.KnowledgeArticleId);
        }
    }
}
