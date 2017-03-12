require 'active_model_serializers/serialization_context'

class MerchantSerializer < ActiveModel::Serializer
  cache key: :merchant, expires_in: 1.week

  has_many :articles do
    link :related, proc { "/merchants/#{object.id}/articles" }
  end
  
  has_many :crawl_sessions do
    link :related, proc { "/merchants/#{object.id}/crawl_sessions" }
  end
  
  has_one :metadatum do
    include_data true
    link :related, proc { "/merchants/#{object.id}/metadatum" }
  end
  
  # When this is declared, the association is automatically fetched...
  # has_many :articles do
  #   link :test, 'test/lol'
  # end
  
  attributes :name,
             :total_articles_count,
             :last_sync_at
  
  # These methods are here is okay..
  # The question to ask is, do we care about these values on model and backend?
  # If its only for UI display, then serializer is enough
  # If its used for business logic, then should go to the model
  def total_articles_count
    object.articles.count
  end
  
  def last_sync_at
    if session = object.crawl_sessions.finished.first
      session.finished_at
    end
  end
end