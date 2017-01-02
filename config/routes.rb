Rails.application.routes.draw do
  devise_for :users
  
  # For lavta, primarily
  resources :statuses, only: [:index, :create, :show]
  delete '/statuses' => 'statuses#destroy'
  
  # hook for mailchimp etc.
  post '/process_email' => 'email#transform'
  post '/reanalyze_email' => 'email#reanalyze'
  
  post '/ajax_api' => 'ajax#multiplex'
  get '/ajax_api' => 'ajax#multiplex'

  resources :status_records, only: [:create]
  
  # Admin
  require 'sidekiq/web'
  #authenticate :admin, lambda { |u| u.is_a? Admin } do
  mount Sidekiq::Web => '/sidekiq_ui'
  #end

  root to: 'statuses#index'
end
