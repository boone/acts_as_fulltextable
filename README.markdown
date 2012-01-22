ActsAsFulltextable
==================

[![Build Status](https://secure.travis-ci.org/boone/acts_as_fulltextable.png)](http://travis-ci.org/boone/acts_as_fulltextable)

It allows you to create an auxiliary to be used for full-text searches.
It behaves like a polymorphic association, so it can be used with any
ActiveRecord model.

This plugin is compatible with MySQL only.

The code is based on the original acts_as_fulltextable plugin: http://code.google.com/p/wonsys/

## Step 1

Install the plugin:
  script/plugin install https://boone@github.com/boone/acts_as_fulltextable.git

## Step 2

Add the following code to the model that should be included in searches:
  acts_as_fulltextable :fields, :to, :include, :in, :index

## Step 3

Create the migration:
  script/generate fulltext_rows model1 model2 model3 ...

Then execute it:
  rake db:migrate

## Run searches

You can either run a search on a single model:
  Model.find_fulltext('query to run', :limit => 10, :offset => 0)

Or you can run it on more models at once:
  FulltextRow.search('query to run', :only => [:only, :this, :models], :limit => 10, :offset => 0)

## Warning

Should you add acts_as_fulltextable to a new model after the initial migration was run,
you should execute the following piece of code (a migration or script/console are both fine):
  
  NewModel.find(:all).each {|i| i.create_fulltext_record}

It will add all of the model's instances to the index.

## Contact us

[boonedocks.net](http://boonedocks.net)


@boonedocks on Twitter
