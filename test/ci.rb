#!/usr/bin/env ruby
def announce(name, msg)
  puts "\n\e[1;33m[#{name}] #{msg}\e[m\n"
end

def rails_version(gemfile)
  gemfile =~ /\d[\d.]*$/ ? $& : '2.3'
end

def system(*args)
  puts "$ #{args.join(' ')}"
  super
end

if ENV['TRAVIS']
  system "mysql -e 'create database acts_as_fulltextable;' >/dev/null"
  abort "failed to create mysql database" unless $?.success?
end

gemfiles = ['Gemfile']
gemfiles.concat Dir['test/gemfiles/*'].reject { |f| f.include? '.lock' }.sort.reverse

ruby19 = RUBY_VERSION > '1.9'
ruby19_gemfiles = gemfiles.first

bundler_options = ENV['TRAVIS'] ? "--path #{Dir.pwd}/vendor/bundle" : ''

failed = false

gemfiles.each do |gemfile|
  next if ruby19 and !ruby19_gemfiles.include? gemfile
  version = rails_version(gemfile)
  ENV['BUNDLE_GEMFILE'] = gemfile
  skip_install = gemfile == gemfiles.first
  if skip_install or system %(bundle install #{bundler_options})
    announce "Rails #{version}", "with mysql"
    ENV['DB'] = 'mysql'
    failed = true unless system %(bundle exec rake)
  else
    # bundle install failed
    failed = true
  end
end

exit 1 if failed
