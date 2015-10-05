json.array!(@resources) do |resource|
  json.extract! resource, :id
  json.name resource.name
  json.value resource.id.to_s
  json.text resource.name
end
