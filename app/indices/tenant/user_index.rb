Apartment.tenant_names.each do |db|
  tenant=Admin::Tenant.find(db.match(/\d+/).to_s.to_i)
  if (tenant.is_affiliate? && tenant.affiliate_status=='APPROVED')|| !tenant.is_affiliate?
    ThinkingSphinx::Index.define 'tenant/user', name: "user_#{db}", :with => :active_record do
      indexes :name, sortable: true

      # has roles(:id), as: :role_ids
      has roles.id, as: :role_ids

      where "status = 'Active'"

      set_property sql_query_pre: ["SET search_path TO #{db}"]
    end
  end
end
