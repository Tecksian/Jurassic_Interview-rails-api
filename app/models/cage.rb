# Cages don't need a name, so we just use id as our cage number.
class Cage < ActiveRecord::Base
  #make sure max_occupancy is a positive integer
  validates :max_occupancy, presence: true, numericality: { only_integer: true, greater_than: 0 }

  has_many :dinosaurs, inverse_of: :cage, validate: :true
end
