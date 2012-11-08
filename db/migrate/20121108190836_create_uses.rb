class CreateUses < ActiveRecord::Migration
  def change
    create_table :uses do |t|
      t.string :chemist
      t.integer :amount
      t.references :chemical

      t.timestamps
    end
    add_index :uses, :chemical_id
  end
end
