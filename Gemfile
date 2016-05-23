source 'http://rubygems.org'

ruby '2.1.7'

gem 'bcrypt', '~> 3.1.7'
gem 'bootstrap-sass'
gem 'bootstrap-will_paginate'
gem 'coffee-rails', '~> 4.1.0'
gem 'coffee-script-source', '1.8.0' #Solves the execjs error, line 6 of application.html
    #This is a cheap patch. a proper fix of the UTF char set in runtime.rb can be used
    #Info here: http://stackoverflow.com/questions/12520456/execjsruntimeerror-on-windows-trying-to-follow-rubytutorial/14118913#14118913
gem 'cocoon'                    #for nested forms on many-to-many join models
gem 'datagrid'
#gem 'jbuilder', '~> 2.0'
gem 'jquery-rails' #added rails.js to assets
gem 'kaminari'
#gem 'lightbox_rails'   this is added in as .js, and .css in assets)
gem 'rails', '4.2.2'
gem 'rubyzip'
gem 'sass-rails', '~> 5.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'thinreports-rails'
gem 'turbolinks', '~> 2.5.3'
gem 'tzinfo'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
gem 'uglifier', '>= 1.3.0'
#gem 'unicorn'
gem 'writeexcel'


group :development, :test do
  gem 'childprocess', '0.3.6'
  #gem "factory_girl_rails"
  #gem 'guard-rspec' #, '2.5.0'
  #gem 'guard-spork' #, '1.5.0'
 # gem 'spork-rails' #, '4.0.0'
  #gem 'rspec-rails' #, '~> 3.0'

  #gem 'capistrano-rails'
  #gem 'debugger'                 # Call 'debugger' anywhere in the code to stop execution and get a debugger console
  gem 'sqlite3'
  #gem 'wdm' if Gem.win_platform?
  gem 'web-console', '~> 2.0'    # Access an IRB console on exception pages or by using <%= console %> in views
end


group :test do
  gem 'capybara' #, '2.1.0'
  #gem 'selenium-webdriver' #, '2.35.1'
end

group :production do
  gem 'rails_12factor'
  gem 'pg'
end