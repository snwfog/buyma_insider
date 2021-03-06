class IndexPagesController < ApplicationController
  options '/**' do
  end

  before '/:id(/**)?' do
    param :id, String, required: true

    @index_page = IndexPage
                    .includes(:index_pages)
                    .find(params[:id])
  end

  post '/:id/_refresh' do
    if IndexPageCrawlWorker.perform_async(index_page_id:         @index_page.id,
                                          use_web_cache:         true,
                                          perform_async_parsing: true)
      status :created
      json data: { type: 'index_pages_refresh',
                   id:   SecureRandom.hex(4) }
    else
      status :conflict and halt
    end
  end

  get '/:id' do
    json @index_page
  end
end
