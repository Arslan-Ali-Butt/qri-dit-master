shared_context 'an HTTP OK request' do
  it 'returns an OK (200) status code when resources have been found' do
    expect(response.status).to eq(200)
  end
end

shared_context 'an HTTP No Content request' do
  it 'returns a No Content (204) status code no resources have been found' do
    expect(response.status).to eq(204)
  end
end

shared_context 'an index request' do
  it "returns a JSON array" do
    json = JSON.parse(response.body)
    expect(json).to be_instance_of(Array)

    # at least an ID is required
    expect(json[0].to_json).to have_json_path('id')
  end
end

shared_context 'a successful show request' do
  it 'returns the specified item' do
    json = JSON.parse(response.body)
    expect(json['id']).to eq(id)
  end
end

shared_context 'a failed create' do
  it 'returns an unprocessable entity (422) status code' do
    expect(response.status).to eq(422)
  end
end

# shared_context 'a response with nested errors' do
#   it 'returns the error messages' do
#     json = JSON.parse(response.body)['errors']
#     expect(json['error']).to eq(message)
#   end
# end

# shared_context 'a response with errors' do
#   it 'returns the error messages' do
#     json = JSON.parse(response.body)
#     expect(json['error']).to eq(message)
#   end
# end

# shared_context 'a show request with a root' do |root|
#   it 'returns the specified item' do
#     json = JSON.parse(response.body)[root]
#     expect(json['id']).to eq(id)
#   end
# end