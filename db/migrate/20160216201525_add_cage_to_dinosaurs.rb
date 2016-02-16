class AddCageToDinosaurs < ActiveRecord::Migration
  def change
    add_reference :dinosaurs, :cage, index: true, foreign_key: true
  end
end
