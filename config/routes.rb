Rails.application.routes.draw do

  #GENERAL PAGES
  root 'pages#home'
  get 'admin', to: 'pages#admin'
  get 'search', to: 'pages#search'
  get 'save_email', to: 'pages#save_email'
  get 'unsubscribe', to: 'pages#unsubscribe'
  
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
  get 'news', to: 'states#news' #the state news page
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
  get 'tweet/:id', to: 'articles#tweet', as: 'tweet'
  get 'send_tweet', to: 'articles#send_tweet'
  
  
  #CATEGORIES  
  resources :categories do
    collection {post :import}
    collection do
      delete 'destroy_multiple'
    end
  end
  post 'categories/search' => 'categories#search', as: 'search_categories'
  get 'category-admin', to: 'categories#admin'
  get 'python', to: 'categories#python'
  
  
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
