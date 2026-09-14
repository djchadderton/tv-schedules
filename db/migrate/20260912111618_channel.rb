class Channel < ActiveRecord::Migration[8.1]
  def change
    create_table :channels do |t|
      t.string :name
      t.string :icon
      t.string :channel_id
    end
  end
end
