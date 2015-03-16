Rails.application.routes.draw do

  resources :statuses, only: [:index, :create, :show]
  post '/bindb_add/:bin' => 'bindb#add'
  get '/bindb_index' => 'bindb#index'

  post '/process_email' => 'email#transform'

  post '/timeout' => 'timeout#infinite_loop'
end
