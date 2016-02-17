# Cages don't need a name, so we just use id as our cage number.
class Cage < ActiveRecord::Base
  #make sure max_occupancy is a positive integer
  validates :max_occupancy, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :power_safety_status
  validates :current_occupancy, numericality: { less_than_or_equal_to: :max_occupancy, \
      message: "Cage is full -- cannot add another dinosaur" }, unless: 'max_occupancy.nil?'
  has_many :dinosaurs, inverse_of: :cage, validate: :true

  attr_reader :current_occupancy
  # the attributes to display in serialization
  def attributes
    {id: nil, max_occupancy: 5, powered_up: true, current_occupancy: current_occupancy}
  end

  # the number of dinosaurs currently in this cage
  def current_occupancy
    self.dinosaurs.size
  end

  # TRUE if the cage is empty, FALSE if it is not
  def is_empty?
    self.current_occupancy == 0
  end

  #is it safe to power down, or to put a dino in?
  def power_safety_status
    if not (powered_up or is_empty?)
      errors.add(:powered_up, "Cannot have a dinosaur in a cage that is powered off. ")
    end

  end
end
