class AddSpeciesToDinosaurs < ActiveRecord::Migration
  def change
    add_reference :dinosaurs, :species, index: true, foreign_key: true
  end
end
