# ActsAsFulltextable
#
# 2008-03-07
#   Patched by Artūras Šlajus <x11@arturaz.net> for will_paginate support
# 2008-06-19
#   Artūras Šlajus <x11@arturaz.net>
#
#   Fixed a bug (thanks John!) where per_page was taken from FulltextRow 
#   model and not from model search was based upon.
# 2008-06-21
#   John Lane (www.starfry.com)
#
#   Added support for conditions to determine which records are included in the
#   full text search. The condition is applied to a record on each update.

require "fulltext_row"

module ActsAsFulltextable
  module ClassMethods
    # Makes a model searchable.
    # Takes a list of fields to use to create the index. It also take an option (:check_for_changes,
    # which defaults to true) to tell the engine wether it should check if the value of a given
    # instance has changed before it actually updates the associated fulltext row.
    # If option :parent_id is not nulled, it is used as the field to be used as the parent of the record,
    # which is useful if you want to limit your queries to a scope.
    # If option :conditions is given, it should be a string containing a ruby expression that 
    # equates to true or nil/false. Records are tested with this condition and only those that return true
    # add/update the FullTextRow. A record returning false that is already in FullTextRow is removed.
    #
    def acts_as_fulltextable(*attr_names)
      configuration = { :check_for_changes => true, :parent_id => nil, :conditions => "true" }
      configuration.update(attr_names.pop) while attr_names.last.is_a?(Hash)
      configuration[:fields] = attr_names.flatten.uniq.compact
      write_inheritable_attribute 'fulltext_options', configuration
      extend  FulltextableClassMethods
      include FulltextableInstanceMethods
      self.send('after_create', :create_fulltext_record)
      self.send('after_update', :update_fulltext_record)
      self.send('has_one', :fulltext_row, :as => :fulltextable, :dependent => :delete)
    end
  end
  
  module FulltextableClassMethods
    def fulltext_options
      read_inheritable_attribute('fulltext_options')
    end
    def fulltext_fields
      read_inheritable_attribute('fulltext_options')[:fields]
    end

    # Performs full-text search for objects of this class.
    # It takes three options:
    # * limit: maximum number of rows to return. Defaults to 10.
    # * offset: offset to apply to query. Defaults to 0.
    # * page: only available with will_paginate plugin installed.
    # * active_record: wether a ActiveRecord objects should be returned or an Array of [class_name, id]
    #
    def find_fulltext(query, options = {})
      default_options = {:active_record => true}
      options = default_options.merge(options)
      unless options[:page]
        options = {:limit => 10, :offset => 0}.merge(options)
      end
      options[:only] = self.to_s.underscore.to_sym # Only look for object belonging to this class
      # Pass from what class search is invoked.
      options[:search_class] = Kernel.const_get(self.to_s)

      FulltextRow.search(query, options)
    end
  end
  
  def self.included(receiver)
    receiver.extend(ClassMethods)
  end
  
  module FulltextableInstanceMethods
    # Creates the fulltext_row record for self
    #
    def create_fulltext_record
      FulltextRow.create(:fulltextable_type => self.class.to_s, :fulltextable_id => self.id, :value => self.fulltext_value, :parent_id => self.parent_id_value) if eval self.class.fulltext_options[:conditions]
    end
    
    # Returns the parent_id value or nil if it wasn't set.
    #
    def parent_id_value
      self.class.fulltext_options[:parent_id].nil? ? nil : self.send(self.class.fulltext_options[:parent_id])
    end
    
    # Updates self's fulltext_row record
    #
    def update_fulltext_record
      if eval self.class.fulltext_options[:conditions]
        if self.class.fulltext_options[:check_for_changes]
          row = FulltextRow.find_by_fulltextable_type_and_fulltextable_id(self.class.to_s, self.id) 
          # If we haven't got a row for the record, yet, create it instead of updating it.
          if row.nil?
            self.create_fulltext_record
            return
          end
        end
        FulltextRow.update_all(["value = ?, parent_id = ?", self.fulltext_value, self.parent_id_value], ["fulltextable_type = ? AND fulltextable_id = ?", self.class.to_s, self.id]) if !(self.class.fulltext_options[:check_for_changes]) || (row.value != self.fulltext_value) || (self.parent_id_value != row.parent_id)
      else
        row = FulltextRow.find_by_fulltextable_type_and_fulltextable_id(self.class.to_s, self.id)
        row.destroy unless row.nil?
      end
    end  
    
    # Returns self's value created by concatenating fulltext fields for its class
    #
    def fulltext_value
      self.class.fulltext_fields.map {|f| self.send(f)}.join("\n")
    end
  end
end

ActiveRecord::Base.send :include, ActsAsFulltextable
