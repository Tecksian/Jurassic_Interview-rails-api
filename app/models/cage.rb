# Cages don't need a name, so we just use id as our cage number.
class Cage < ActiveRecord::Base
  before_validation :survey_carnivores
  #make sure max_occupancy is a positive integer
  validates :max_occupancy, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :power_safety_status
  validates :current_occupancy, numericality: { less_than_or_equal_to: :max_occupancy, \
      message: "Cage is full -- cannot add another dinosaur" }, unless: 'max_occupancy.nil?'
  has_many :dinosaurs, inverse_of: :cage, validate: :true
  validate :happy_cage?
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
    unless powered_up or is_empty?
      errors.add(:powered_up, "Cannot have a dinosaur in a cage that is powered off. ")
    end

  end

  def happy_cage?
    if carnivore_species_fighting? or carnivore_will_eat_herbivore?
      true
    end

    if carnivore_species_fighting?
      errors.add('Unhappy FightClub Cage', 'Cannot have multiple carnivorous species in the same cage')
    end

    if carnivore_will_eat_herbivore?
      errors.add('Unhappy Buffet Cage:', 'Cannot have a carnivore and herbivore in the same cage.')
    end
  end

  def carnivore_species_fighting?
    @carnivores.uniq.count > 1
  end

  def carnivore_will_eat_herbivore?
    has_carnivore? and any_herbivores?
  end

  def any_herbivores?
    not @carnivores.count == current_occupancy
  end

  def has_carnivore?
    @carnivores.count > 0
  end

  def has_herbivore?
    # Yeah, really should have used before_validate to make
    # current_occupancy a class variable as well
    @carnivores.count == current_occupancy
  end

  # As the only condition on herbivores are the power being on and overcrowding,
  # we only need to track the carnivores
  def survey_carnivores
    # really wanted to use Set here as: 1) it's an amazing class, and under-utlized,
    # and 2) it ignores duplicates automatically...
    # However, given the choice between Array and having to also keep track of
    # herbivores (or another potential db call to see if there are any), I choose Array
    @carnivores = Array.new

    self.dinosaurs.each do |dino_species|
      @carnivores.push(dino_species) if dino_species.species.is_carnivore
    end
  end
end
