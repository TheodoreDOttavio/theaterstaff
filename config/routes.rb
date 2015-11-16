Theaterstaff::Application.routes.draw do

  get "archives/backup"
  post "archives/restore"

resources :theaters,
  :performances,
  :products,
  :events,
  :availables,
  :distributeds

resources :sessions, only: [:new, :create, :destroy]


resources :users do
  member do
    get 'txtalert'
    get 'emailalert'
  end
end


match '/signup', to: 'users#new', via: 'get'
match '/signin',  to: 'sessions#new', via: 'get'
match '/signout', to: 'sessions#destroy', via: 'delete'

#This arranges both for a valid page at /help (responding to GET requests)
#and a named route called help_path that returns the path to that page.
#(Actually, using get in place of match gives the same named routes,
# but using match is more conventional.)

match '/help', to: 'static_pages#help', via: 'get'
match '/home', to: 'static_pages#home', via: 'get'
match '/about', to: 'static_pages#about', via: 'get'
match '/contact', to: 'static_pages#contact', via: 'get'

root  'static_pages#home'

match '/theaters', to: 'theaters#show', via: 'get'
match '/performances', to: 'performances#show', via: 'get'
match '/products', to: 'products#show', via: 'get'
match '/events', to: 'events#show', via: 'get'


#revised reports Calling it Papers...
match '/papers', to: 'papers#index', via: 'get'
match '/papersweekly', to: 'papers#generateweekly', via: 'post'
match '/papersmonthly', to: 'papers#generatemonthly', via: 'post'

#preselect theater for distributeds data entry:
match '/preedit', to: 'distributeds#preedit', via: 'get'

#Data Viewer
resources :distributed_reports, :only => [:index]



#Email and txt messages
#match '/sms_mailer', to: 'SmsMailer#schedule_for_txt_msg', via: 'get'
#match "/settings_redirect" => "settings#redirect", :via => "get"

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
