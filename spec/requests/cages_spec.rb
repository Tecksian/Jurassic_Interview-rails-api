require 'rspec'

# NOTE: As mentioned in the readme, making only the barest-bones unit tests that don't involve the
# business logic. Could be refactored and DRY-ed up a great deal.
RSpec.describe "Cages", type: :request do

  #define a cage_list_size to easily vary testing sample sizes
  let!(:cage_list_size) {5}
  let!(:cage_list) {create_list(:cage, cage_list_size)}

  #can we see existing cages?
  describe "GET /cages.json", type: :request do
    before do
      get cages_path
    end

    it "returns HTTP status of 200" do
      expect(response).to have_http_status(200)
    end

    it "resturns JSON data" do
      expect(response.content_type).to eq("application/json")
    end

    it "returns cage_list_size cages" do
      expect(JSON.parse(response.body)['count'].to_int).to eq(cage_list_size)
    end

    it "shows the correct cages" do
      expect(response).to have_exposed cage_list
    end
  end

  # Can the api create its own cages?
  describe "POST /cages.json" do
    let!(:single_json_cage) {FactoryGirl.build(:cage).as_json(root: true)}
    before(:each) do
      post cages_path, single_json_cage, format: :json
    end

    it 'adds a new cage' do
      expect(response).to have_http_status :created
      expect(response.content_type).to eq("application/json")
    end

    it 'returns an error if no max_occupancy is specified' do
      post cages_path, {cage: {max_occupancy: nil, powered_up: true}}
      expect(response).to have_http_status :unprocessable_entity
      expect(JSON.parse(response.body)['messages']['max_occupancy']).to eq(["can't be blank", "is not a number"])
    end

  end

  #TODO PUT tests to flip the power on and off.
end
