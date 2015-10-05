json.array!(@resources) do |resource|
  json.extract! resource, :id
  json.name resource.name
end
