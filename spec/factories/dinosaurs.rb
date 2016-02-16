# For an application this size/complexity, probably faster not to use FactoryGirl.
# However, I'd like to give the impression of what I'd do on a more complex project,
# so I'll go ahead and crack this peanut with a sledgehammer. Plus, it DRYs up code nicely.
FactoryGirl.define do
  # create a dinosaur for our testing, with a sequential name.
  factory :dinosaur do
    # sequences are good for avoiding unique constraints!
    sequence(:name){ |index| "Testasaurus-#{index}"}

    species { attributes_for(:species)[:id] }
  end
end