require 'rails_helper'
require 'spec_helper'

# NOTE: As mentioned in the readme, making only the barest-bones unit tests that don't involve the
# business logic. Could be refactored and DRY-ed up a great deal.
RSpec.describe "Dinosaurs", type: :request do

  # Can we see existing dinosaurs?...
  describe "GET /dinosaurs.json", type: :request do
    #Default create_list size.
    let!(:dino_list_size) {5}
    #create the list...
    let!(:dinosaur_list) {FactoryGirl.create_list(:dinosaur, dino_list_size)}

    before do
      # look for the list...
      get dinosaurs_path
    end

    # bare minimum....
    it "returns HTTP status of 200" do
      expect(response).to have_http_status(200)
    end

    # bare minimum does incluide JSON responses in your JSON api...
    it "resturns JSON data" do
      expect(response.content_type).to eq("application/json")
    end

    # did it retutn the correct dinosaurs?
    #TODO make controllers return root instead of that :json
    it "returns the dinos we created" do
      expect(response).to have_exposed dinosaur_list
    end
  end


  # Can the api create its own dinosaurs?
  describe "POST /dinosaurs.json" do
    # a lone dinosaur for testing...not a JSON one -- yet. Useful to have original around.
    let!(:single_dinosaur) { FactoryGirl.build(:dinosaur) }
    # adding the root: true because I believe it's more robust and secure
    # (even though RocketPants doesn't like it)
    let!(:single_json_dinosaur) { single_dinosaur.as_json(root: true) }
    # dinosaurs should have names...let's make sure they must.
    let!(:single_nameless_json_dinosaur) { FactoryGirl.build(:dinosaur, name: nil).as_json(root: true) }
    # while we're at it, make sure the name uniqueness constraint works, too....
    let!(:single_imposter_dinosaur) { FactoryGirl.build(:dinosaur, name: single_dinosaur.name) }

    before(:each) do
      post dinosaurs_path, single_json_dinosaur
    end

    it "adds a new dinosaur" do
      # I don't like returning no info other than 'OK'...but that's the standard.
      # TODO: append message to response for created dinosaur? That standards-ok?
      expect(response).to have_http_status :created
      # need to DRY-uo the repeated JSON content-type checks...
      # would create a helper for it if I were building more tests.
      expect(response.content_type).to eq("application/json")
    end
    #TODO: add name requirement test -- can't now, because when name is the only attribute, the whole record is nil.
    # it "returns an error if no name is specified" do
    #   post dinosaurs_path, single_nameless_json_dinosaur.as_json(root: true), format: :json
    #   expect(response).to have_http_status 422
    #   expect(JSON.parse(response.body)['messages']['name']).to eq(["can't be blank"])
    # end

    it "returns a unique constraint error on name" do
      #put one dinosaur in the DB
      single_dinosaur.save
      #try to POST a dinosaur with the same name
      post dinosaurs_path, single_imposter_dinosaur.as_json(root: true), format: :json
      expect(response).to have_http_status :conflict
      expect(JSON.parse(response.body)['name_already_taken']).to eq(single_imposter_dinosaur.name)
    end
  end

end
