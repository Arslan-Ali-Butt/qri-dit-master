module Sortable
  TYPES     = %w(Group Question Answer Comment Photo Instructions)

  NESTING_RULES = {
      'Group'     => ['Group', 'Question', 'Instructions'],
      'Question'  => ['Answer'],
      'Answer'    => ['Question', 'Comment', 'Photo', 'Instructions'],
      'Comment'   => [],
      'Photo'     => [],
      'Instructions' => ['Comment','Photo']
  }

  def self.included(base)
    base.class_eval do
      acts_as_ordered_tree
      validates :task_type, presence: true, inclusion: { in: TYPES }
      validate do
        unless can_be_nested_in?(self.parent_id)
          errors.add(:task_type, 'you selected cannot be nested here')
        end
      end
    end
  end
end
