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
end
