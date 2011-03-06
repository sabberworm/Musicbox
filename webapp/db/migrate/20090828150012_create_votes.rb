class CreateVotes < ActiveRecord::Migration
  def self.up
    create_table :votes do |t|
      t.int :user_id
      t.int :track_id
      t.int :vote_count

      t.timestamps
    end
  end

  def self.down
    drop_table :votes
  end
end
