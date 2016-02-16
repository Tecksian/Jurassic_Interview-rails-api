

FactoryGirl.define do
  # a mostly basic species factory. Each call produces a shuffled,
  # different species until one of each species is produced, then it starts the cycle again.

  # create a shuffled, but cycling, choice of species
  # first by shuffling...
  shuffled_species_list = Species.all.shuffle
  # ...then by cycling
  sequence(:index)  { |i| i % shuffled_species_list.count}

  factory :species do
    # only need the id for now...
    id {shuffled_species_list[generate(:index)]}
  end
end

