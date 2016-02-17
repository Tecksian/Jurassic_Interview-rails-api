# A model for species -- however, we are treating this as reference data, like a dictionary.
# Species data will not be (hopefully!) changeable via the API, and populated merely as seed data.
class Species < ActiveRecord::Base
  scope :name_filter, -> (species_name) { where(name: species_name) }
  #TODO generate errors for invalid values
  # Though we don't formally need to validate this data as no changes
  # are *intended* to be made to it, it's useful for helping us find our own
  # errors.
  validates :name, presence: :true, uniqueness: :true

  has_many :dinosaurs, inverse_of: :species

  def attributes
    {name: nil, is_carnivore: nil}
  end
end
