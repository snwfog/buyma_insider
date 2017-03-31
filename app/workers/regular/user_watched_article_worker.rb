class UserWatchedArticleWorker < Worker::Base
  def perform(article_id)
    article = Article
                .eager_load(:user_watched_articles)
                .find!(article_id)
    
    today = Time.now.utc.to_date
    article.user_watched_articles.each do |watched_article|
      if watched_article.all_criteria_applies?
        watched_article.notify!(today)
      end
    end
  end
end