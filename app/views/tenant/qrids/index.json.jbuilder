json.array!(@resources) do |resource|
  json.extract! resource, :id
  json.name "#{resource.name} (#{resource.estimated_duration} hours)"
end
