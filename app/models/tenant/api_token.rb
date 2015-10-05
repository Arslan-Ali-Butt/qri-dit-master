class Tenant::ApiToken < ActiveRecord::Base
  belongs_to :user
end
