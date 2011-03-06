class Vote < ActiveRecord::Base
  set_primary_keys :user_id, :track_id
  belongs_to :user
  belongs_to :track
  
  def self.delete_for_user_id(user_id)
    connection.delete("DELETE votes FROM votes JOIN tracks ON votes.track_id = tracks.id WHERE votes.user_id = #{user_id} AND tracks.is_playing = 0;")
  end
end
