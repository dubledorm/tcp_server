Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    get 'health_check', to: 'api#health_check'
    put 'start_pair', to: 'api#start_pair'
    put 'stop_pair', to: 'api#stop_pair'
  end
end
