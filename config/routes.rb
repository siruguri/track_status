Rails.application.routes.draw do
  devise_for :users

  resources :statuses, only: [:index, :create, :show]
  resources :job_records, only: [:index]
  
  delete '/statuses' => 'statuses#destroy'
  
  # Various things this app does
  scope :document_analyses, controller: 'analysis' do
    get :task_page
    post :execute_task
  end
  
  post '/process_email' => 'email#transform'
  post '/reanalyze_email' => 'email#reanalyze'
  
  get '/reddits/userinfo/:user' => 'reddits#userinfo'
  
  get '/readability/run_scrape' => 'readability#run_scrape'
  get '/readability/list' => 'readability#list_articles'
  get '/readability/tag_words' => 'readability#tag_words'
  post '/readability/tag_article' => 'readability#tag_article'

  scope :twitter, as: 'twitter', controller: 'twitters' do
    get :set_twitter_token
    get :input_handle
    post :twitter_call
    get '/:handle', action: :show
  end
  
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
