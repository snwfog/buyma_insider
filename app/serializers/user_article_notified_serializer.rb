class UserArticleNotifiedSerializer < ActiveModel::Serializer
  belongs_to :article do
    include_data(true)
    # link :related, proc { "/articles/#{object.article_id}" }
  end
  
  belongs_to :article_notification_criteria do
    include_data(true)
    # link :related, proc {
    #   "/user_article_notifieds/#{object.id}/article_notification_criteria" }
  end
  
  attributes :id,
             :read_at,
             :updated_at,
             :created_at

  class ArticleSerializer < ActiveModel::Serializer
    cache key: :article, expires_in: 24.hours

    attributes :id,
               :name,
               :description,
               :price,
               :link,
               # :price_summary,
               # :synced_at,
               :created_at,
               :updated_at
  end
end