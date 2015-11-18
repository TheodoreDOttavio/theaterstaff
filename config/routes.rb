Theaterstaff::Application.routes.draw do

  get "archives/backup"
  post "archives/restore"

# resources :theaters,
  # :performances,
  # :products,
  # :events,
  # :availables,
  # :distributeds
# 
# resources :sessions, only: [:new, :create, :destroy]=end



resources :users do
  member do
    get 'txtalert'
    get 'emailalert'
  end
end


match '/signup', to: 'users#new', via: 'get'
match '/signin',  to: 'sessions#new', via: 'get'
match '/signout', to: 'sessions#destroy', via: 'delete'

match '/help', to: 'static_pages#help', via: 'get'
match '/home', to: 'static_pages#home', via: 'get'
match '/about', to: 'static_pages#about', via: 'get'
match '/contact', to: 'static_pages#contact', via: 'get'

root  'static_pages#home'

# match '/theaters', to: 'theaters#show', via: 'get'
# match '/performances', to: 'performances#show', via: 'get'
# match '/products', to: 'products#show', via: 'get'
# 
# 
# #revised reports Calling it Papers...
# match '/papers', to: 'papers#index', via: 'get'
# match '/papersweekly', to: 'papers#generateweekly', via: 'post'
# match '/papersmonthly', to: 'papers#generatemonthly', via: 'post'
# 
# #preselect theater for distributeds data entry:
# match '/preedit', to: 'distributeds#preedit', via: 'get'
# 
# #Data Viewer
# resources :distributed_reports, :only => [:index]
end
