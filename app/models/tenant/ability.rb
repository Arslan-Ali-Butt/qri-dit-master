class Tenant::Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Tenant::User.new # guest user (not logged in)

    if user.role? :admin
      can :manage, :all
    elsif user.role? :manager
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete, :invite], :client
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete, :invite], :user
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete, :rebuild], :task
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete, :rebuild], :permatask
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete], :zone
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete], :work_type
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete], :site
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete, :duplicate, :qrcard, :qrcode, :trial, :nominate, :populate, :customize, :augment, :rehash], :qrid
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete], :qrid_photo
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete, :reschedule], :assignment
      can [:index, :show, :edit, :update, :create], :report
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete], :report_solution
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete], :report_note
      can [:index, :show], :my_assignment
      can [:index, :start,:trial], :my_qrid
      can [:index, :show, :submit], :my_report
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete], :report_photo
      can [:index], :time
    elsif user.role? :reporter
      can [:index, :show], :my_assignment
      can [:index, :start,:trial], :my_qrid
      can [:index, :show], :qrid_photo
      can [:index, :show], :qrid
      can [:index, :show, :submit], :my_report
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete], :report_photo
      can [:create], :report
    elsif user.role? :client
      can [:index, :show], :my_site
      can [:index, :show], :report_photo
      can [:index, :show], :c_report
      can [:index, :show, :update], :report_solution
      can [:index, :show, :new, :create, :edit, :update, :destroy, :delete], :report_note
    end
  end
end
