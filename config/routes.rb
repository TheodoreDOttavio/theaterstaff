Rails.application.routes.draw do

resources :theaters,
  :performances,
  :products#,
  # :availables,
  # :distributeds
#


resources :users do
  member do
    get 'txtalert'
    get 'emailalert'
  end
end
match '/getautopass', to: 'users#getautopassword', via: 'get'

match '/signup', to: 'users#new', via: 'get'
match '/signin',  to: 'sessions#new', via: 'get'
match '/signout', to: 'sessions#destroy', via: 'get'
resources :sessions, only: [:new, :create, :destroy]

match '/help', to: 'static_pages#help', via: 'get'
match '/home', to: 'static_pages#home', via: 'get'
match '/about', to: 'static_pages#about', via: 'get'
match '/contact', to: 'static_pages#contact', via: 'get'

root  'static_pages#home'

# match '/theaters', to: 'theaters#show', via: 'get'
# match '/performances', to: 'performances#show', via: 'get'
# match '/products', to: 'products#show', via: 'get'


#Data Reports Calling it Papers...
match '/papers', to: 'papers#index', via: 'get'
match '/papersweekly', to: 'papers#generateweekly', via: 'post'
match '/papersmonthly', to: 'papers#generatemonthly', via: 'post'

#Data Archiving to csv files
get "archives/backup"
post "archives/restore"

# #preselect theater for distributeds data entry:
match '/preedit', to: 'distributeds#preedit', via: 'get'
match '/distributeds', to: 'distributeds#index', via: 'get'

# #Data Viewer
# resources :distributed_reports, :only => [:index]
end
