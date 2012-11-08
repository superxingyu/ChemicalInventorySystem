class CreateChemicals < ActiveRecord::Migration
  def change
    create_table :chemicals do |t|
      t.string :name
      t.integer :amount
      t.string :cas

      t.timestamps
    end
  end
end
