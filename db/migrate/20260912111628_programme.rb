class Programme < ActiveRecord::Migration[8.1]
  def change
    create_table :programmes do |t|
      t.string :title
      t.string :icon
      t.text :description
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :series
      t.integer :episode
      t.boolean :premiere, default: false
      t.string :channel_id, null: false
    end
  end
end
