# Cages don't need a name, so we just use id as our cage number.
class Cage < ActiveRecord::Base
  #define a scope for simpler filtering/querying
  scope :cage_status_filter, -> (p_status) {where(powered_up: self.status_hash[p_status])}

  #make sure max_occupancy is a positive integer
  validates :max_occupancy, presence: true, numericality: { only_integer: true, greater_than: 0 }
  # many validations don't need to be performed if the cage is empty
  with_options unless: :is_empty? do
    # update the survey of carnivorous species in this cage
    before_validation :survey_carnivores
    # let Ruby do the validation for us....starting with returning
    # nice, customizable errors when a cage would be over-full.
    validates :current_occupancy, numericality: { less_than_or_equal_to: :max_occupancy, \
      message: "Cage is full -- cannot add another dinosaur" }, unless: 'max_occupancy.nil?'
    # prevent powering down cages that aren't empty
    validate :power_safety_status
    validate :happy_cage?
  end

  has_many :dinosaurs, validate: true,  inverse_of: :cage

  attr_reader :current_occupancy
  attr_accessor :powered_up

  # the attributes to display in serialization
  def attributes
    {id: nil, max_occupancy: 5, status: status, current_occupancy: current_occupancy}
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

  # will the dinosaurs get along, without killing and/or eating each other?
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

  # true if the carnivores in this cage will kill each other, false otherwise
  def carnivore_species_fighting?
    @carnivores.uniq.count > 1
  end
  # true if the carnivores in this cage will eat an herbivore, false otherwise
  def carnivore_will_eat_herbivore?
    has_carnivore? and any_herbivores?
  end
  # are there any herbivores in the cage?
  def any_herbivores?
    @carnivores.count < current_occupancy
  end
  #are there any carnivores in the cage?
  def has_carnivore?
    @carnivores.count > 0
  end

  # As the only condition on herbivores are the power being on and overcrowding,
  # we only need to track the carnivores.
  # populates the @carnivores array
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

  def status
    @status = self.class.powered_hash[powered_up]
  end

  # def status=(power_status)
  #   self.powered_up=self.class.status_hash[power_status]
  # end

  #avoid having to type "ACTIVE" and/or "INACTIVE" a bazillion times...
  def self.status_hash
    @status_hash={"ACTIVE"=> true, "INACTIVE"=> false}
  end

  def self.powered_hash
    @powered_hash = {true => "ACTIVE", false => "INACTIVE", nil => "INACTIVE"}
  end

end
