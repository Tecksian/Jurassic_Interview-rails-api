# Dinosaur class. Only fundamental attributes are name, cage_id, and species_id. Created method-based
# attributes for species_name, is_carnivore, and allowed viewing of cage_id which is functionally similar
# to a cage number.
class Dinosaur < ActiveRecord::Base
  validates :name,
            presence: true,
            # The problem description does not specify unique names, but the alternative
            # is name+species being unique (otherwise nonsense ensues -- in business use, not only code).
            # We choose the easier of the two implied options, if only to avoid sitcom-like confusion!
            uniqueness: true
  # dinosaurs must have a species....
  belongs_to :species, inverse_of: :dinosaurs, validate: true
  # ... and moreover they must have a VALID species. Despite my 'Testasaurus' spec names.

  # dinosaurs needn't have a cage, but if they do, it needs to be a real cage.
  belongs_to :cage, inverse_of: :dinosaurs, validate: true

  def species_name
    @species_name = self.species.name
  end

  def is_carnivore
    @is_carnivore = self.species.is_carnivore
  end

end