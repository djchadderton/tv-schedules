class AddScheduleUniqueIndexes < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      DELETE FROM programmes
      WHERE id NOT IN (
        SELECT MIN(id)
        FROM programmes
        GROUP BY channel_id, starts_at
      )
    SQL

    add_index :channels, :channel_id, unique: true
    add_index :programmes, [:channel_id, :starts_at], unique: true
  end

  def down
    remove_index :programmes, column: [:channel_id, :starts_at]
    remove_index :channels, :channel_id
  end
end
