require 'rails_helper'

RSpec.describe "Dinosaurs", type: :request do

  # we include caging a dino in the business logic, as it's not something that's an inherent
  # part of being either a dinosaur or a cage. It's something ouside forces want to accomplish,
  # so into business logic it goes!
  describe "PUT /dinosaurs/cage" do
    let!(:test_cage_size) {3}
    # a lone dinosaur for testing...not a JSON one -- yet. Useful to have original around.
    let!(:single_dinosaur) { create(:dinosaur) }
    # adding the root: true because I believe it's more robust and secure
    # (even though RocketPants doesn't like it)
    let!(:single_json_dinosaur) { single_dinosaur.as_json(root: true, include: [:species, :cage]) }
    # an empty cage with the power on
    let!(:test_cage_on) { create(:cage, powered_up: true)}
    # a dinosaur who has been assigned a cage
    let(:single_caged_dinosaur) {assign_cage(single_dinosaur, test_cage_on)}

    # can we add a dino to a cage?
    it "adds a dinosaur to a cage" do

      put to_cage_dinosaurs_path, single_caged_dinosaur.as_json(root: true, include: [:species, :cage]), format: :json

      expect(response).to have_http_status 200
      #update the testing model, otherwise it expects the associated cage to still be empty
      expect(response).to have_exposed single_caged_dinosaur
    end

    # Can we stuff more dinos in a cage than it can hold?
    it "prevents overcrowding" do
      #create a full cage, using only herbivores and a powered cage to avoid any other cage-related conflicts
      create_list(:dinosaur, test_cage_size, cage: test_cage_on)

      #now try to add another dinosaur...
      put to_cage_dinosaurs_path, single_caged_dinosaur.as_json(root: true, include: [:species, :cage]), format: :json

      expect(response).to have_http_status 422
      expect(JSON.parse(response.body)['messages']['current_occupancy']).to eq(['Cage is full -- cannot add another dinosaur'])
    end
  end
end