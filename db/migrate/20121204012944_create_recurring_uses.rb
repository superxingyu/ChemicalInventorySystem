class CreateRecurringUses < ActiveRecord::Migration
  def change
    create_table :recurring_uses do |t|
      t.integer :amount
      t.string :chemist
      t.string :periodicity
      t.date :first_effective_date
      t.date :end_date
      t.references :chemical

      t.timestamps
    end
    add_index :recurring_uses, :chemical_id
  end
end
