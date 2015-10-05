# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

require 'ffaker'

class DatabaseSeeder

 def seed
    if Apartment::Tenant.current_tenant == 'public'
      Admin::Landlord.create_with(password: 'Copenhagen123', password_confirmation: 'Copenhagen123').find_or_create_by!(name: 'admin')
      recreate_price_plans

    else
      tenant=Admin::Tenant.find(Apartment::Database.current_tenant.match(/\d+/).to_s.to_i)
      is_affiliate=tenant.is_affiliate?
      useParent_tempates=false
      useParent_permatasks=false
      if is_affiliate
        current_tenant=Apartment::Database.current_tenant
        Apartment::Tenant.switch("tenant#{tenant.parent_id}")
        parent_task_count=Tenant::Task.where(for_affiliates: true).count
        if parent_task_count>0
          useParent_tempates=true
        end
        parent_permatask_count=Tenant::Permatask.where(for_affiliates: true).count
        if parent_permatask_count>0
          useParent_permatasks=true
        end
        Apartment::Tenant.switch(current_tenant)
      end
      recreate_roles
      unless useParent_tempates
        recreate_work_types
      end

      if Rails.env.development?
        recreate_fake_zones(11)
        recreate_fake_client(10, :client)
        recreate_fake_staff(7, :reporter)
        recreate_fake_staff(2, :manager)
        recreate_fake_sites(14)
        unless useParent_permatasks
          recreate_fake_permatasks
        end
        unless useParent_tempates
          recreate_fake_default_tasks
        end
        recreate_fake_qrids(12)
        recreate_fake_assignments(23)
        Tenant::Report.delete_all
      end

      if Rails.env.production? or Rails.env.staging?
        unless useParent_permatasks
          recreate_fake_permatasks
        end
        unless useParent_tempates
          recreate_fake_default_tasks
        end
      end
      if useParent_tempates||useParent_permatasks
        transfer_affiliate_tasks(tenant)
      end
    end

  end

  private

  def transfer_affiliate_tasks(tenant)
    if tenant.is_affiliate?
      Apartment::Tenant.switch("tenant#{tenant.affiliate_owner.id}")
      parent_root_tasks = Tenant::Task.roots.where(qrid_id: nil).where(for_affiliates: true)
      id=1
      id_map={}
      work_types=[]
      parent_root_tasks.each do |root|
        Apartment::Tenant.switch("tenant#{tenant.affiliate_owner.id}")
        task_data=root.self_and_descendants.map do |record|

          id_map[record.id]=id
          id=id+1
          work_types<<record.work_type_id
          [
              id_map[record.id],
              id_map[record.parent_id],
              record.position,
              record.name,
              record.task_type,
              record.work_type_id,
              record.client_type,
              record.active,
              nil,
              nil,
              record.checked,
              record.depth
          ]

        end
        task_cols=[
            :id,
            :parent_id,
            :position,
            :name,
            :task_type,
            :work_type_id,
            :client_type,
            :active,
            :qrid_id,
            :origin_id,
            :checked,
            :depth
        ]
        Apartment::Tenant.switch("tenant#{tenant.id}")
        num_inserted=Tenant::Task.import task_cols, task_data, {validate: false}
        ActiveRecord::Base.connection.reset_pk_sequence!(Tenant::Task.table_name) if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
      end

      Apartment::Tenant.switch("tenant#{tenant.affiliate_owner.id}")
      parent_root_tasks = Tenant::Permatask.roots.where(for_affiliates: true)
      id=1
      id_map={}
      parent_root_tasks.each do |root|

        Apartment::Tenant.switch("tenant#{tenant.affiliate_owner.id}")
        task_data=root.self_and_descendants.map do |record|

          id_map[record.id]=id
          id=id+1
          [
              id_map[record.id],
              id_map[record.parent_id],
              record.position,
              record.name,
              record.task_type,
              record.active,
              record.depth
          ]

        end
        task_cols=[
            :id,
            :parent_id,
            :position,
            :name,
            :task_type,
            :active,
            :depth
        ]
        Apartment::Tenant.switch("tenant#{tenant.id}")
        num_inserted=Tenant::Permatask.import task_cols, task_data, {validate: false}
        ActiveRecord::Base.connection.reset_pk_sequence!(Tenant::Permatask.table_name) if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
      end

      Apartment::Tenant.switch("tenant#{tenant.affiliate_owner.id}")
      parent_work_types=Tenant::WorkType.find(work_types.compact.to_a)
      Apartment::Tenant.switch("tenant#{tenant.id}")
      work_data=parent_work_types.map do |record|
        [record.id,record.name,true]

      end
      work_cols=[:id,:name,:fixed]
      Tenant::WorkType.import work_cols, work_data, {validate: false}
      ActiveRecord::Base.connection.reset_pk_sequence!(Tenant::WorkType.table_name) if ActiveRecord::Base.connection.respond_to?(:reset_pk_sequence!)
    end
  end

  def recreate_price_plans
    Admin::Priceplan.create_with(title: 'Startup', qrid_num: 30, price_per_month: 69.00, price_per_year: 745.20, position: 10).find_or_create_by!(name: 'startup')
    Admin::Priceplan.create_with(title: 'Entrepreneur', qrid_num: 60, price_per_month: 99.00, price_per_year: 1069.20, position: 20).find_or_create_by!(name: 'entrepreneur')
    Admin::Priceplan.create_with(title: 'Business', qrid_num: 120, price_per_month: 129.00, price_per_year: 1393.20, position: 30).find_or_create_by!(name: 'business')
    Admin::Priceplan.create_with(title: 'Corporate', qrid_num: 200, price_per_month: 189.00, price_per_year: 2041.20, position: 40).find_or_create_by!(name: 'corporate')
    Admin::Priceplan.create_with(title: 'Corporate Plus', qrid_num: 300, price_per_month: 249.00, price_per_year: 2689.20, position: 50).find_or_create_by!(name: 'corp_plus')
    Admin::Priceplan.create_with(title: 'Secret Starter', qrid_num: 15, price_per_month: 35.00, price_per_year: 378.20, position: 60).find_or_create_by!(name: 'secret_starter')

    # the new pricing scheme
    priceplan = Admin::Priceplan.create_with(title: 'Qridit Base Plan', qrid_num: nil, price_per_month: 40.00, price_per_year: nil, position: 1).find_or_create_by!(name: 'qridit-base-plan')

    Admin::Priceplan::Addon.create_with(name: 'Startup', item_name: 'qrid', starting_number: 1, ending_number: 3, unit_price: 0.00, priceplan: priceplan).find_or_create_by(name: 'Startup', item_name: 'qrid', starting_number: 1, ending_number: 3)
    Admin::Priceplan::Addon.create_with(name: 'Entrepreneur', item_name: 'qrid', starting_number: 4, ending_number: 50, unit_price: 2.50, priceplan: priceplan).find_or_create_by(name: 'Entrepreneur', item_name: 'qrid', starting_number: 4, ending_number: 50)
    Admin::Priceplan::Addon.create_with(name: 'Business', item_name: 'qrid', starting_number: 51, ending_number: 250, unit_price: 1.99, priceplan: priceplan).find_or_create_by(name: 'Business', item_name: 'qrid', starting_number: 51, ending_number: 250)
    Admin::Priceplan::Addon.create_with(name: 'Corporate', item_name: 'qrid', starting_number: 251, ending_number: 350, unit_price: 1.75, priceplan: priceplan).find_or_create_by(name: 'Corporate', item_name: 'qrid', starting_number: 251, ending_number: 350)
    Admin::Priceplan::Addon.create_with(name: 'Corporate Plus', item_name: 'qrid', starting_number: 351, ending_number: 9999, unit_price: 1.50, priceplan: priceplan).find_or_create_by(name: 'Corporate Plus', item_name: 'qrid', starting_number: 351, ending_number: 9999)
  end

  def recreate_roles
    @roles = {
        admin:      Tenant::Role.create_with(position: 10).find_or_create_by!(name: 'Admin'),
        manager:    Tenant::Role.create_with(position: 20).find_or_create_by!(name: 'Manager'),
        reporter:   Tenant::Role.create_with(position: 30).find_or_create_by!(name: 'Reporter'),
        client:     Tenant::Role.create_with(position: 40).find_or_create_by!(name: 'Client')
    }
  end

  def recreate_work_types
    Tenant::WorkType.create_with(fixed: true).find_or_create_by!(name: 'Home Watch')
    Tenant::WorkType.create_with(fixed: true).find_or_create_by!(name: 'Property Management')
    Tenant::WorkType.create_with(fixed: true).find_or_create_by!(name: 'Cleaning')
  end

  def recreate_fake_zones(num)
    Tenant::Zone.delete_all

    num.times do |i|
      Tenant::Zone.create!(
          name: "#{Faker::AddressCA.neighborhood} #{i}"
      )
    end
  end

  def recreate_fake_client(num, role)
    Tenant::User.by_role(role.to_s.camelize).delete_all

    num.times do
      options = {
          role_ids: [@roles[role].id],
          email:    Faker::Internet.email,
          name:     Faker::Name.name,
          skip_invitation: true,
          address_attributes: {
              house_number: Faker::AddressCA.building_number,
              street_name:  Faker::AddressCA.street_name,
              line_2:       Faker::AddressCA.secondary_address,
              city:         Faker::AddressCA.city,
              province:     Faker::AddressCA.province_abbr,
              postal_code:  Faker::AddressCA.postal_code,
              country:      'CA'
          }
      }
      if role == :client
        options[:client_type]         = Tenant::Client::CLIENT_TYPES.sample
      end

      client = Tenant::Client.invite!(options)
    end
  end
  def recreate_fake_staff(num, role)
    Tenant::Staff.by_role(role.to_s.camelize).delete_all

    zone_ids      = Tenant::Zone.pluck(:id)
    work_type_ids = Tenant::WorkType.pluck(:id)

    num.times do
      options = {
          role_ids: [@roles[role].id],
          email:    Faker::Internet.email,
          name:     Faker::Name.name,
          skip_invitation: true
      }
      if role == :reporter
        options[:staff_zone_ids]      = [zone_ids.sample]       unless zone_ids.empty?
        options[:staff_work_type_ids] = [work_type_ids.sample]  unless work_type_ids.empty?
      end
      user = Tenant::Staff.invite!(options)
    end
  end

  def recreate_fake_sites(num)
    Tenant::Site.delete_all

    owner_ids = Tenant::Client.by_role('Client').active.pluck(:id)
    zone_ids  = Tenant::Zone.pluck(:id)

    unless owner_ids.empty? || zone_ids.empty?
      num.times do
        Tenant::Site.create!(
            owner_id:       owner_ids.sample,
            zone_id:        zone_ids.sample,
            address_attributes: {
                house_number: Faker::AddressCA.building_number,
                street_name:  Faker::AddressCA.street_name,
                line_2:       Faker::AddressCA.secondary_address,
                city:         Faker::AddressCA.city,
                province:     Faker::AddressCA.province_abbr,
                postal_code:  Faker::AddressCA.postal_code,
                country:      'CA'
            },
            alarm_code:       Faker::Lorem.word,
            alarm_safeword:   Faker::Name.name,
            alarm_company:    Faker::Company.name,
            emergency_number: Faker::PhoneNumber.phone_number
        )
      end
    end
  end

  def recreate_fake_permatasks
    Tenant::Permatask.delete_all

    options = {active: true}
    #prestorm
    i0=Tenant::Permatask.create!(options.merge({name: 'Pre-Storm Checklist',task_type: 'Group'}))
    i1=Tenant::Permatask.create!(options.merge({name: 'Main Home Exterior',task_type: 'Group'}))
    i1.move_to_child_of i0
    i2=Tenant::Permatask.create!(options.merge({name: 'yard',task_type: 'Group'}))
    i2.move_to_child_of i1
    i3=Tenant::Permatask.create!(options.merge({name: 'Were all hanging objects or loose objects stowed in garage or secure area?',task_type: 'Question'}))
    i3.move_to_child_of i2
    i3no=i3.children.detect{|child| child.name=='No'}
    i4=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i4.move_to_child_of i3no
    i5=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i5.move_to_child_of i3no
    i6=Tenant::Permatask.create!(options.merge({name: 'Was property inspected for loose items that may become airborne and removed?',task_type: 'Question'}))
    i6.move_to_child_of i2
    i6no=i6.children.detect{|child| child.name=='No'}
    i7=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i7.move_to_child_of i6no
    i8=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i8.move_to_child_of i6no
    i9=Tenant::Permatask.create!(options.merge({name: 'Home exterior',task_type: 'Group'}))
    i9.move_to_child_of i0
    i10=Tenant::Permatask.create!(options.merge({name: 'Are all hanging items (plants, wind chimes etc?) removed and stored in a safe place?',task_type: 'Question'}))
    i10.move_to_child_of i9
    i10no=i10.children.detect{|child| child.name=='No'}
    i11=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i11.move_to_child_of i10no
    i12=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i12.move_to_child_of i10no
    i13=Tenant::Permatask.create!(options.merge({name: 'Shutters installed, plywood or hurricane protection installed?',task_type: 'Question'}))
    i13.move_to_child_of i9
    i13yes=i13.children.detect{|child| child.name=='Yes'}
    i14=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i14.move_to_child_of i13yes
    i15=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i15.move_to_child_of i13yes
    i16=Tenant::Permatask.create!(options.merge({name: 'Are there any tasks that need to be completed after this pre storm check prior to the storm?',task_type: 'Question'}))
    i16.move_to_child_of i13yes
    i16yes=i16.children.detect{|child| child.name=='Yes'}
    i17=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i17.move_to_child_of i16yes
    i18=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i18.move_to_child_of i16yes
    i19=Tenant::Permatask.create!(options.merge({name: 'Pool or Spa',task_type: 'Group'}))
    i19.move_to_child_of i0
    i20=Tenant::Permatask.create!(options.merge({name: 'Patio or pool furniture stowed in a safe place?',task_type: 'Question'}))
    i20.move_to_child_of i19
    i20no=i20.children.detect{|child| child.name=='No'}
    i21=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i21.move_to_child_of i20no
    i22=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i22.move_to_child_of i20no
    i23=Tenant::Permatask.create!(options.merge({name: 'Main Home Interior',task_type: 'Group'}))
    i23.move_to_child_of i0
    i24=Tenant::Permatask.create!(options.merge({name: 'Utilities',task_type: 'Group'}))
    i24.move_to_child_of i23
    i25=Tenant::Permatask.create!(options.merge({name: 'Water Shut off to home?',task_type: 'Question'}))
    i25.move_to_child_of i24
    i25no=i25.children.detect{|child| child.name=='No'}
    i26=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i26.move_to_child_of i25no
    i27=Tenant::Permatask.create!(options.merge({name: 'Breaker switch for hot water tank switched off?',task_type: 'Question'}))
    i27.move_to_child_of i24
    i27no=i27.children.detect{|child| child.name=='No'}
    i28=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i28.move_to_child_of i27no
    i29=Tenant::Permatask.create!(options.merge({name: 'All electronic devices unplugged?',task_type: 'Question'}))
    i29.move_to_child_of i24
    i29no=i29.children.detect{|child| child.name=='No'}
    i30=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i30.move_to_child_of i29no
    i31=Tenant::Permatask.create!(options.merge({name: 'Irrigation system shut off?',task_type: 'Question'}))
    i31.move_to_child_of i24
    i31no=i31.children.detect{|child| child.name=='No'}
    i32=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i32.move_to_child_of i31no
    i33=Tenant::Permatask.create!(options.merge({name: 'Pool or Spa shut off?',task_type: 'Question'}))
    i33.move_to_child_of i24
    i33no=i33.children.detect{|child| child.name=='No'}
    i34=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i34.move_to_child_of i33no
    i35=Tenant::Permatask.create!(options.merge({name: 'Garage',task_type: 'Group'}))
    i35.move_to_child_of i0
    i36=Tenant::Permatask.create!(options.merge({name: 'Exterior',task_type: 'Group'}))
    i36.move_to_child_of i35
    i37=Tenant::Permatask.create!(options.merge({name: 'All hanging objects removed and stowed in a safe place?',task_type: 'Question'}))
    i37.move_to_child_of i36
    i37no=i37.children.detect{|child| child.name=='No'}
    i38=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i38.move_to_child_of i37no
    i39=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i39.move_to_child_of i37no
    i40=Tenant::Permatask.create!(options.merge({name: 'Interior',task_type: 'Group'}))
    i40.move_to_child_of i35
    i41=Tenant::Permatask.create!(options.merge({name: 'All items on the floors that may get wet stowed in a safe place?',task_type: 'Question'}))
    i41.move_to_child_of i40
    i41no=i41.children.detect{|child| child.name=='No'}
    i42=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i42.move_to_child_of i41no
    i43=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i43.move_to_child_of i41no
    i44=Tenant::Permatask.create!(options.merge({name: 'Garden Shed',task_type: 'Group'}))
    i44.move_to_child_of i0
    i45=Tenant::Permatask.create!(options.merge({name: 'Exterior',task_type: 'Group'}))
    i45.move_to_child_of i44
    i46=Tenant::Permatask.create!(options.merge({name: 'All hanging objects removed and stowed in a safe place?',task_type: 'Question'}))
    i46.move_to_child_of i45
    i46no=i46.children.detect{|child| child.name=='No'}
    i47=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i47.move_to_child_of i46no
    i48=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i48.move_to_child_of i46no
    i49=Tenant::Permatask.create!(options.merge({name: 'Interior',task_type: 'Group'}))
    i49.move_to_child_of i44
    i50=Tenant::Permatask.create!(options.merge({name: 'All items on the floors that may get wet stowed in a safe place?',task_type: 'Question'}))
    i50.move_to_child_of i49
    i50no=i50.children.detect{|child| child.name=='No'}
    i51=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i51.move_to_child_of i50no
    i52=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i52.move_to_child_of i50no
    i53=Tenant::Permatask.create!(options.merge({name: 'general',task_type: 'Group'}))
    i53.move_to_child_of i0
    i54=Tenant::Permatask.create!(options.merge({name: 'Please take exterior and interior pictures of property.',task_type: 'Instructions'}))
    i54.move_to_child_of i53
    i55=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i55.move_to_child_of i54
    #PostStorm
    i0=Tenant::Permatask.create!(options.merge({name: 'Post-Storm Checklist',task_type: 'Group'}))
    i1=Tenant::Permatask.create!(options.merge({name: 'Main Home Exterior',task_type: 'Group'}))
    i1.move_to_child_of i0
    i2=Tenant::Permatask.create!(options.merge({name: 'Yard',task_type: 'Group'}))
    i2.move_to_child_of i1
    i3=Tenant::Permatask.create!(options.merge({name: 'Is there any damage to the yard?',task_type: 'Question'}))
    i3.move_to_child_of i2
    i3yes=i3.children.detect{|child| child.name=='Yes'}
    i4=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i4.move_to_child_of i3yes
    i5=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i5.move_to_child_of i3yes
    i6=Tenant::Permatask.create!(options.merge({name: 'Pool damage?',task_type: 'Question'}))
    i6.move_to_child_of i3yes
    i6yes=i6.children.detect{|child| child.name=='Yes'}
    i7=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i7.move_to_child_of i6yes
    i8=Tenant::Permatask.create!(options.merge({name: 'Please Take a photo',task_type: 'Photo'}))
    i8.move_to_child_of i6yes
    i9=Tenant::Permatask.create!(options.merge({name: 'Spa damage?',task_type: 'Question'}))
    i9.move_to_child_of i3yes
    i9yes=i9.children.detect{|child| child.name=='Yes'}
    i10=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i10.move_to_child_of i9yes
    i11=Tenant::Permatask.create!(options.merge({name: 'Please Take a photo',task_type: 'Photo'}))
    i11.move_to_child_of i9yes
    i12=Tenant::Permatask.create!(options.merge({name: 'Home exterior',task_type: 'Group'}))
    i12.move_to_child_of i1
    i13=Tenant::Permatask.create!(options.merge({name: 'Is there any damage to the roof?',task_type: 'Question'}))
    i13.move_to_child_of i12
    i13yes=i13.children.detect{|child| child.name=='Yes'}
    i14=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i14.move_to_child_of i13yes
    i15=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i15.move_to_child_of i13yes
    i16=Tenant::Permatask.create!(options.merge({name: 'Is there any damage to the exterior of the home?',task_type: 'Question'}))
    i16.move_to_child_of i12
    i16yes=i16.children.detect{|child| child.name=='Yes'}
    i17=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i17.move_to_child_of i16yes
    i18=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i18.move_to_child_of i16yes
    i19=Tenant::Permatask.create!(options.merge({name: 'Is there any signs of vandalism or break & enter?',task_type: 'Question'}))
    i19.move_to_child_of i16yes
    i19yes=i19.children.detect{|child| child.name=='Yes'}
    i20=Tenant::Permatask.create!(options.merge({name: 'Please Take a photo',task_type: 'Photo'}))
    i20.move_to_child_of i19yes
    i21=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i21.move_to_child_of i19yes
    i22=Tenant::Permatask.create!(options.merge({name: 'Is there any damage to any windows or doors?',task_type: 'Question'}))
    i22.move_to_child_of i16yes
    i22yes=i22.children.detect{|child| child.name=='Yes'}
    i23=Tenant::Permatask.create!(options.merge({name: 'Please Take a photo',task_type: 'Photo'}))
    i23.move_to_child_of i22yes
    i24=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i24.move_to_child_of i22yes
    i25=Tenant::Permatask.create!(options.merge({name: 'Home Interior',task_type: 'Group'}))
    i25.move_to_child_of i0
    i26=Tenant::Permatask.create!(options.merge({name: 'Are there any damages to the interior of the home?',task_type: 'Question'}))
    i26.move_to_child_of i25
    i26yes=i26.children.detect{|child| child.name=='Yes'}
    i27=Tenant::Permatask.create!(options.merge({name: 'Please take pictures and describe.',task_type: 'Instructions'}))
    i27.move_to_child_of i26yes
    i28=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i28.move_to_child_of i27
    i29=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i29.move_to_child_of i27
    i30=Tenant::Permatask.create!(options.merge({name: 'General areas damages?',task_type: 'Question'}))
    i30.move_to_child_of i25
    i30yes=i30.children.detect{|child| child.name=='Yes'}
    i31=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i31.move_to_child_of i30yes
    i32=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i32.move_to_child_of i30yes
    i33=Tenant::Permatask.create!(options.merge({name: 'Main Living area damage?',task_type: 'Question'}))
    i33.move_to_child_of i25
    i33yes=i33.children.detect{|child| child.name=='Yes'}
    i34=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i34.move_to_child_of i33yes
    i35=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i35.move_to_child_of i33yes
    i36=Tenant::Permatask.create!(options.merge({name: 'Kitchen damages?',task_type: 'Question'}))
    i36.move_to_child_of i25
    i36yes=i36.children.detect{|child| child.name=='Yes'}
    i37=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i37.move_to_child_of i36yes
    i38=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i38.move_to_child_of i36yes
    i39=Tenant::Permatask.create!(options.merge({name: 'Bedrooms damages?',task_type: 'Question'}))
    i39.move_to_child_of i25
    i39yes=i39.children.detect{|child| child.name=='Yes'}
    i40=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i40.move_to_child_of i39yes
    i41=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i41.move_to_child_of i39yes
    i42=Tenant::Permatask.create!(options.merge({name: 'Bathrooms damage?',task_type: 'Question'}))
    i42.move_to_child_of i25
    i42yes=i42.children.detect{|child| child.name=='Yes'}
    i43=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i43.move_to_child_of i42yes
    i44=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i44.move_to_child_of i42yes
    i45=Tenant::Permatask.create!(options.merge({name: 'Garage',task_type: 'Group'}))
    i45.move_to_child_of i0
    i46=Tenant::Permatask.create!(options.merge({name: 'Exterior',task_type: 'Group'}))
    i46.move_to_child_of i45
    i47=Tenant::Permatask.create!(options.merge({name: 'Is there any damage to the exterior of the garage?',task_type: 'Question'}))
    i47.move_to_child_of i46
    i47yes=i47.children.detect{|child| child.name=='Yes'}
    i48=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i48.move_to_child_of i47yes
    i49=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i49.move_to_child_of i47yes
    i50=Tenant::Permatask.create!(options.merge({name: 'Is there any signs of vandalism or break & enter?',task_type: 'Question'}))
    i50.move_to_child_of i47yes
    i50yes=i50.children.detect{|child| child.name=='Yes'}
    i51=Tenant::Permatask.create!(options.merge({name: 'Please Take a photo if applicable',task_type: 'Photo'}))
    i51.move_to_child_of i50yes
    i52=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i52.move_to_child_of i50yes
    i53=Tenant::Permatask.create!(options.merge({name: 'Is there any damage to any windows or doors?',task_type: 'Question'}))
    i53.move_to_child_of i47yes
    i53yes=i53.children.detect{|child| child.name=='Yes'}
    i54=Tenant::Permatask.create!(options.merge({name: 'Please Take a photo if applicable',task_type: 'Photo'}))
    i54.move_to_child_of i53yes
    i55=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i55.move_to_child_of i53yes
    i56=Tenant::Permatask.create!(options.merge({name: 'Garage Interior',task_type: 'Group'}))
    i56.move_to_child_of i45
    i57=Tenant::Permatask.create!(options.merge({name: 'Is there any damage to the exterior of the garage?',task_type: 'Question'}))
    i57.move_to_child_of i56
    i57yes=i57.children.detect{|child| child.name=='Yes'}
    i58=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i58.move_to_child_of i57yes
    i59=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i59.move_to_child_of i57yes
    i60=Tenant::Permatask.create!(options.merge({name: 'Water damage to ceiling?',task_type: 'Question'}))
    i60.move_to_child_of i57yes
    i60yes=i60.children.detect{|child| child.name=='Yes'}
    i61=Tenant::Permatask.create!(options.merge({name: 'Please Take a photo if applicable',task_type: 'Photo'}))
    i61.move_to_child_of i60yes
    i62=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i62.move_to_child_of i60yes
    i63=Tenant::Permatask.create!(options.merge({name: 'Water damage to walls?',task_type: 'Question'}))
    i63.move_to_child_of i57yes
    i63yes=i63.children.detect{|child| child.name=='Yes'}
    i64=Tenant::Permatask.create!(options.merge({name: 'Please Take a photo if applicable',task_type: 'Photo'}))
    i64.move_to_child_of i63yes
    i65=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i65.move_to_child_of i63yes
    i66=Tenant::Permatask.create!(options.merge({name: 'Damage to any items stowed in the garage?',task_type: 'Question'}))
    i66.move_to_child_of i57yes
    i66yes=i66.children.detect{|child| child.name=='Yes'}
    i67=Tenant::Permatask.create!(options.merge({name: 'Please Take a photo if applicable',task_type: 'Photo'}))
    i67.move_to_child_of i66yes
    i68=Tenant::Permatask.create!(options.merge({name: 'Please Comment',task_type: 'Comment'}))
    i68.move_to_child_of i66yes
    i69=Tenant::Permatask.create!(options.merge({name: 'General',task_type: 'Group'}))
    i69.move_to_child_of i45
    i70=Tenant::Permatask.create!(options.merge({name: 'Please take any additional pictures as required.',task_type: 'Instructions'}))
    i70.move_to_child_of i69
    i71=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i71.move_to_child_of i70
    i72=Tenant::Permatask.create!(options.merge({name: 'Are there any repairs required?',task_type: 'Question'}))
    i72.move_to_child_of i69
    i72yes=i72.children.detect{|child| child.name=='Yes'}
    i73=Tenant::Permatask.create!(options.merge({name: 'Please Take a photo if applicable',task_type: 'Photo'}))
    i73.move_to_child_of i72yes
    i74=Tenant::Permatask.create!(options.merge({name: 'Please Describe any repairs required.',task_type: 'Comment'}))
    i74.move_to_child_of i72yes
    #Maintenance
    i0=Tenant::Permatask.create!(options.merge({name: 'Maintenance Job',task_type: 'Group'}))
    i1=Tenant::Permatask.create!(options.merge({name: 'Is this a scheduled maintenance job?',task_type: 'Question'}))
    i1.move_to_child_of i0
    i1yes=i1.children.detect{|child| child.name=='Yes'}
    i2=Tenant::Permatask.create!(options.merge({name: 'Please record information for job and take photos as required.',task_type: 'Instructions'}))
    i2.move_to_child_of i1yes
    i3=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i3.move_to_child_of i2
    i4=Tenant::Permatask.create!(options.merge({name: 'Scheduled job information',task_type: 'Comment'}))
    i4.move_to_child_of i2
    i5=Tenant::Permatask.create!(options.merge({name: 'Please record any materials used.',task_type: 'Instructions'}))
    i5.move_to_child_of i1yes
    i6=Tenant::Permatask.create!(options.merge({name: 'Materials used.',task_type: 'Comment'}))
    i6.move_to_child_of i5
    i7=Tenant::Permatask.create!(options.merge({name: 'Was there any 3rd party contractors required for this job?',task_type: 'Question'}))
    i7.move_to_child_of i0
    i7yes=i7.children.detect{|child| child.name=='Yes'}
    i8=Tenant::Permatask.create!(options.merge({name: 'Please record contractors Company name & address.',task_type: 'Instructions'}))
    i8.move_to_child_of i7yes
    i9=Tenant::Permatask.create!(options.merge({name: 'Contractors Name & Addres',task_type: 'Comment'}))
    i9.move_to_child_of i8
    i10=Tenant::Permatask.create!(options.merge({name: 'Please record all work contractor completed.',task_type: 'Instructions'}))
    i10.move_to_child_of i7yes
    i11=Tenant::Permatask.create!(options.merge({name: 'Contractor work completed',task_type: 'Comment'}))
    i11.move_to_child_of i10
    i12=Tenant::Permatask.create!(options.merge({name: 'Please take photos of all work completed.',task_type: 'Instructions'}))
    i12.move_to_child_of i7yes
    i13=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i13.move_to_child_of i12
    i14=Tenant::Permatask.create!(options.merge({name: 'Is this an unscheduled maintenance job?',task_type: 'Question'}))
    i14.move_to_child_of i0
    i14yes=i14.children.detect{|child| child.name=='Yes'}
    i15=Tenant::Permatask.create!(options.merge({name: 'Please record all details of the job.',task_type: 'Instructions'}))
    i15.move_to_child_of i14yes
    i16=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i16.move_to_child_of i15
    i17=Tenant::Permatask.create!(options.merge({name: 'Please explain',task_type: 'Comment'}))
    i17.move_to_child_of i15
    i18=Tenant::Permatask.create!(options.merge({name: 'Was there any 3rd party contractors required for this job?',task_type: 'Question'}))
    i18.move_to_child_of i14yes
    i18yes=i18.children.detect{|child| child.name=='Yes'}
    i19=Tenant::Permatask.create!(options.merge({name: 'Please record contractors Company name & address.',task_type: 'Instructions'}))
    i19.move_to_child_of i18yes
    i20=Tenant::Permatask.create!(options.merge({name: 'Contractors Name & Addres',task_type: 'Comment'}))
    i20.move_to_child_of i19
    i21=Tenant::Permatask.create!(options.merge({name: 'Please record all work contractor completed.',task_type: 'Instructions'}))
    i21.move_to_child_of i18yes
    i22=Tenant::Permatask.create!(options.merge({name: 'Contractor work completed',task_type: 'Comment'}))
    i22.move_to_child_of i21
    i23=Tenant::Permatask.create!(options.merge({name: 'Please take photos of all work completed.',task_type: 'Instructions'}))
    i23.move_to_child_of i18yes
    i24=Tenant::Permatask.create!(options.merge({name: 'Please take photos of all work completed.',task_type: 'Photo'}))
    i24.move_to_child_of i23
    #Time Recording Only
    i0=Tenant::Permatask.create!(options.merge({name: 'Time Recording only',task_type: 'Group'}))
    i1=Tenant::Permatask.create!(options.merge({name: 'Time recording at job site.',task_type: 'Group'}))
    i1.move_to_child_of i0
    i2=Tenant::Permatask.create!(options.merge({name: 'Are you supervising contractor work for a client?',task_type: 'Question'}))
    i2.move_to_child_of i1
    i2yes=i2.children.detect{|child| child.name=='Yes'}
    i3=Tenant::Permatask.create!(options.merge({name: 'Please indicate what type of service you are supervising.',task_type: 'Instructions'}))
    i3.move_to_child_of i2yes
    i4=Tenant::Permatask.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i4.move_to_child_of i3
    i5=Tenant::Permatask.create!(options.merge({name: 'Please put the contractors details in the comment box?',task_type: 'Instructions'}))
    i5.move_to_child_of i2yes
    i6=Tenant::Permatask.create!(options.merge({name: 'Contractor Details',task_type: 'Comment'}))
    i6.move_to_child_of i5
    i7=Tenant::Permatask.create!(options.merge({name: 'Please add photos of the before, during and after the work has been completed.',task_type: 'Instructions'}))
    i7.move_to_child_of i2yes
    i8=Tenant::Permatask.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i8.move_to_child_of i7
    i9=Tenant::Permatask.create!(options.merge({name: 'Please describe work completed.',task_type: 'Instructions'}))
    i9.move_to_child_of i2yes
    i10=Tenant::Permatask.create!(options.merge({name: 'Work Completed',task_type: 'Comment'}))
    i10.move_to_child_of i9

  end

  def recreate_fake_default_tasks
    Tenant::Task.delete_all(:qrid_id => nil)

    option = {
        client_type:  Tenant::Client::CLIENT_TYPES[0],
        active:       true
    }
	  options=option.merge({work_type_id: Tenant::WorkType.find_by!(name: 'Home Watch').id})
	  
	  i0=Tenant::Task.create!(options.merge({name: 'Home Exterior',task_type: 'Group'}))
    i1=Tenant::Task.create!(options.merge({name: 'Roof',task_type: 'Group'}))
    i1.move_to_child_of i0
    i2=Tenant::Task.create!(options.merge({name: 'Roof, Chimney, Gutters & downspouts checked and all okay?',task_type: 'Question'}))
    i2.move_to_child_of i1
    i2no=i2.children.detect{|child| child.name=='No'}
    i3=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i3.move_to_child_of i2no
    i4=Tenant::Task.create!(options.merge({name: 'If roof is not okay please take pictures, explain damage and any repairs required.',task_type: 'Instructions'}))
    i4.move_to_child_of i2no
    i5=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i5.move_to_child_of i4
    i6=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i6.move_to_child_of i4
    i7=Tenant::Task.create!(options.merge({name: 'Walls, Doors and Windows',task_type: 'Group'}))
    i7.move_to_child_of i0
    i8=Tenant::Task.create!(options.merge({name: 'Check for any signs of vandalism or break & enter and all okay?',task_type: 'Question'}))
    i8.move_to_child_of i7
    i8no=i8.children.detect{|child| child.name=='No'}
    i9=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i9.move_to_child_of i8no
    i10=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i10.move_to_child_of i8no
    i11=Tenant::Task.create!(options.merge({name: 'Exterior Doors & Windows checked and all okay?',task_type: 'Question'}))
    i11.move_to_child_of i7
    i11no=i11.children.detect{|child| child.name=='No'}
    i12=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i12.move_to_child_of i11no
    i13=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i13.move_to_child_of i11no
    i14=Tenant::Task.create!(options.merge({name: 'Exterior checked for signs of animal or rodent intrusion and all okay?',task_type: 'Question'}))
    i14.move_to_child_of i7
    i14no=i14.children.detect{|child| child.name=='No'}
    i15=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i15.move_to_child_of i14no
    i16=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i16.move_to_child_of i14no
    i17=Tenant::Task.create!(options.merge({name: 'Checked for insect damage or intrusion and all okay?',task_type: 'Question'}))
    i17.move_to_child_of i7
    i17no=i17.children.detect{|child| child.name=='No'}
    i18=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i18.move_to_child_of i17no
    i19=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i19.move_to_child_of i17no
    
    i0=Tenant::Task.create!(options.merge({name: 'Yard',task_type: 'Group'}))
    i1=Tenant::Task.create!(options.merge({name: 'Lawn, Trees, Shrubs, Gardens checked and all okay?',task_type: 'Question'}))
    i1.move_to_child_of i0
    i1no=i1.children.detect{|child| child.name=='No'}
    i2=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i2.move_to_child_of i1no
    i3=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i3.move_to_child_of i1no
    i4=Tenant::Task.create!(options.merge({name: 'Patio and/or furniture checked and all okay?',task_type: 'Question'}))
    i4.move_to_child_of i0
    i4no=i4.children.detect{|child| child.name=='No'}
    i5=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i5.move_to_child_of i4no
    i6=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i6.move_to_child_of i4no
    i7=Tenant::Task.create!(options.merge({name: 'Check & collect mail, remove solicitations & newspapers.',task_type: 'Instructions'}))
    i7.move_to_child_of i0
    i8=Tenant::Task.create!(options.merge({name: 'Faucets & hoses checked and all okay?',task_type: 'Question'}))
    i8.move_to_child_of i0
    i8no=i8.children.detect{|child| child.name=='No'}
    i9=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i9.move_to_child_of i8no
    i10=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i10.move_to_child_of i8no
    i11=Tenant::Task.create!(options.merge({name: 'Check screened in sunroom and all okay?',task_type: 'Question'}))
    i11.move_to_child_of i0
    i11no=i11.children.detect{|child| child.name=='No'}
    i12=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i12.move_to_child_of i11no
    i13=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i13.move_to_child_of i11no
    i14=Tenant::Task.create!(options.merge({name: 'Pool & Spa',task_type: 'Group'}))
    i14.move_to_child_of i0
    i15=Tenant::Task.create!(options.merge({name: 'Pool',task_type: 'Group'}))
    i15.move_to_child_of i14
    i16=Tenant::Task.create!(options.merge({name: 'Pool Water level okay?',task_type: 'Question'}))
    i16.move_to_child_of i15
    i16no=i16.children.detect{|child| child.name=='No'}
    i17=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i17.move_to_child_of i16no
    i18=Tenant::Task.create!(options.merge({name: 'Pool Chlorine & PH checked and all okay?',task_type: 'Question'}))
    i18.move_to_child_of i15
    i18no=i18.children.detect{|child| child.name=='No'}
    i19=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i19.move_to_child_of i18no
    i20=Tenant::Task.create!(options.merge({name: 'Pool Heater checked and all okay?',task_type: 'Question'}))
    i20.move_to_child_of i15
    i20no=i20.children.detect{|child| child.name=='No'}
    i21=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i21.move_to_child_of i20no
    i22=Tenant::Task.create!(options.merge({name: 'Circulating pump checked and all okay?',task_type: 'Question'}))
    i22.move_to_child_of i15
    i22no=i22.children.detect{|child| child.name=='No'}
    i23=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i23.move_to_child_of i22no
    i24=Tenant::Task.create!(options.merge({name: 'Are there any repairs or service required?',task_type: 'Question'}))
    i24.move_to_child_of i15
    i24yes=i24.children.detect{|child| child.name=='Yes'}
    i25=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i25.move_to_child_of i24yes
    i26=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i26.move_to_child_of i24yes
    i27=Tenant::Task.create!(options.merge({name: 'Spa',task_type: 'Group'}))
    i27.move_to_child_of i14
    i28=Tenant::Task.create!(options.merge({name: 'Spa Checked and all okay?',task_type: 'Question'}))
    i28.move_to_child_of i27
    i28no=i28.children.detect{|child| child.name=='No'}
    i29=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i29.move_to_child_of i28no
    i30=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i30.move_to_child_of i28no
    i31=Tenant::Task.create!(options.merge({name: 'Spa Bromine & PH checked and all okay?',task_type: 'Question'}))
    i31.move_to_child_of i27
    i31no=i31.children.detect{|child| child.name=='No'}
    i32=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i32.move_to_child_of i31no
    i33=Tenant::Task.create!(options.merge({name: 'Spa Heater checked and all okay?',task_type: 'Question'}))
    i33.move_to_child_of i27
    i33no=i33.children.detect{|child| child.name=='No'}
    i34=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i34.move_to_child_of i33no
    i35=Tenant::Task.create!(options.merge({name: 'Spa Circulating pump checked and all okay?',task_type: 'Question'}))
    i35.move_to_child_of i27
    i35no=i35.children.detect{|child| child.name=='No'}
    i36=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i36.move_to_child_of i35no
    i37=Tenant::Task.create!(options.merge({name: 'Are there any repairs or service required?',task_type: 'Question'}))
    i37.move_to_child_of i27
    i37yes=i37.children.detect{|child| child.name=='Yes'}
    i38=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i38.move_to_child_of i37yes
    i39=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i39.move_to_child_of i37yes
    i40=Tenant::Task.create!(options.merge({name: 'Does this property require yard work?',task_type: 'Question'}))
    i40.move_to_child_of i0
    i40yes=i40.children.detect{|child| child.name=='Yes'}
    i41=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i41.move_to_child_of i40yes
    i42=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i42.move_to_child_of i40yes
    
    i0=Tenant::Task.create!(options.merge({name: 'Grarage',task_type: 'Group'}))
    i1=Tenant::Task.create!(options.merge({name: 'Exterior',task_type: 'Group'}))
    i1.move_to_child_of i0
    i2=Tenant::Task.create!(options.merge({name: 'Exterior checked and all okay?',task_type: 'Question'}))
    i2.move_to_child_of i1
    i2no=i2.children.detect{|child| child.name=='No'}
    i3=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i3.move_to_child_of i2no
    i4=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i4.move_to_child_of i2no
    i5=Tenant::Task.create!(options.merge({name: 'Are there any repairs required?',task_type: 'Question'}))
    i5.move_to_child_of i2no
    i5yes=i5.children.detect{|child| child.name=='Yes'}
    i6=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i6.move_to_child_of i5yes
    i7=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i7.move_to_child_of i5yes
    i8=Tenant::Task.create!(options.merge({name: 'Check for any signs of vandalism or break & enter and all okay?',task_type: 'Question'}))
    i8.move_to_child_of i1
    i8no=i8.children.detect{|child| child.name=='No'}
    i9=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i9.move_to_child_of i8no
    i10=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i10.move_to_child_of i8no
    i11=Tenant::Task.create!(options.merge({name: 'Exterior Doors & Windows checked and all okay?',task_type: 'Question'}))
    i11.move_to_child_of i1
    i11no=i11.children.detect{|child| child.name=='No'}
    i12=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i12.move_to_child_of i11no
    i13=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i13.move_to_child_of i11no
    i14=Tenant::Task.create!(options.merge({name: 'Interior',task_type: 'Group'}))
    i14.move_to_child_of i0
    i15=Tenant::Task.create!(options.merge({name: 'Start and run vehicle.',task_type: 'Instructions'}))
    i15.move_to_child_of i14
    i16=Tenant::Task.create!(options.merge({name: 'Record any problems with vehicle.',task_type: 'Comment'}))
    i16.move_to_child_of i15
    i17=Tenant::Task.create!(options.merge({name: 'Interior of the Garage checked and all okay?',task_type: 'Question'}))
    i17.move_to_child_of i14
    i17no=i17.children.detect{|child| child.name=='No'}
    i18=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i18.move_to_child_of i17no
    i19=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i19.move_to_child_of i17no
    i20=Tenant::Task.create!(options.merge({name: 'Are all items stowed in the Garage okay?',task_type: 'Question'}))
    i20.move_to_child_of i14
    i20no=i20.children.detect{|child| child.name=='No'}
    i21=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i21.move_to_child_of i20no
    i22=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i22.move_to_child_of i20no
    i23=Tenant::Task.create!(options.merge({name: 'Garage door opener checked and all okay?',task_type: 'Question'}))
    i23.move_to_child_of i14
    i23no=i23.children.detect{|child| child.name=='No'}
    i24=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i24.move_to_child_of i23no
    i25=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i25.move_to_child_of i23no
    
    i0=Tenant::Task.create!(options.merge({name: 'Garden Shed',task_type: 'Group'}))
    i1=Tenant::Task.create!(options.merge({name: 'Shed Exterior',task_type: 'Group'}))
    i1.move_to_child_of i0
    i2=Tenant::Task.create!(options.merge({name: 'Exterior checked and all okay?',task_type: 'Question'}))
    i2.move_to_child_of i1
    i2no=i2.children.detect{|child| child.name=='No'}
    i3=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i3.move_to_child_of i2no
    i4=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i4.move_to_child_of i2no
    i5=Tenant::Task.create!(options.merge({name: 'Doors and windows okay?',task_type: 'Question'}))
    i5.move_to_child_of i2no
    i5no=i5.children.detect{|child| child.name=='No'}
    i6=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i6.move_to_child_of i5no
    i7=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i7.move_to_child_of i5no
    i8=Tenant::Task.create!(options.merge({name: 'Check for any signs of vandalism or break & enter and all okay?',task_type: 'Question'}))
    i8.move_to_child_of i1
    i8no=i8.children.detect{|child| child.name=='No'}
    i9=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i9.move_to_child_of i8no
    i10=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i10.move_to_child_of i8no
    i11=Tenant::Task.create!(options.merge({name: 'Shed Interior',task_type: 'Group'}))
    i11.move_to_child_of i0
    i12=Tenant::Task.create!(options.merge({name: 'Is the interior of the shed okay?',task_type: 'Question'}))
    i12.move_to_child_of i11
    i12no=i12.children.detect{|child| child.name=='No'}
    i13=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i13.move_to_child_of i12no
    i14=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i14.move_to_child_of i12no
    
    i0=Tenant::Task.create!(options.merge({name: 'Home Interior',task_type: 'Group'}))
    i1=Tenant::Task.create!(options.merge({name: 'General',task_type: 'Group'}))
    i1.move_to_child_of i0
    i2=Tenant::Task.create!(options.merge({name: 'Check & record humidity level in main living area.',task_type: 'Instructions'}))
    i2.move_to_child_of i1
    i3=Tenant::Task.create!(options.merge({name: 'Humidity Level',task_type: 'Comment'}))
    i3.move_to_child_of i2
    i4=Tenant::Task.create!(options.merge({name: 'Record main room temperature.',task_type: 'Instructions'}))
    i4.move_to_child_of i1
    i5=Tenant::Task.create!(options.merge({name: 'Main Room temperature.',task_type: 'Comment'}))
    i5.move_to_child_of i4
    i6=Tenant::Task.create!(options.merge({name: 'Alarm system checked and all okay?',task_type: 'Question'}))
    i6.move_to_child_of i1
    i6no=i6.children.detect{|child| child.name=='No'}
    i7=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i7.move_to_child_of i6no
    i8=Tenant::Task.create!(options.merge({name: 'All doors and windows checked and locked?',task_type: 'Question'}))
    i8.move_to_child_of i1
    i8no=i8.children.detect{|child| child.name=='No'}
    i9=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i9.move_to_child_of i8no
    i10=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i10.move_to_child_of i8no
    i11=Tenant::Task.create!(options.merge({name: 'Ceilings checked for leaks or water damage and all okay?',task_type: 'Question'}))
    i11.move_to_child_of i1
    i11no=i11.children.detect{|child| child.name=='No'}
    i12=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i12.move_to_child_of i11no
    i13=Tenant::Task.create!(options.merge({name: 'If water damage found please take pictures and describe any repairs required.',task_type: 'Instructions'}))
    i13.move_to_child_of i11no
    i14=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i14.move_to_child_of i13
    i15=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i15.move_to_child_of i13
    i16=Tenant::Task.create!(options.merge({name: 'Were all plants watered as per instructions?',task_type: 'Question'}))
    i16.move_to_child_of i1
    i16no=i16.children.detect{|child| child.name=='No'}
    i17=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i17.move_to_child_of i16no
    i18=Tenant::Task.create!(options.merge({name: 'Any signs of animal, rodent or insect infestation?',task_type: 'Question'}))
    i18.move_to_child_of i1
    i18yes=i18.children.detect{|child| child.name=='Yes'}
    i19=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i19.move_to_child_of i18yes
    i20=Tenant::Task.create!(options.merge({name: 'Any signs of mold or unusual odors?',task_type: 'Question'}))
    i20.move_to_child_of i1
    i20yes=i20.children.detect{|child| child.name=='Yes'}
    i21=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i21.move_to_child_of i20yes
    i22=Tenant::Task.create!(options.merge({name: 'Any signs of leaks in the plumbing?',task_type: 'Question'}))
    i22.move_to_child_of i1
    i22yes=i22.children.detect{|child| child.name=='Yes'}
    i23=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i23.move_to_child_of i22yes
    i24=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i24.move_to_child_of i22yes
    i25=Tenant::Task.create!(options.merge({name: 'Are there any repairs required?',task_type: 'Question'}))
    i25.move_to_child_of i22yes
    i25yes=i25.children.detect{|child| child.name=='Yes'}
    i26=Tenant::Task.create!(options.merge({name: 'Please take photos if applicable',task_type: 'Photo'}))
    i26.move_to_child_of i25yes
    i27=Tenant::Task.create!(options.merge({name: 'Please comment',task_type: 'Comment'}))
    i27.move_to_child_of i25yes
    i28=Tenant::Task.create!(options.merge({name: 'All lights checked and all okay?',task_type: 'Question'}))
    i28.move_to_child_of i1
    i28no=i28.children.detect{|child| child.name=='No'}
    i29=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i29.move_to_child_of i28no
    i30=Tenant::Task.create!(options.merge({name: 'Washer and dryer checked and all okay?',task_type: 'Question'}))
    i30.move_to_child_of i1
    i30no=i30.children.detect{|child| child.name=='No'}
    i31=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i31.move_to_child_of i30no
    i32=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i32.move_to_child_of i30no
    i33=Tenant::Task.create!(options.merge({name: 'Check A/C & heating system controls and all okay?',task_type: 'Question'}))
    i33.move_to_child_of i1
    i33no=i33.children.detect{|child| child.name=='No'}
    i34=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i34.move_to_child_of i33no
    i35=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i35.move_to_child_of i33no
    i36=Tenant::Task.create!(options.merge({name: 'Smoke detectors',task_type: 'Group'}))
    i36.move_to_child_of i0
    i37=Tenant::Task.create!(options.merge({name: 'Smoke detectors checked and all okay?',task_type: 'Question'}))
    i37.move_to_child_of i36
    i37no=i37.children.detect{|child| child.name=='No'}
    i38=Tenant::Task.create!(options.merge({name: 'Please record if batteries were changed.',task_type: 'Instructions'}))
    i38.move_to_child_of i37no
    i39=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i39.move_to_child_of i37no
    i40=Tenant::Task.create!(options.merge({name: 'Security Lights & timers',task_type: 'Group'}))
    i40.move_to_child_of i0
    i41=Tenant::Task.create!(options.merge({name: 'Security Lights & timers checked and all okay?',task_type: 'Question'}))
    i41.move_to_child_of i40
    i41no=i41.children.detect{|child| child.name=='No'}
    i42=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i42.move_to_child_of i41no
    i43=Tenant::Task.create!(options.merge({name: 'Please record any light bulbs changed.',task_type: 'Instructions'}))
    i43.move_to_child_of i41no
    i44=Tenant::Task.create!(options.merge({name: 'Timer settings checked and all okay?',task_type: 'Question'}))
    i44.move_to_child_of i40
    i44no=i44.children.detect{|child| child.name=='No'}
    i45=Tenant::Task.create!(options.merge({name: 'Please Explain & record timer settings if required.',task_type: 'Comment'}))
    i45.move_to_child_of i44no
    i46=Tenant::Task.create!(options.merge({name: 'Kitchen',task_type: 'Group'}))
    i46.move_to_child_of i0
    i47=Tenant::Task.create!(options.merge({name: 'Are faucets and drains okay?',task_type: 'Question'}))
    i47.move_to_child_of i46
    i47no=i47.children.detect{|child| child.name=='No'}
    i48=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i48.move_to_child_of i47no
    i49=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i49.move_to_child_of i47no
    i50=Tenant::Task.create!(options.merge({name: 'Is refrigerator running & all okay?',task_type: 'Question'}))
    i50.move_to_child_of i46
    i50no=i50.children.detect{|child| child.name=='No'}
    i51=Tenant::Task.create!(options.merge({name: 'Please explain',task_type: 'Comment'}))
    i51.move_to_child_of i50no
    i52=Tenant::Task.create!(options.merge({name: 'Are there any unusual noises?',task_type: 'Question'}))
    i52.move_to_child_of i50no
    i52yes=i52.children.detect{|child| child.name=='Yes'}
    i53=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i53.move_to_child_of i52yes
    i54=Tenant::Task.create!(options.merge({name: 'Was there any mold detected?',task_type: 'Question'}))
    i54.move_to_child_of i50no
    i54yes=i54.children.detect{|child| child.name=='Yes'}
    i55=Tenant::Task.create!(options.merge({name: 'If mold detected please notify office immediately.',task_type: 'Instructions'}))
    i55.move_to_child_of i54yes
    i56=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i56.move_to_child_of i54yes
    i57=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i57.move_to_child_of i54yes
    i58=Tenant::Task.create!(options.merge({name: 'All electronic devices unplugged in the kitchen?',task_type: 'Question'}))
    i58.move_to_child_of i46
    i58no=i58.children.detect{|child| child.name=='No'}
    i59=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i59.move_to_child_of i58no
    i60=Tenant::Task.create!(options.merge({name: 'Dishwasher checked and all okay?',task_type: 'Question'}))
    i60.move_to_child_of i46
    i60no=i60.children.detect{|child| child.name=='No'}
    i61=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i61.move_to_child_of i60no
    i62=Tenant::Task.create!(options.merge({name: 'Are there any leaks?',task_type: 'Question'}))
    i62.move_to_child_of i60no
    i62yes=i62.children.detect{|child| child.name=='Yes'}
    i63=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i63.move_to_child_of i62yes
    i64=Tenant::Task.create!(options.merge({name: 'Please comment',task_type: 'Comment'}))
    i64.move_to_child_of i62yes
    i65=Tenant::Task.create!(options.merge({name: 'Is Garbage disposal okay?',task_type: 'Question'}))
    i65.move_to_child_of i46
    i65no=i65.children.detect{|child| child.name=='No'}
    i66=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i66.move_to_child_of i65no
    i67=Tenant::Task.create!(options.merge({name: 'Check kitchen for signs of animal, rodent or insect infestation in cupboards and all okay?',task_type: 'Question'}))
    i67.move_to_child_of i46
    i67no=i67.children.detect{|child| child.name=='No'}
    i68=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i68.move_to_child_of i67no
    i69=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i69.move_to_child_of i67no
    i70=Tenant::Task.create!(options.merge({name: 'Please indicate if an exterminator is required?',task_type: 'Instructions'}))
    i70.move_to_child_of i67no
    i71=Tenant::Task.create!(options.merge({name: 'Exterminator required?',task_type: 'Comment'}))
    i71.move_to_child_of i70
    i72=Tenant::Task.create!(options.merge({name: 'Any signs of mold or unusual odors?',task_type: 'Question'}))
    i72.move_to_child_of i46
    i72yes=i72.children.detect{|child| child.name=='Yes'}
    i73=Tenant::Task.create!(options.merge({name: 'If mold found call office immediately and leave the home.',task_type: 'Instructions'}))
    i73.move_to_child_of i72yes
    i74=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i74.move_to_child_of i72yes
    i75=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i75.move_to_child_of i72yes
    i76=Tenant::Task.create!(options.merge({name: 'Main Living Area',task_type: 'Group'}))
    i76.move_to_child_of i0
    i77=Tenant::Task.create!(options.merge({name: 'Any signs of water damage?',task_type: 'Question'}))
    i77.move_to_child_of i76
    i77yes=i77.children.detect{|child| child.name=='Yes'}
    i78=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i78.move_to_child_of i77yes
    i79=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i79.move_to_child_of i77yes
    i80=Tenant::Task.create!(options.merge({name: 'Any signs of mold?',task_type: 'Question'}))
    i80.move_to_child_of i76
    i80yes=i80.children.detect{|child| child.name=='Yes'}
    i81=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i81.move_to_child_of i80yes
    i82=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i82.move_to_child_of i80yes
    i83=Tenant::Task.create!(options.merge({name: 'If mold is found please call office and leave the home.',task_type: 'Instructions'}))
    i83.move_to_child_of i80yes
    i84=Tenant::Task.create!(options.merge({name: 'All furniture checked and all okay?',task_type: 'Question'}))
    i84.move_to_child_of i76
    i84no=i84.children.detect{|child| child.name=='No'}
    i85=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i85.move_to_child_of i84no
    i86=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i86.move_to_child_of i84no
    i87=Tenant::Task.create!(options.merge({name: 'Bedrooms',task_type: 'Group'}))
    i87.move_to_child_of i0
    i88=Tenant::Task.create!(options.merge({name: 'Bedrooms checked and all okay?',task_type: 'Question'}))
    i88.move_to_child_of i87
    i88no=i88.children.detect{|child| child.name=='No'}
    i89=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i89.move_to_child_of i88no
    i90=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i90.move_to_child_of i88no
    i91=Tenant::Task.create!(options.merge({name: 'Bathrooms',task_type: 'Group'}))
    i91.move_to_child_of i0
    i92=Tenant::Task.create!(options.merge({name: 'Run all taps, showers, baths & flush toilets and all okay?',task_type: 'Instructions'}))
    i92.move_to_child_of i91
    i93=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i93.move_to_child_of i92
    i94=Tenant::Task.create!(options.merge({name: 'Record any problems.',task_type: 'Comment'}))
    i94.move_to_child_of i92
    i95=Tenant::Task.create!(options.merge({name: 'Any signs of leaks?',task_type: 'Question'}))
    i95.move_to_child_of i91
    i95yes=i95.children.detect{|child| child.name=='Yes'}
    i96=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i96.move_to_child_of i95yes
    i97=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i97.move_to_child_of i95yes
    i98=Tenant::Task.create!(options.merge({name: 'Any signs of mold?',task_type: 'Question'}))
    i98.move_to_child_of i91
    i98yes=i98.children.detect{|child| child.name=='Yes'}
    i99=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i99.move_to_child_of i98yes
    i100=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i100.move_to_child_of i98yes
    i101=Tenant::Task.create!(options.merge({name: 'If mold found call office immediately and leave the home.',task_type: 'Instructions'}))
    i101.move_to_child_of i98yes
    i102=Tenant::Task.create!(options.merge({name: 'Utility Room',task_type: 'Group'}))
    i102.move_to_child_of i0
    i103=Tenant::Task.create!(options.merge({name: 'General',task_type: 'Group'}))
    i103.move_to_child_of i102
    i104=Tenant::Task.create!(options.merge({name: 'Irrigation system turned on?',task_type: 'Question'}))
    i104.move_to_child_of i103
    i104no=i104.children.detect{|child| child.name=='No'}
    i105=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i105.move_to_child_of i104no
    i106=Tenant::Task.create!(options.merge({name: 'Heating system checked and all okay?',task_type: 'Question'}))
    i106.move_to_child_of i103
    i106no=i106.children.detect{|child| child.name=='No'}
    i107=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i107.move_to_child_of i106no
    i108=Tenant::Task.create!(options.merge({name: 'Check breaker/fuse panel for any abnormal signs and all okay?',task_type: 'Question'}))
    i108.move_to_child_of i103
    i108no=i108.children.detect{|child| child.name=='No'}
    i109=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i109.move_to_child_of i108no
    i110=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i110.move_to_child_of i108no
    i111=Tenant::Task.create!(options.merge({name: 'A/C System',task_type: 'Group'}))
    i111.move_to_child_of i102
    i112=Tenant::Task.create!(options.merge({name: 'A/C system checked and all okay?',task_type: 'Question'}))
    i112.move_to_child_of i111
    i112no=i112.children.detect{|child| child.name=='No'}
    i113=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i113.move_to_child_of i112no
    i114=Tenant::Task.create!(options.merge({name: 'Filters checked and all okay?',task_type: 'Question'}))
    i114.move_to_child_of i111
    i114no=i114.children.detect{|child| child.name=='No'}
    i115=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i115.move_to_child_of i114no
    i116=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i116.move_to_child_of i114no
    i117=Tenant::Task.create!(options.merge({name: 'Please record any filters changed?',task_type: 'Instructions'}))
    i117.move_to_child_of i114no
    i118=Tenant::Task.create!(options.merge({name: 'Record any filters changed.',task_type: 'Comment'}))
    i118.move_to_child_of i117
    i119=Tenant::Task.create!(options.merge({name: 'R/O Unit',task_type: 'Group'}))
    i119.move_to_child_of i102
    i120=Tenant::Task.create!(options.merge({name: 'Run water through and flush R/O unit.',task_type: 'Instructions'}))
    i120.move_to_child_of i119
    i121=Tenant::Task.create!(options.merge({name: 'Record any issues or leaks.',task_type: 'Comment'}))
    i121.move_to_child_of i120
    i122=Tenant::Task.create!(options.merge({name: 'R/O unit checked and all okay?',task_type: 'Question'}))
    i122.move_to_child_of i119
    i122no=i122.children.detect{|child| child.name=='No'}
    i123=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i123.move_to_child_of i122no
    
	  options=option.merge({work_type_id: Tenant::WorkType.find_by!(name: 'Cleaning').id})
	  
	  i1=Tenant::Task.create!(options.merge({name: 'General',task_type: 'Group'}))
    i2=Tenant::Task.create!(options.merge({name: 'Alarm System',task_type: 'Group'}))
    i2.move_to_child_of i1
    i3=Tenant::Task.create!(options.merge({name: 'Was alarm system on when you arrived?',task_type: 'Question'}))
    i3.move_to_child_of i2
    i3no=i3.children.detect{|child| child.name=='No'}
    i4=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i4.move_to_child_of i3no
    i5=Tenant::Task.create!(options.merge({name: 'When leaving was alarm system turned back on?',task_type: 'Question'}))
    i5.move_to_child_of i2
    i5no=i5.children.detect{|child| child.name=='No'}
    i6=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i6.move_to_child_of i5no
    i7=Tenant::Task.create!(options.merge({name: 'Home interior',task_type: 'Group'}))
    i8=Tenant::Task.create!(options.merge({name: 'Kitchen',task_type: 'Group'}))
    i8.move_to_child_of i7
    i9=Tenant::Task.create!(options.merge({name: 'Please note any additional cleaning completed in the kitchen.',task_type: 'Instructions'}))
    i9.move_to_child_of i8
    i10=Tenant::Task.create!(options.merge({name: 'Additional work completed today.',task_type: 'Comment'}))
    i10.move_to_child_of i9
    i11=Tenant::Task.create!(options.merge({name: 'Was there any concerns prior to cleaning the kitchen?',task_type: 'Question'}))
    i11.move_to_child_of i8
    i11yes=i11.children.detect{|child| child.name=='Yes'}
    i12=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i12.move_to_child_of i11yes
    i13=Tenant::Task.create!(options.merge({name: 'Please add a photo',task_type: 'Photo'}))
    i13.move_to_child_of i11yes
    i14=Tenant::Task.create!(options.merge({name: 'Decorative items, lights, ceiling fans & pictures wiped or dusted?',task_type: 'Question'}))
    i14.move_to_child_of i8
    i14no=i14.children.detect{|child| child.name=='No'}
    i15=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i15.move_to_child_of i14no
    i16=Tenant::Task.create!(options.merge({name: 'Cobwebs removed?',task_type: 'Question'}))
    i16.move_to_child_of i8
    i16no=i16.children.detect{|child| child.name=='No'}
    i17=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i17.move_to_child_of i16no
    i18=Tenant::Task.create!(options.merge({name: 'Window sills and baseboards wiped or dusted?',task_type: 'Question'}))
    i18.move_to_child_of i8
    i18yes=i18.children.detect{|child| child.name=='Yes'}
    i19=Tenant::Task.create!(options.merge({name: 'Please note whether they were dusted or wiped.',task_type: 'Instructions'}))
    i19.move_to_child_of i18yes
    i20=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i20.move_to_child_of i19
    i21=Tenant::Task.create!(options.merge({name: 'Table & chairs dusted and spot wiped?',task_type: 'Question'}))
    i21.move_to_child_of i8
    i21no=i21.children.detect{|child| child.name=='No'}
    i22=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i22.move_to_child_of i21no
    i23=Tenant::Task.create!(options.merge({name: 'Door knobs, light switches & hand rails dusted and spot wiped?',task_type: 'Question'}))
    i23.move_to_child_of i8
    i23no=i23.children.detect{|child| child.name=='No'}
    i24=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i24.move_to_child_of i23no
    i25=Tenant::Task.create!(options.merge({name: 'Stovetop, exterior of oven, refrigerator & dishwasher wiped and cleaned?',task_type: 'Question'}))
    i25.move_to_child_of i8
    i25no=i25.children.detect{|child| child.name=='No'}
    i26=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i26.move_to_child_of i25no
    i27=Tenant::Task.create!(options.merge({name: 'Interior of fridge cleaned?',task_type: 'Question'}))
    i27.move_to_child_of i8
    i27no=i27.children.detect{|child| child.name=='No'}
    i28=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i28.move_to_child_of i27no
    i29=Tenant::Task.create!(options.merge({name: 'Countertops & backsplash cleaned and wiped?',task_type: 'Question'}))
    i29.move_to_child_of i8
    i29no=i29.children.detect{|child| child.name=='No'}
    i30=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i30.move_to_child_of i29no
    i31=Tenant::Task.create!(options.merge({name: 'Small appliances wiped and cleaned?',task_type: 'Question'}))
    i31.move_to_child_of i8
    i31no=i31.children.detect{|child| child.name=='No'}
    i32=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i32.move_to_child_of i31no
    i33=Tenant::Task.create!(options.merge({name: 'Microwave interior cleaned?',task_type: 'Question'}))
    i33.move_to_child_of i8
    i33no=i33.children.detect{|child| child.name=='No'}
    i34=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i34.move_to_child_of i33no
    i35=Tenant::Task.create!(options.merge({name: 'Exterior of kitchen cupboards wiped?',task_type: 'Question'}))
    i35.move_to_child_of i8
    i35no=i35.children.detect{|child| child.name=='No'}
    i36=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i36.move_to_child_of i35no
    i37=Tenant::Task.create!(options.merge({name: 'Sink & faucets wiped and polished?',task_type: 'Question'}))
    i37.move_to_child_of i8
    i37no=i37.children.detect{|child| child.name=='No'}
    i38=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i38.move_to_child_of i37no
    i39=Tenant::Task.create!(options.merge({name: 'Kitchen floors cleaned?',task_type: 'Question'}))
    i39.move_to_child_of i8
    i39no=i39.children.detect{|child| child.name=='No'}
    i40=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i40.move_to_child_of i39no
    i41=Tenant::Task.create!(options.merge({name: 'Kitchen trash emptied and bag replaced?',task_type: 'Question'}))
    i41.move_to_child_of i8
    i41no=i41.children.detect{|child| child.name=='No'}
    i42=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i42.move_to_child_of i41no
    i43=Tenant::Task.create!(options.merge({name: 'Dining Area',task_type: 'Group'}))
    i43.move_to_child_of i7
    i44=Tenant::Task.create!(options.merge({name: 'Please note any additional cleaning completed in the Dining area.',task_type: 'Instructions'}))
    i44.move_to_child_of i43
    i45=Tenant::Task.create!(options.merge({name: 'Additional cleaning completed in the dining area.',task_type: 'Comment'}))
    i45.move_to_child_of i44
    i46=Tenant::Task.create!(options.merge({name: 'Decorative items, lights, ceiling fans & pictures wiped or dusted?',task_type: 'Question'}))
    i46.move_to_child_of i43
    i46no=i46.children.detect{|child| child.name=='No'}
    i47=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i47.move_to_child_of i46no
    i48=Tenant::Task.create!(options.merge({name: 'Cobwebs removed?',task_type: 'Question'}))
    i48.move_to_child_of i43
    i48no=i48.children.detect{|child| child.name=='No'}
    i49=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i49.move_to_child_of i48no
    i50=Tenant::Task.create!(options.merge({name: 'Window sills and baseboards wiped or dusted?',task_type: 'Question'}))
    i50.move_to_child_of i43
    i50no=i50.children.detect{|child| child.name=='No'}
    i51=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i51.move_to_child_of i50no
    i52=Tenant::Task.create!(options.merge({name: 'Table & chairs dusted & spot wiped?',task_type: 'Question'}))
    i52.move_to_child_of i43
    i52no=i52.children.detect{|child| child.name=='No'}
    i53=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i53.move_to_child_of i52no
    i54=Tenant::Task.create!(options.merge({name: 'Door knobs, light switches & hand rails dusted and spot wiped?',task_type: 'Question'}))
    i54.move_to_child_of i43
    i54no=i54.children.detect{|child| child.name=='No'}
    i55=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i55.move_to_child_of i54no
    i56=Tenant::Task.create!(options.merge({name: 'Any additional furniture dusted?',task_type: 'Question'}))
    i56.move_to_child_of i43
    i56yes=i56.children.detect{|child| child.name=='Yes'}
    i57=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i57.move_to_child_of i56yes
    i58=Tenant::Task.create!(options.merge({name: 'Living Area',task_type: 'Group'}))
    i58.move_to_child_of i7
    i59=Tenant::Task.create!(options.merge({name: 'Please note any additional cleaning completed in the main living area.',task_type: 'Instructions'}))
    i59.move_to_child_of i58
    i60=Tenant::Task.create!(options.merge({name: 'Additional cleaning in the main living area.',task_type: 'Comment'}))
    i60.move_to_child_of i59
    i61=Tenant::Task.create!(options.merge({name: 'Decorative items, lights, ceiling fans & pictures wiped or dusted?',task_type: 'Question'}))
    i61.move_to_child_of i58
    i61no=i61.children.detect{|child| child.name=='No'}
    i62=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i62.move_to_child_of i61no
    i63=Tenant::Task.create!(options.merge({name: 'Window sills and baseboards wiped or dusted?',task_type: 'Question'}))
    i63.move_to_child_of i58
    i63no=i63.children.detect{|child| child.name=='No'}
    i64=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i64.move_to_child_of i63no
    i65=Tenant::Task.create!(options.merge({name: 'Cobwebs removed?',task_type: 'Question'}))
    i65.move_to_child_of i58
    i65no=i65.children.detect{|child| child.name=='No'}
    i66=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i66.move_to_child_of i65no
    i67=Tenant::Task.create!(options.merge({name: 'Was furniture moved and cleaned underneath?',task_type: 'Question'}))
    i67.move_to_child_of i58
    i67no=i67.children.detect{|child| child.name=='No'}
    i68=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i68.move_to_child_of i67no
    i69=Tenant::Task.create!(options.merge({name: 'All furniture cleaned?',task_type: 'Question'}))
    i69.move_to_child_of i58
    i69no=i69.children.detect{|child| child.name=='No'}
    i70=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i70.move_to_child_of i69no
    i71=Tenant::Task.create!(options.merge({name: 'All side tables, coffee tables etc... dusted, wiped and polished?',task_type: 'Question'}))
    i71.move_to_child_of i58
    i71no=i71.children.detect{|child| child.name=='No'}
    i72=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i72.move_to_child_of i71no
    i73=Tenant::Task.create!(options.merge({name: 'Floors and carpets cleaned?',task_type: 'Question'}))
    i73.move_to_child_of i58
    i73no=i73.children.detect{|child| child.name=='No'}
    i74=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i74.move_to_child_of i73no
    i75=Tenant::Task.create!(options.merge({name: 'Entry Way',task_type: 'Group'}))
    i75.move_to_child_of i7
    i76=Tenant::Task.create!(options.merge({name: 'Any additional cleaning in the entry way?',task_type: 'Instructions'}))
    i76.move_to_child_of i75
    i77=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i77.move_to_child_of i76
    i78=Tenant::Task.create!(options.merge({name: 'Decorative items, lights, ceiling fans & pictures wiped or dusted?',task_type: 'Question'}))
    i78.move_to_child_of i75
    i78no=i78.children.detect{|child| child.name=='No'}
    i79=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i79.move_to_child_of i78no
    i80=Tenant::Task.create!(options.merge({name: 'Window sills and baseboards wiped or dusted?',task_type: 'Question'}))
    i80.move_to_child_of i78no
    i80no=i80.children.detect{|child| child.name=='No'}
    i81=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i81.move_to_child_of i80no
    i82=Tenant::Task.create!(options.merge({name: 'Cobwebs removed?',task_type: 'Question'}))
    i82.move_to_child_of i75
    i82no=i82.children.detect{|child| child.name=='No'}
    i83=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i83.move_to_child_of i82no
    i84=Tenant::Task.create!(options.merge({name: 'Hand rails dusted and wiped?',task_type: 'Question'}))
    i84.move_to_child_of i75
    i84no=i84.children.detect{|child| child.name=='No'}
    i85=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i85.move_to_child_of i84no
    i86=Tenant::Task.create!(options.merge({name: 'Floors and carpets cleaned?',task_type: 'Question'}))
    i86.move_to_child_of i75
    i86no=i86.children.detect{|child| child.name=='No'}
    i87=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i87.move_to_child_of i86no
    i88=Tenant::Task.create!(options.merge({name: 'Bedrooms',task_type: 'Group'}))
    i88.move_to_child_of i7
    i89=Tenant::Task.create!(options.merge({name: 'Additional cleaning in the bedrooms?',task_type: 'Instructions'}))
    i89.move_to_child_of i88
    i90=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i90.move_to_child_of i89
    i91=Tenant::Task.create!(options.merge({name: 'Decorative items, lights, ceiling fans & pictures wiped or dusted?',task_type: 'Question'}))
    i91.move_to_child_of i88
    i91no=i91.children.detect{|child| child.name=='No'}
    i92=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i92.move_to_child_of i91no
    i93=Tenant::Task.create!(options.merge({name: 'Was furniture moved and cleaned underneath?',task_type: 'Question'}))
    i93.move_to_child_of i88
    i93no=i93.children.detect{|child| child.name=='No'}
    i94=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i94.move_to_child_of i93no
    i95=Tenant::Task.create!(options.merge({name: 'Floors & carpets cleaned?',task_type: 'Question'}))
    i95.move_to_child_of i88
    i95no=i95.children.detect{|child| child.name=='No'}
    i96=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i96.move_to_child_of i95no
    i97=Tenant::Task.create!(options.merge({name: 'Beds made?',task_type: 'Question'}))
    i97.move_to_child_of i88
    i97yes=i97.children.detect{|child| child.name=='Yes'}
    i98=Tenant::Task.create!(options.merge({name: 'Were linens changed?',task_type: 'Question'}))
    i98.move_to_child_of i97yes
    i98no=i98.children.detect{|child| child.name=='No'}
    i99=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i99.move_to_child_of i98no
    i100=Tenant::Task.create!(options.merge({name: 'Mirrors polished?',task_type: 'Question'}))
    i100.move_to_child_of i88
    i100no=i100.children.detect{|child| child.name=='No'}
    i101=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i101.move_to_child_of i100no
    i102=Tenant::Task.create!(options.merge({name: 'Cleaned under the beds?',task_type: 'Question'}))
    i102.move_to_child_of i88
    i102no=i102.children.detect{|child| child.name=='No'}
    i103=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i103.move_to_child_of i102no
    i104=Tenant::Task.create!(options.merge({name: 'Window sills and baseboards wiped or dusted?',task_type: 'Question'}))
    i104.move_to_child_of i88
    i104no=i104.children.detect{|child| child.name=='No'}
    i105=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i105.move_to_child_of i104no
    i106=Tenant::Task.create!(options.merge({name: 'Bathrooms',task_type: 'Group'}))
    i106.move_to_child_of i7
    i107=Tenant::Task.create!(options.merge({name: 'Record any additional cleaning in the bathrooms?',task_type: 'Instructions'}))
    i107.move_to_child_of i106
    i108=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i108.move_to_child_of i107
    i109=Tenant::Task.create!(options.merge({name: 'Decorative items, lights, ceiling fans & pictures wiped or dusted?',task_type: 'Question'}))
    i109.move_to_child_of i106
    i109no=i109.children.detect{|child| child.name=='No'}
    i110=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i110.move_to_child_of i109no
    i111=Tenant::Task.create!(options.merge({name: 'Window sills and baseboards wiped or dusted?',task_type: 'Question'}))
    i111.move_to_child_of i106
    i111no=i111.children.detect{|child| child.name=='No'}
    i112=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i112.move_to_child_of i111no
    i113=Tenant::Task.create!(options.merge({name: 'Floors & carpets cleaned?',task_type: 'Question'}))
    i113.move_to_child_of i106
    i113no=i113.children.detect{|child| child.name=='No'}
    i114=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i114.move_to_child_of i113no
    i115=Tenant::Task.create!(options.merge({name: 'Glass shower doors and mirrors cleaned and polished?',task_type: 'Question'}))
    i115.move_to_child_of i106
    i115no=i115.children.detect{|child| child.name=='No'}
    i116=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i116.move_to_child_of i115no
    i117=Tenant::Task.create!(options.merge({name: 'Showers and/or tubs cleaned, sanitized and polished?',task_type: 'Question'}))
    i117.move_to_child_of i106
    i117no=i117.children.detect{|child| child.name=='No'}
    i118=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i118.move_to_child_of i117no
    i119=Tenant::Task.create!(options.merge({name: 'Sinks & taps cleaned, sanitized and polished?',task_type: 'Question'}))
    i119.move_to_child_of i106
    i119no=i119.children.detect{|child| child.name=='No'}
    i120=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i120.move_to_child_of i119no
    i121=Tenant::Task.create!(options.merge({name: 'Counters cleaned and polished?',task_type: 'Question'}))
    i121.move_to_child_of i106
    i121no=i121.children.detect{|child| child.name=='No'}
    i122=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i122.move_to_child_of i121no
    i123=Tenant::Task.create!(options.merge({name: 'Toilets cleaned, sanitized and polished inside and out?',task_type: 'Question'}))
    i123.move_to_child_of i106
    i123no=i123.children.detect{|child| child.name=='No'}
    i124=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i124.move_to_child_of i123no
    i125=Tenant::Task.create!(options.merge({name: 'Toilet paper rolls changed?',task_type: 'Question'}))
    i125.move_to_child_of i106
    i125no=i125.children.detect{|child| child.name=='No'}
    i126=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i126.move_to_child_of i125no
    i127=Tenant::Task.create!(options.merge({name: 'Outdoor living areas',task_type: 'Group'}))
    i128=Tenant::Task.create!(options.merge({name: 'Please note any additional cleaning done for the outside areas.',task_type: 'Instructions'}))
    i128.move_to_child_of i127
    i129=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i129.move_to_child_of i128
    i130=Tenant::Task.create!(options.merge({name: 'Decorative items, lights, ceiling fans & pictures wiped or dusted?',task_type: 'Question'}))
    i130.move_to_child_of i127
    i130no=i130.children.detect{|child| child.name=='No'}
    i131=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i131.move_to_child_of i130no
    i132=Tenant::Task.create!(options.merge({name: 'Floors & carpets cleaned?',task_type: 'Question'}))
    i132.move_to_child_of i127
    i132no=i132.children.detect{|child| child.name=='No'}
    i133=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i133.move_to_child_of i132no
    i134=Tenant::Task.create!(options.merge({name: 'Outdoor chairs and tables dusted and wiped down?',task_type: 'Question'}))
    i134.move_to_child_of i127
    i134no=i134.children.detect{|child| child.name=='No'}
    i135=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i135.move_to_child_of i134no
    i136=Tenant::Task.create!(options.merge({name: 'Plants watered?',task_type: 'Question'}))
    i136.move_to_child_of i127
    i136no=i136.children.detect{|child| child.name=='No'}
    i137=Tenant::Task.create!(options.merge({name: 'Please Explain',task_type: 'Comment'}))
    i137.move_to_child_of i136no

  end

  def recreate_fake_qrids(num)
    Tenant::Qrid.delete_all

    site_ids      = Tenant::Site.active.pluck(:id)
    work_type_ids = Tenant::WorkType.pluck(:id)

    unless site_ids.empty? || work_type_ids.empty?
      num.times do |i|
        Tenant::Qrid.create!(
            name:         "#{Faker::Lorem.word} #{i}",
            site_id:      site_ids.sample,
            work_type_id: work_type_ids.sample,
            estimated_duration: 1.25 + rand(2)
        )
      end
    end
  end

  def recreate_fake_assignments(num)
    Tenant::Assignment.delete_all

    assignee_ids = Tenant::Staff.by_role('Reporter').active.pluck(:id)
    qrid_ids = Tenant::Qrid.active.pluck(:id)

    unless assignee_ids.empty? || qrid_ids.empty?
      num.times do |i|
        start_at = Time.now + i * rand(35000)
        end_at = start_at + 3000 + rand(3000)

        options = {
            assignee_id:  assignee_ids.sample,
            qrid_id:      qrid_ids.sample,
            status:       Tenant::Assignment::STATUSES.sample,
            start_at:     start_at,
            end_at:       end_at
        }
        if i % 7 == 0
          options[:recurrence]  = 'w'
          options[:status]      = 'Open'
        end

        a = Tenant::Assignment.create!(options)
      end
    end
  end
end

seeder = DatabaseSeeder.new
seeder.seed
