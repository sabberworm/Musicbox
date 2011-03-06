class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.int :id
      t.string :relative_path
      t.string :artist_name
      t.string :track_name
      t.string :album_name
      t.int :year
      t.int :track_number
      t.date :last_update
      t.date :last_played
      t.boolean :is_playing
      t.boolean :has_been_updated

      t.timestamps
    end
  end

  def self.down
    drop_table :tracks
  end
end
