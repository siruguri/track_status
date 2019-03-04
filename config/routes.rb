Rails.application.routes.draw do
  devise_for :users
  get 'fetch_mtc_data' => 'mtc#fetch_and_mail'

  # For lavta, primarily
  resources :statuses, only: [:index, :create, :show]
  delete '/statuses' => 'statuses#destroy'
  
  # hook for mailchimp etc.
  scope '/', controller: :email do
    post :transform, path: 'process_email'
    post :reanalyze, path: 'reanalyze_email'
    get :send_it, path: 'send_mail'
  end
  
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
