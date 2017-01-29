Rails.application.routes.draw do

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
  
  #RESET PASSWORD
  resources :password_resets, only: [:new, :create]
  
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
  get 'tweet/:id', to: 'articles#tweet', as: 'tweet'
  put 'save_visit/:id', to: 'articles#save_visit', as: 'save_visit'
  put 'user_article_save/:id', to: 'articles#user_article_save', as: 'user_article_save'
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
