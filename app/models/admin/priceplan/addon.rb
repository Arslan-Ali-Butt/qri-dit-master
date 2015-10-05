class Admin::Priceplan::Addon < ActiveRecord::Base
  belongs_to :priceplan, class_name: 'Admin::Priceplan'
end
