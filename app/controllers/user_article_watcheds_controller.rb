class UserArticleWatchedsController < ApplicationController
  options '/**' do; end
  
  before '/:id(/**)?' do
    param :id, String, required: true
  
    @ua_watched = UserArticleWatched.find!(params[:id])
  end
  
  get '/:id/article_notification_criteria' do
    json @ua_watched.article_notification_criteria
  end
  
  patch '/:id' do
    request.body.rewind
    payload = JSON.parse(request.body.read)
    ua_watched_json = as_model(payload)
    if current_user.id != ua_watched_json[:user_id]
      raise 'Only current user can update watched article'
    else
      @ua_watched.update!(ua_watched_json)
      status :ok
      json @ua_watched
    end
  end
  
  get '/:id' do
    json @ua_watched
  end
end