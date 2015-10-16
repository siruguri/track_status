Rails.application.routes.draw do
  devise_for :users

  resources :statuses, only: [:index, :create, :show]
  resources :job_records, only: [:index]
  
  delete '/statuses' => 'statuses#destroy'
  
  post '/process_email' => 'email#transform'
  post '/reanalyze_email' => 'email#reanalyze'
  
  # Various things this app does
  get '/reddits/userinfo/:user' => 'reddits#userinfo'
  get '/readability/run_scrape' => 'readability#run_scrape'
  get '/readability/list' => 'readability#list_articles'
  get '/readability/tag_words' => 'readability#tag_words'
  post '/readability/tag_article' => 'readability#tag_article'
  
  resources 'channel_posts', only: [:index, :create, :new]
  resources 'account_entries', only: [:new, :create] do
    collection do
      get 'tag', action: 'generate_tags'
      post 'update_tag'
    end
  end
  
  resources 'redirect_maps', path: 'r', only: [:show]
  
  # Admin
  require 'sidekiq/web'
  #authenticate :admin, lambda { |u| u.is_a? Admin } do
  mount Sidekiq::Web => '/sidekiq_ui'
  #end
end
