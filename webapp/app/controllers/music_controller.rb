class MusicController < ApplicationController
  def artist_count
    @count = Track.count(:select => "artist_name", :distinct => true)
    render :json => {:count => @count}
  end
  
  def artists
    start = request.parameters['start']
    length = request.parameters['length']
    @artists = Track.find(:all, :select => "DISTINCT artist_name", :offset => start, :limit => length, :order => "artist_name")
    render :json => @artists
  end
  
  def album_count
    artist_name = request.parameters['artist_name']
    if artist_name.nil?
      @count = Track.count(:select => "album_name", :distinct => true)
    else
      @count = Track.count(:select => "album_name", :distinct => true, :conditions => ["artist_name = ?", artist_name])
    end
    render :json => {:count => @count}
  end
  
  def albums
    start = request.parameters['start']
    length = request.parameters['length']
    artist_name = request.parameters['artist_name']
    if artist_name.nil?
      @albums = Track.find(:all, :select => "DISTINCT album_name", :offset => start, :limit => length, :order => "album_name")
    else
      @albums = Track.find(:all, :select => "DISTINCT album_name", :offset => start, :limit => length, :order => "album_name", :conditions => ["artist_name = ?", artist_name])
    end
    render :json => @albums
  end
  
  def tracks
    start = request.parameters['start']
    length = request.parameters['length']
    artist_name = request.parameters['artist_name']
    album_name = request.parameters['album_name']
    if artist_name.nil?
      if album_name.nil?
        @tracks = Track.find(:all, :conditions => ["is_unplayable = 0"], :order => 'album_name, track_number, track_name')
      else
        @tracks = Track.find(:all, :conditions => ["album_name = ? AND is_unplayable = 0", album_name], :order => 'album_name, track_number, track_name')
      end
    else
      if album_name.nil?
        @tracks = Track.find(:all, :conditions => ["artist_name = ? AND is_unplayable = 0", artist_name], :order => 'album_name, track_number, track_name')
      else
        @tracks = Track.find(:all, :conditions => ["artist_name = ? AND album_name = ? AND is_unplayable = 0", artist_name, album_name], :order => 'album_name, track_number, track_name')
      end
    end
    render :json => @tracks
  end
  
  def next_tracks
    @tracks = Track.find(:all, :select => "*, sum(votes.vote_count) AS vote_count", :joins => "JOIN votes ON tracks.id=votes.track_id", :group => "tracks.id", :order => 'is_playing DESC, vote_count DESC, last_played ASC, tracks.id ASC')
    render :json => @tracks
  end
end
