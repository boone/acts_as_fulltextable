source 'http://rubygems.org'

rails_version = '~> 2.3.14'

#gem 'actionpack',   rails_version
gem 'activerecord', rails_version

gem 'rake', '~> 0.8.7'
#gem 'mocha', '0.9.7'
#gem 'sqlite3-ruby', '1.3.1'
gem 'mysql', :group => :mysql

group :debug do
  gem 'ruby-debug', :platforms => :mri_18
  gem 'ruby-debug19', :platforms => :mri_19
end unless ENV['TRAVIS']
