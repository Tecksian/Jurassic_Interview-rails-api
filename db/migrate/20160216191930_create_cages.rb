class CreateCages < ActiveRecord::Migration
  def change
    create_table :cages do |t|
      t.integer :max_occupancy
      t.boolean :powered_up

      t.timestamps null: false
    end
  end
end
