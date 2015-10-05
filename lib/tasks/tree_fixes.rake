namespace :tree_fixes do
  desc "fix task tree integrity"
  task fix_task_tree_integrity: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    ActiveRecord::Base.transaction do
      Apartment::Tenant.switch "tenant#{ARGV[1]}"
      damanaged_questions=[]
      puts "collecting tasks"
      damanaged_questions=recurse_tasks(nil,damanaged_questions,"")
      puts "recovering bad #{damanaged_questions.length}"
      damanaged_questions.each_with_index do |answer,index|
        puts "#{index}"
        task=Tenant::Task.create!({task_type: 'Answer',name:answer[:name],work_type_id:answer[:work_type_id],client_type:answer[:client_type],qrid_id:answer[:qrid_id],checked:true,active:answer[:active]})
        task.move_to_child_with_index(Tenant::Task.find(answer[:parent_id]),answer[:position])
      end
    end
  end


  def recurse_tasks(parent_id,damanaged_questions,parent_type)
    tasks=Tenant::Task.where(parent_id: parent_id).order(qrid_id: :asc)
    if parent_type=='Question'
      tasks=tasks.order(name: :desc)
      parent=Tenant::Task.find(parent_id)
      if tasks.count!=3
        names=tasks.to_ary.map { |task| task.name }
        unless names.include? "Yes"
          damanaged_questions<<{parent_id: parent_id, name: "Yes", position: 0, work_type_id: parent.work_type_id, client_type: parent.client_type, qrid_id: parent.qrid_id, active: parent.active}
        end
        unless names.include? "No"
          damanaged_questions<<{parent_id: parent_id, name: "No", position: 1, work_type_id: parent.work_type_id, client_type: parent.client_type, qrid_id: parent.qrid_id, active: parent.active}
        end
        unless names.include? "N/A"
          damanaged_questions<<{parent_id: parent_id, name: "N/A", position: 2, work_type_id: parent.work_type_id, client_type: parent.client_type, qrid_id: parent.qrid_id, active: parent.active}
        end
      end
      tasks.each  do |task|
        if task.checked!=parent.checked
          task.checked=parent.checked
        end
      end
    end
    tasks.each do |task|
      damanaged_questions=recurse_tasks(task.id,damanaged_questions,task.task_type) if Tenant::Task.where(parent_id: task.id).count!=0 || task.task_type=='Question'
    end
    return damanaged_questions
  end

  desc "fix permatask tree integrity"
  task fix_permatask_tree_integrity: :environment do
    ARGV.each { |a| task a.to_sym do ; end }
    ActiveRecord::Base.transaction do
      Apartment::Tenant.switch "tenant#{ARGV[1].to_s}"
      damanaged_questions=[]
      puts "collecting permatasks"
      damanaged_questions=recurse_permatasks(nil,damanaged_questions,"")
      puts "recovering bad"
      damanaged_questions.each do |answer|
        task=Tenant::Permatask.create!({task_type: 'Answer',name:answer[:name],active:answer[:active]})
        task.move_to_child_with_index(Tenant::Permatask.find(answer[:parent_id]),answer[:position])
      end
    end
  end


  def recurse_permatasks(parent_id,damanaged_questions,parent_type)
    tasks=Tenant::Permatask.where(parent_id: parent_id)
    if parent_type=='Question'
      tasks=tasks.order(name: :desc)
      parent=Tenant::Permatask.find(parent_id)
      if tasks.count!=3
        names=tasks.to_ary.map { |task| task.name }
        unless names.include? "Yes"
          damanaged_questions<<{parent_id: parent_id, name: "Yes", position: 0, active: parent.active}
        end
        unless names.include? "No"
          damanaged_questions<<{parent_id: parent_id, name: "No", position: 1, active: parent.active}
        end
        unless names.include? "N/A"
          damanaged_questions<<{parent_id: parent_id, name: "N/A", position: 2, active: parent.active}
        end
      end
    else
      tasks=tasks.order(position: :asc)
    end
    tasks.each do |task| damanaged_questions=recurse_permatasks(task.id,damanaged_questions,task.task_type) if Tenant::Permatask.where(parent_id: task.id).count!=0 || task.task_type=='Question'    end
    return damanaged_questions
  end
end