class Tenant::UserSettings < ActiveRecord::Base
  belongs_to :user

  strip_attributes allow_empty: true
end
