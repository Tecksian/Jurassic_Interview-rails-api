include ActiveModel::Serializers::JSON

# Dinosaur class. Only fundamental attributes are name, cage_id, and species_id. Created method-based
# attributes for species_name, is_carnivore, and allowed viewing of cage_id which is functionally similar
# to a cage number.
class Dinosaur < ActiveRecord::Base
  scope :dinosaur_species_name, -> (find_name) { joins(:species).merge(Species.where(name: find_name)) }
  validates :name,
            presence: true,
            # The problem description does not specify unique names, but the alternative
            # is name+species being unique (otherwise nonsense ensues -- in business use, not only code).
            # We choose the easier of the two implied options, if only to avoid sitcom-like confusion!
            uniqueness: true
  # dinosaurs must have a species....
  validates :species, presence: :true
  # ... and moreover they must have a VALID species. Despite my 'Testasaurus' spec names.
  belongs_to :species, inverse_of: :dinosaurs, validate: true


  # dinosaurs needn't have a cage, but if they do, it needs to be a real cage.
  belongs_to :cage, inverse_of: :dinosaurs, validate: true
  attr_accessor :species_name, :is_carnivore
  # overloading attributes is the crux of ActiveModel::Serializers
  def attributes
    {name: self.name, species_name: species_name, is_carnivore: is_carnivore, cage_id: self.cage_id}
  end

  def species_name
    self.species.name unless species_id.nil?
  end

  def is_carnivore
    self.species.is_carnivore unless species_id.nil?
  end

end