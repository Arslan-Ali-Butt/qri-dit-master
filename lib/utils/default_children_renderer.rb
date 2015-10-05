module Utils
  class SortableTreeRenderer < TreeRenderer
    private

    def add_default_children
      if self.task_type == 'Question'
        ['Yes', 'No', 'N/A'].each do |answer|
          child = Tenant::Task.create!(
              name: answer,
              task_type: 'Answer',
              work_type_id: self.work_type_id,
              client_type: self.client_type,
              qrid_id: self.qrid_id,
              active: self.active
          )
          child.move_to_child_of(self)
        end
      end
    end
  end
end
