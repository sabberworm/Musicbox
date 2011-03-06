class MyVotesController < ApplicationController
  before_filter :satisfy_user
  def satisfy_user
    @user_name = request.parameters['user_name']
    @user_id = User.find(:first, :conditions => ["username = ?", @user_name]).id
  end
  def show_votes
    render :json => {:vote_count => votes_left}
  end
  def reset
    Vote.delete_for_user_id(@user_id)
    render :json => {:reset => true}
  end
  def add
    if(votes_left <= 0) then
      render :json => {:added => false}
    else
      track_id = request.parameters['track_id']
      vote = Vote.find(:first, :conditions => ["user_id = ? AND track_id = ?", @user_id, track_id])
      if vote.nil? then
        vote = Vote.create(:user_id => @user_id, :track_id => track_id, :vote_count => 1)
      else
        vote.vote_count += 1
        vote.save
      end
      render :json => {:added => vote}
    end
  end
  
  private
  def votes_left
    number_of_votes = Setting.get_setting("number_of_votes", 10);
    return number_of_votes-Vote.sum("vote_count", :conditions => ["user_id = ? AND tracks.is_playing = ?", @user_id, false], :joins => "JOIN tracks ON id = track_id").to_i
  end
end