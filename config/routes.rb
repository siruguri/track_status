Rails.application.routes.draw do

  resources :statuses, only: [:index, :create, :show]
  delete '/statuses' => 'statuses#destroy'
  
  post '/bindb/add/:bin' => 'bindb#add'
  get '/bindb/index' => 'bindb#index'
  get '/bindb/dump' => 'bindb#dump'

  post '/process_email' => 'email#transform'

  get '/reddits/userinfo/:user' => 'reddits#userinfo'  
end
