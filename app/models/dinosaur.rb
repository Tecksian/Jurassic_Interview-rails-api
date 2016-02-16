# Right now, Dinosaurs only have a name.
class Dinosaur < ActiveRecord::Base
  validates :name,
            presence: true,
            # The problem description does not specify unique names, but the alternative
            # is name+species being unique (otherwise nonsense ensues -- in business use, not only code).
            # We choose the easier of the two implied options, if only to avoid sitcom-like confusion!
            uniqueness: true
end

