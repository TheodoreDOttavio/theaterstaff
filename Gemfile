source 'http://rubygems.org'

gem 'bcrypt', '~> 3.1.7'
gem 'bootstrap-sass'
gem 'bootstrap-will_paginate'
gem 'chartkick'                 #Pretties for the Datum!
gem 'coffee-rails', '~> 4.1.0'
gem 'coffee-script-source', '1.8.0' #Solves the execjs error, line 6 of application.html
    #This is a cheap patch. a proper fix of the UTF char set in runtime.rb can be used
    #Info here: http://stackoverflow.com/questions/12520456/execjsruntimeerror-on-windows-trying-to-follow-rubytutorial/14118913#14118913
gem 'cocoon'                    #for nested forms on many-to-many join models
gem 'datagrid'
#gem 'jbuilder', '~> 2.0'
gem 'jquery-rails'
gem 'kaminari'
#gem 'lightbox_rails'   this is added in manually at the momment (as a .js, and a .css in assets)
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
  ruby '1.9.3'
  #gem 'capistrano-rails'
  gem 'debugger'                 # Call 'debugger' anywhere in the code to stop execution and get a debugger console
  gem 'sqlite3'
  gem 'web-console', '~> 2.0'    # Access an IRB console on exception pages or by using <%= console %> in views
end


group :production do
  #ruby '2.0.0'
  gem 'rails_12factor'
  gem 'pg'
end