
FactoryGirl.define do

  factory :dinosaur do

    #make sure dinosaurs have different names
    sequence(:name){ |index| "Testasaurus-#{index}"}
    species {attributes_for(:species)[:id] }

    trait :caged do
      cage {create(:cage)}
    end

    #could parameterize this more efficiently, but clock is ticking....
    trait :herbivore do
      species {attributes_for(:species, :herbivore)[:id] }

    end
    trait :carnivore do
      species {attributes_for(:species, :carnivore)[:id] }
    end
  end
end



