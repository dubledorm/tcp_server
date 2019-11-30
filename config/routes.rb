Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api do
    get 'health_check', to: 'api#health_check'
    get 'restart', to: 'api#restart'
    get 'start_pair', to: 'api#start_pair'
  end

  namespace :test do
    post 'health_check', to: 'api#test_health_check'
  end
end
