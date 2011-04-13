Stories::Application.routes.draw do |map|
  resources :stories do
    member do
      get :more_info
      get :export
      get :export_done
    end
    collection do
      get :import
      get :info
      get :quit
      get :export
      get :export_done
    end
  end

  root :to => "stories#index"

  resources :collections
end
