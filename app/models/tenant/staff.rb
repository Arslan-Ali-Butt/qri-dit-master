class Tenant::Staff < Tenant::User
  has_many :reports, foreign_key: :reporter_id
  has_and_belongs_to_many :staff_zones, class_name: 'Tenant::Zone', join_table: 'tenant_staff_zones_users', foreign_key: 'user_id'
  has_and_belongs_to_many :staff_work_types, class_name: 'Tenant::WorkType', join_table: 'tenant_staff_work_types_users', foreign_key: 'user_id'
  has_many :assignments, foreign_key: :assignee_id, dependent: :restrict_with_exception
  has_one :address, as: :addressable, dependent: :destroy
  
  # has_many :qrids, foreign_key: 'updated_tenant_staff_id', class_name: 'qrids_updated_by'
  # has_many :qrids, foreign_key: 'created_tenant_staff_id', class_name: 'qrids_modified_by'

  accepts_nested_attributes_for :address
  
  HOURS_THIS_WEEK   = [['less than 1 hour', nil, 1], ['1 - 10 hours', 1, 10], ['10 - 20 hours', 10, 20], ['20 - 30 hours', 20, 30], ['30 - 40 hours', 30, 40], ['more than 40 hours', 40, nil]] 

  
end