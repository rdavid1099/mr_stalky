class CreateTurnipPriceRecords < ActiveRecord::Migration[6.0]
  def change
    create_table :turnip_price_records do |t|
      t.integer :price
      t.date :date
      t.integer :time_period
      t.references :user

      t.timestamps
    end
  end
end
