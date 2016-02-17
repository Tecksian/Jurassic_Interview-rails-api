require 'rails_helper'

RSpec.describe "Dinosaurs", type: :request do

  # we include caging a dino in the business logic, as it's not something that's an inherent
  # part of being either a dinosaur or a cage. It's something ouside forces want to accomplish,
  # so into business logic it goes!
  describe "PUT /dinosaurs/cage" do
    let!(:test_cage_size) {3}
    # a lone dinosaur for testing...not a JSON one -- yet. Useful to have original around.
    let!(:single_dinosaur) { create(:dinosaur, :herbivore) }
    # adding the root: true because I believe it's more robust and secure
    # (even though RocketPants doesn't like it)
    let!(:single_json_dinosaur) { single_dinosaur.as_json(root: true, include: [:species, :cage]) }
    # an empty cage with the power on
    let!(:test_cage_on) { create(:cage, powered_up: true)}
    # a dinosaur who has been assigned a cage
    let!(:single_caged_dinosaur) {assign_cage(single_dinosaur, test_cage_on)}

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

    it "prevents adding a dinosaur to a cage that is powered down" do
      test_cage_off = create(:cage, powered_up: false)
      assign_cage(single_dinosaur, test_cage_off)
      put to_cage_dinosaurs_path, single_dinosaur.as_json(root: true, include:[:species, :cage]), format: :json

      expect(response).to have_http_status 422
      expect(JSON.parse(response.body)['messages']['powered_up']).to \
        eq(["Cannot have a dinosaur in a cage that is powered off. "])
    end

    describe "check Cages for invalid species mixes" do
      let!(:single_herbivore) {create(:dinosaur, :herbivore)}
      let!(:single_caged_herbivore) { assign_cage(single_herbivore, test_cage_on) }
      let!(:single_carnivore) {create(:dinosaur, :carnivore)}
      let!(:single_caged_carnivore) {assign_cage(single_carnivore, test_cage_on)}

      it "prevents adding a carnivore to an herbivore" do
        #cage an herbivore....
        single_caged_herbivore.save
        #try to add a carnivore...
        put to_cage_dinosaurs_path, single_caged_carnivore.as_json(root: true, include: [:species, :cage]), format: :json

        expect(response).to have_http_status 422
        expect(JSON.parse(response.body)['messages']['Unhappy Buffet Cage:']).to \
        eq(["Cannot have a carnivore and herbivore in the same cage."])
      end

      it "prevents adding an herbivore to a carnivore" do
        #cage a carnivore...
        single_caged_carnivore.save
        #try to add an herbivore...
        put to_cage_dinosaurs_path, single_caged_herbivore.as_json(root: true, include: [:species, :cage]), format: :json

        expect(response).to have_http_status 422
        expect(JSON.parse(response.body)['messages']['Unhappy Buffet Cage:']).to \
        eq(["Cannot have a carnivore and herbivore in the same cage."])
      end

      it "prevents two different species of carnivore" do
        #because we built our dinosaur factory to cycle through species, asking for
        #two carnivores is guaranteed to produce two different species.
        a_carnivore, different_caged_carnivore = create_list(:dinosaur, 2, :carnivore)
        #add a carnivore of one species...
        assign_cage(a_carnivore, test_cage_on).save
        #now try to add a carnivore of a different species...
        assign_cage(different_caged_carnivore, test_cage_on)

        put to_cage_dinosaurs_path, different_caged_carnivore.as_json(root: true, include: [:species, :cage]), format: :json

        expect(response).to have_http_status 422
        expect(JSON.parse(response.body)['messages']['Unhappy FightClub Cage']).to \
        eq(["Cannot have multiple carnivorous species in the same cage"])
      end
    end
  end
end


describe "/cages?status=" do
  let(:number_of_active) {3+rand(7)}
  let(:number_of_inactive) {3+rand(7)}
  let(:on_cages) {create_list(:cage, number_of_active, status: 'ACTIVE')}
  let(:off_cages) {create_list(:cage, number_of_inactive, status: 'INACTIVE')}

  it "filters by /cages/?status=ACTIVE" do
    on_cages
    get cages_path+'?status=ACTIVE'
    expect(response).to have_exposed on_cages
  end

  it "filters by /cages/?status=INACTIVE" do
    off_cages
    get cages_path+'?status=INACTIVE'
    expect(response).to have_exposed off_cages
  end
end
