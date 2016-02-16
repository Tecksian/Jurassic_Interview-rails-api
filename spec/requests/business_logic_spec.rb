require 'rails_helper'

RSpec.describe "Dinosaurs", type: :request do

  # we include caging a dino in the business logic, as it's not something that's an inherent
  # part of being either a dinosaur or a cage. It's something ouside forces want to accomplish,
  # so into business logic it goes!
  describe "PUT /dinosaurs/cage" do
    # a lone dinosaur for testing...not a JSON one -- yet. Useful to have original around.
    let!(:single_dinosaur) { create(:dinosaur) }
    # adding the root: true because I believe it's more robust and secure
    # (even though RocketPants doesn't like it)
    let!(:single_json_dinosaur) { single_dinosaur.as_json(root: true) }
    # an empty cage with the power on
    let!(:test_cage_on) { create(:cage, powered_up: true)}

    it "adds a dinosaur to a cage" do
      single_caged_dinosaur = test_cage_on.dinosaurs.build(single_dinosaur.attributes)
      put to_cage_dinosaurs_path, single_caged_dinosaur.as_json(root: true, include: :cage), format: :json

      expect(response).to have_http_status 200
      #update the testing model, otherwise it expects the associated cage to still be empty
      single_caged_dinosaur.cage(true)
      expect(response).to have_exposed single_caged_dinosaur.as_json(except: [:created_at, :updated_at])
    end
  end
end