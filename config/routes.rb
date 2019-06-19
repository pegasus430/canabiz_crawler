Rails.application.routes.draw do

  #active admin
  devise_for :admin_users, ActiveAdmin::Devise.config

  ActiveAdmin.routes(self)
  match "/admin/admin_users/import_admin_users" => 'admin/admin_users#import_admin_users', via: [:get, :post]
  match "/admin/articles/import_articles" => 'admin/articles#import_articles', via: [:get, :post]
  match "/admin/average_prices/import_average_prices" => 'admin/average_prices#import_average_prices', via: [:get, :post]
  match "/admin/categories/import_categories" => 'admin/categories#import_categories', via: [:get, :post]
  match "/admin/dispensaries/import_dispensaries" => 'admin/dispensaries#import_dispensaries', via: [:get, :post]
  match "/admin/products/import_products" => 'admin/products#import_products', via: [:get, :post]
  
  match "/admin/dispensary_sources/:id/add_to_store" => 'admin/dispensary_sources#add_to_store', via: :post
  match "/admin/dispensary_sources/:id/delete_from_store" => 'admin/dispensary_sources#delete_from_store', via: :post
  match "/admin/dispensary_sources/:id/update_product_store" => 'admin/dispensary_sources#update_product_store', via: :put
  match "/admin/dispensary_source_products/add_to_store" => 'admin/dispensary_source_products#add_to_store', via: :post
  match "/admin/dispensary_products/add_to_store" => 'admin/dispensary_products#add_to_store', via: [:post, :patch]
  
  #ecommerce
  resources :carts
  resources :product_items
  get 'add_to_cart/:product_id/:dispensary_source_id', to: 'product_items#add_to_cart', :as => :add_to_cart
  resources :orders
  
  #SIDEKIQ Routes
  require 'sidekiq/web'
  require 'sidekiq/cron/web'
  mount Sidekiq::Web => "/background"

  #GENERAL PAGES
  root 'pages#home'

  get 'admin', to: 'pages#admin'
  get 'search', to: 'pages#search'
  get 'save_email', to: 'pages#save_email'
  get 'unsubscribe', to: 'pages#unsubscribe'
  
  get 'contact_us', to: 'pages#contact_us'
  get 'submit_contact_form', to: 'pages#submit_contact_form'
  
  get 'feedback', to: 'pages#feedback'
  get 'submit_feedback_form', to: 'pages#submit_feedback_form'
  
  get 'privacy_policy', to: 'pages#privacy_policy'
  get 'terms_conditions', to: 'pages#terms_conditions'
  get 'about', to: 'pages#about'
  
  #sitemap
  get "sitemap.xml" => "sitemaps#index", :format => "xml", :as => :sitemap
  
  #DIFF STYLING
  get 'test', to: 'diff_layouts#test'
  
  #LOGIN AND LOGOUT
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  #USER
  get 'signup', to: 'users#new'
  resources :users, except: [:new] do 
    collection do
      delete 'destroy_multiple'
    end
  end
  get 'users-admin', to: 'users#admin'
  get 'change_password/:id', to: 'users#change_password', as: 'change_password'
  get 'submit_password_change', to: 'users#submit_password_change' 
  
  put 'user_source_save/:source_id', to: 'users#user_source_save', as: 'user_source_save'
  put 'user_category_save/:category_id', to: 'users#user_category_save', as: 'user_category_save'
  put 'user_state_save/:state_id', to: 'users#user_state_save', as: 'user_state_save'
  
  #RESET PASSWORD
  resources :password_resets, only: [:new, :create, :edit, :update]
  
  #ERROR FILES
  get 'errors/not_found'
  get 'errors/internal_server_error'
  get 'errors/application_error'
  
  #ERROR HANDLING
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all
  match "/503", :to => "errors#application_error", :via => :all
  
  resources :blog
  resources :categories
  resources :sources
  resources :average_prices
  resources :vendor_products
  resources :dispensary_sources
  resources :dispensary_source_products
  resources :dsp_prices
  resources :dispensary_products

  #ARTICLES
  resources :articles
  get 'digest', to: 'articles#digest'
  get 'send_weekly_digest', to: 'articles#send_weekly_digest'
  get 'tweet/:id', to: 'articles#tweet', as: 'tweet'
  put 'save_visit/:id', to: 'articles#save_visit', as: 'save_visit'
  put 'user_article_save/:id', to: 'articles#user_article_save', as: 'user_article_save'
  get 'send_tweet', to: 'articles#send_tweet'
  get 'update_states_categories', to: 'articles#update_states_categories'
  get 'update_article_tags', to: 'articles#update_article_tags'
  
  #PRODUCTS
  resources :products
  post "products_refine_index", to: "products#refine_index"
  get "products_refine_index", to: "products#refine_index"
  post 'products/:id/change_state' => 'products#change_state', as: 'change_state_product'
  
  #STATES
  resources :states
  post 'states/:id/refine_products' => 'states#refine_products', as: 'refine_state_products'

  #VENDORS
  resources :vendors
  post 'vendors/refine_index' => 'vendors#refine_index', as: 'refine_vendor_index'

  #DISPENSARIES
  resources :dispensaries
  post 'dispensaries/refine_index' => 'dispensaries#refine_index', as: 'refine_dispensary_index'

end
