

FactoryGirl.define do
  #create a shuffled, but cycling, choice of species
  #first by shuffling...
  shuffled_species_list = Species.all.shuffle

  #create species type-specific lists. Could make this more efficient, to be sure, but this is more readable.
  shuffled_herbivores = shuffled_species_list.reject {|type| type.is_carnivore}
  shuffled_carnivores = shuffled_species_list.select {|type| type.is_carnivore}

  #...then by cycling
  sequence(:index)  { |i| i % shuffled_species_list.count}
  sequence(:herbiv_index) {|i| i% shuffled_herbivores.count}
  sequence(:carniv_index) {|i| i% shuffled_carnivores.count}

  factory :species do

    transient do
      next_index {generate(:index)}
      generated_species {shuffled_species_list[next_index]}

      trait :herbivore do
        next_index {generate(:herbiv_index)}
        generated_species {shuffled_herbivores[next_index]}
      end

      trait :carnivore do
        next_index {generate(:carniv_index)}
        generated_species {shuffled_carnivores[next_index]}
      end

      trait :same do
        # ...don't cycle if we want the same species
        next_index 0
      end
    end

    id {generated_species}
    # name {generated_species.name}
    # is_carnivore {generated_species.is_carnivore}
  end
end

