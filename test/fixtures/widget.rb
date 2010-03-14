class Widget < ActiveRecord::Base
  acts_as_fulltextable :title, :content, :conditions => 'self.active == true'
end
