Rails.application.routes.draw do
  devise_for :users, controllers: {registrations: 'users/registrations'}

  # For lavta
  resources :statuses, only: [:index, :create, :show]
  delete '/statuses' => 'statuses#destroy'
  
  # twitter
  scope :document_analyses, controller: 'analysis', as: 'analyses' do
    get :task_page
    post :execute_task
  end

  # hook for mailchimp
  post '/process_email' => 'email#transform'
  post '/reanalyze_email' => 'email#reanalyze'
  
  post '/ajax_api' => 'ajax#multiplex'
  get '/ajax_api' => 'ajax#multiplex'
  scope :twitter, as: 'twitter', controller: 'twitters' do
    get :authorize_twitter
    get :set_twitter_token    

    get :schedule
    post :schedule
    
    get :index
    get :input_handle
    post :twitter_call
    post :batch_call
    
    get "/analysis(/:handle)", action: :analyze, as: :profile_analysis
    get '/feed(/:handle)', action: :feed, as: :feed
  end
  
  # twitter
  resources 'redirect_maps', path: 'r', only: [:show]
  
  # Admin
  require 'sidekiq/web'
  #authenticate :admin, lambda { |u| u.is_a? Admin } do
  mount Sidekiq::Web => '/sidekiq_ui'
  #end
end
