class ArticleParseWorker < Worker::Base
  def perform(crawl_history_id)
    history        = CrawlHistory.find!(crawl_history_id)
    merchant       = history.crawl_session.merchant
    cache_filename = history.index_page.cache_filename
    cache_dir      = "./tmp/cache/crawl/#{merchant.id}"
    cache_filepath = '%s/%s' % [cache_dir, cache_filename]
    
    cache_file_content = File.open(cache_filepath, 'rb') { |file| file.read }
    body               = read_cache_file(cache_file_content,
                                         history.content_encoding)
    
    item_css = merchant.metadatum.item_css
    document = Nokogiri::HTML(body, nil, 'utf-8')
    document.css(item_css).each do |it|
      begin
        attrs      = merchant.attrs_from_node(it)
        article_id = attrs[:id]
        
        raise 'No valid id was found in parsed article attributes' unless article_id =~ /[a-z]{3}:[a-z0-9]+/
        
        if article = Article.find?(article_id)
          # Bust the (serializer) cache and touch the record
          article.update!(attrs.merge(updated_at: Time.now.utc.iso8601))
          # ArticleUpdatedWorker.perform_async(article.id)
          CrawlHistoryArticle.upsert!(crawl_history: history,
                                      article:       article,
                                      status:        :updated)
          ArticleUpdatedWorker.perform_async(article.id)
          history.updated_articles_count += 1
          logger.info { 'Article %s created...' % article_id }
        else
          article = Article.create!(attrs.merge(merchant: merchant))
          CrawlHistoryArticle.create!(crawl_history: history,
                                      article:       article,
                                      status:        :created)
          ArticleCreatedWorker.perform_async(article.id)
          history.created_articles_count += 1
          logger.info { 'Article %s updated...' % article_id }
        end
        
        article.update_price_history!
        history.items_count += 1
      rescue Exception => ex
        history.invalid_items_count += 1
        
        logger.warn { 'Failed creating article: %s' % ex.message }
        logger.warn { attrs }
        logger.debug { it.to_html }
      else
      ensure
        history.save
        # logger.debug { attrs }
      end
    end
    
    logger.info 'Finished'
  end
  
  private
  
  def read_cache_file(body, encoding = nil)
    RestClient::Request.decode(encoding, body)
  end
end