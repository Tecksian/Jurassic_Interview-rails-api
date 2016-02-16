class CreateSpecies < ActiveRecord::Migration
  def change
    create_table :species do |t|
      t.string :name
      t.boolean :is_carnivore

      t.timestamps null: false
    end
  end
end
