Rails.application.routes.draw do
  namespace :api do
    resources :mentions, only: :create
  end
end
