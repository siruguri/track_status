Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: 'users/registrations'}

  resources :statuses, only: [:index, :create, :show]
  resources :job_records, only: [:index]
  
  delete '/statuses' => 'statuses#destroy'
  
  # Various things this app does
  scope :document_analyses, controller: 'analysis', as: 'analyses' do
    get :task_page
    post :execute_task
  end
  
  post '/process_email' => 'email#transform'
  post '/reanalyze_email' => 'email#reanalyze'
  
  get '/reddits/userinfo/:user' => 'reddits#userinfo'
  
  scope 'readability', as: 'readability', controller: 'readability' do
    get :run_scrape
    get :list, action: :list_articles
    get :tag_words
    post :tag_article
  end
  
  post '/ajax_api' => 'ajax#multiplex'
  scope :twitter, as: 'twitter', controller: 'twitters' do
    get :authorize_twitter
    get :set_twitter_token    

    get :schedule
    post :schedule
    
    get :index
    get :input_handle
    post :twitter_call
    post :batch_call
    get '/handle/:handle', action: :show, as: :handle
    get '/feed(/:handle)', action: :feed, as: :feed
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
