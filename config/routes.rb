Rails.application.routes.draw do

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
  #get 'sitemap', to: 'pages#sitemap'
  
  #sitemap and robots.txt
  get "sitemap.xml" => "sitemaps#index", :format => "xml", :as => :sitemap
  get '/robots.:format' => 'pages#robots'
  
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
  
  #ERROR FILES
  get 'errors/not_found'
  get 'errors/internal_server_error'  
  
  #ERROR HANDLING
  match "/404", :to => "errors#not_found", :via => :all
  match "/500", :to => "errors#internal_server_error", :via => :all
  
  #RESET PASSWORD
  resources :password_resets, only: [:new, :create, :edit, :update]
  
  #DIGEST EMAILS
  resources :digest_emails do
    collection {post :import}
    collection do
      delete 'destroy_multiple'
    end
  end
  get 'digest_emails-admin', to: 'digest_emails#admin'
  
  
  #STATES
  resources :states do
    collection {post :import}
  end
  get 'states-admin', to: 'states#admin'
  
  
  #ARTICLES
  resources :articles do
    collection {post :import}
    collection do
      delete 'destroy_multiple'
    end
  end
  post 'articles/search' => 'articles#search', as: 'search_articles'
  get 'article-admin', to: 'articles#admin'
  get 'digest', to: 'articles#digest'
  get 'send_weekly_digest', to: 'articles#send_weekly_digest'
  get 'tweet/:id', to: 'articles#tweet', as: 'tweet'
  put 'save_visit/:id', to: 'articles#save_visit', as: 'save_visit'
  put 'user_article_save/:id', to: 'articles#user_article_save', as: 'user_article_save'
  get 'send_tweet', to: 'articles#send_tweet'
  get 'update_states_categories', to: 'articles#update_states_categories'
  get 'update_article_tags', to: 'articles#update_article_tags'
  
  
  #CATEGORIES  
  resources :categories do
    collection {post :import}
    collection do
      delete 'destroy_multiple'
    end
  end
  post 'categories/search' => 'categories#search', as: 'search_categories'
  get 'category-admin', to: 'categories#admin'
  get 'sidekiqtest', to: 'categories#sidekiqtest'
  
  
  #SOURCES  
  resources :sources do
    collection {post :import}
    collection do
      delete 'destroy_multiple'
    end
  end
  post 'sources/search' => 'sources#search', as: 'search_sources'
  get 'source-admin', to: 'sources#admin'
  
  
  #HASHTAGS
  resources :hashtags do
    collection {post :import}
    collection do
      delete 'destroy_multiple'
    end
  end
  post 'hashtags/search' => 'hashtags#search', as: 'search_hashtags'
  get 'hashtag-admin', to: 'hashtags#admin'  
  
  resources :sort_options do
    collection {post :import}
    collection do
      delete 'destroy_multiple'
    end
  end
  post 'sort_options/search' => 'sort_options#search', as: 'search_sort_options'
  get 'sort_options-admin', to: 'sort_options#admin'  

end
