json.id task.id
json.parent_id task.parent_id.nil? ? 0 : task.parent_id
if @features[:lft_right]
  json.lft task.position
  json.rgt 0
end
json.name task.name
json.task_type task.task_type

children = task.children.where(active: true)
if task.respond_to?(:checked)
  children = children.where(checked: true)
end

json.children children do |child_task|
  json.partial! 'api/v0/tenant/qrids/task', task: child_task
end