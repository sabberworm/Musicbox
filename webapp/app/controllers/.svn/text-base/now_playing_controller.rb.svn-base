class NowPlayingController < ApplicationController
  def index
    @current = Track.find(:first, :conditions => "is_playing = true", :order => 'last_played')
    if @current.nil? then
      @current = {:message => "Nothing playing"}
    end
    render :json => @current
  end
end
