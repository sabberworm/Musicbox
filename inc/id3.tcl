namespace eval snack {
  proc sound {args} {
  }
}
###############################################################################
# id3Tag 1.0
#
# ID3 Lookup functions for snackAmp Player in Tcl/Tk
#
# Copyright (C) 2001 Tom Wilkason
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA
#
# Please send any comments/bug reports to
# tom.wilkason@cox.net  (Tom Wilkason)
#
set [file root [file tail [info script]]]_History {
   $Header: /home/fenk/CvsRepository/tcl/xtools/id3.tcl,v 1.1 2004/12/30 23:14:50 fenk Exp $
}
##
# User API: read: id3Label
#           write: id3V1Modify
#
###############################################################################
# Function   : id3 handling routines
# Description: Create tag list for lookup in file
# Author     : Tom Wilkason
# Date       : 2/6/2001
###############################################################################
namespace eval id3Tag {
   variable ID3types
   variable TagIDs
   variable id3v1Lookup
   variable id3v1ReverseLookup
   variable v1Genres
   variable mmMatch "<Edit For Multiple Tracks>"
   variable lastGenre "Not Set"
   variable TableCols
   variable TableJust
   variable TableType
   variable TableWidths
   set ID3types {
     PCNT "PCNT"
     TALB "Album/Movie/Show title"
     COMM "Country"
     TBPM "BPM (beats per minute)"
     TCOM "Composer"
     TCON "Content type"
     TCOP "Copyright message"
     TDAT "Date"
     TDLY "Playlist delay"
     TENC "Encoded by"
     TEXT "Lyricist/Text writer"
     TFLT "File type"
     TIME "Time"
     TIT1 "Content group description"
     TIT2 "Title/songname/content description"
     TIT3 "Subtitle/Description refinement"
     TKEY "Initial key"
     TLAN "Language(s)"
     TLEN "Length"
     TMED "Media type"
     TOAL "Original album/movie/show title"
     TOFN "Original filename"
     TOLY "Original lyricist(s)/text writer(s)"
     TOPE "Original artist(s)/performer(s)"
     TORY "Original release year"
     TOWN "File owner/licensee"
     TPE1 "Lead performer(s)/Soloist(s)"
     TPE2 "Band/orchestra/accompaniment"
     TPE3 "Conductor/performer refinement"
     TPE4 "Interpreted, remixed, or otherwise modified by  "
     TPOS "Part of a set"
     TPUB "Publisher"
     TRCK "Track number"
     TRDA "Recording dates "
     TRSN "Internet radio station name "
     TRSO "Internet radio station owner"
     TSIZ "Size"
     TSRC "ISRC (international standard recording code) "
     TSSE "Software/Hardware and settings used for encoding"
     TYER "Year"
   }
   array set id3v1Lookup {
      0  "Blues"         20  "Alternative"      40  "AlternRock"        60  "Top 40"
      1  "Classic Rock"  21  "Ska"              41  "Bass"              61  "Christian Rap"
      2  "Country"       22  "Death Metal"      42  "Soul"              62  "Pop/Funk"
      3  "Dance"         23  "Pranks"           43  "Punk"              63  "Jungle"
      4  "Disco"         24  "Soundtrack"       44  "Space"             64  "Native American"
      5  "Funk"          25  "Euro-Techno"      45  "Meditative"        65  "Cabaret"
      6  "Grunge"        26  "Ambient"          46  "Instrumental Pop"  66  "New Wave"
      7  "Hip-Hop"       27  "Trip-Hop"         47  "Instrumental Rock" 67  "Psychadelic"
      8  "Jazz"          28  "Vocal"            48  "Ethnic"            68  "Rave"
      9  "Metal"         29  "Jazz+Funk"        49  "Gothic"            69  "Showtunes"
      10 "New Age"       30  "Fusion"           50  "Darkwave"          70  "Trailer"
      11 "Oldies"        31  "Trance"           51  "Techno-Industrial" 71  "Lo-Fi"
      12 "Other"         32  "Classical"        52  "Electronic"        72  "Tribal"
      13 "Pop"           33  "Instrumental"     53  "Pop-Folk"          73  "Acid Punk"
      14 "R&B"           34  "Acid"             54  "Eurodance"         74  "Acid Jazz"
      15 "Rap"           35  "House"            55  "Dream"             75  "Polka"
      16 "Reggae"        36  "Game"             56  "Southern Rock"     76  "Retro"
      17 "Rock"          37  "Sound Clip"       57  "Comedy"            77  "Musical"
      18 "Techno"        38  "Gospel"           58  "Cult"              78  "Rock & Roll"
      19 "Industrial"    39  "Noise"            59  "Gangsta"           79  "Hard Rock"
      80 "Folk"          92  "Progressive Rock" 104 "Chamber Music"     116 "Ballad"
      81 "Folk-Rock"     93  "Psychedelic Rock" 105 "Sonata"            117 "Power Ballad"
      82 "National Folk" 94  "Symphonic Rock"   106 "Symphony"          118 "Rhytmic Soul"
      83 "Swing"         95  "Slow Rock"        107 "Booty Brass"       119 "Freestyle"
      84 "Fast Fusion"   96  "Big Band"         108 "Primus"            120 "Duet"
      85 "Be-bop"        97  "Chorus"           109 "Porn Groove"       121 "Punk Rock"
      86 "Latin"         98  "Easy Listening"   110 "Satire"            122 "Drum Solo"
      87 "Revival"       99  "Acoustic"         111 "Slow Jam"          123 "A Capela"
      88 "Celtic"        100 "Humour"           112 "Club"              124 "Euro-House"
      89 "Bluegrass"     101 "Speech"           113 "Tango"             125 "Dance Hall"
      90 "Avantgarde"    102 "Chanson"          114 "Samba"
      91 "Gothic Rock"   103 "Opera"            115 "Folklore"
   }
   ;# Order shown on editor
   set v1Parts {
      "Title"
      "Artist"
      "Album"
      "Year"
      "Note"
      "Track"
      "SubGenre"
      "Genre"
   }
   foreach {index value} [array get id3v1Lookup] {
      lappend v1Genres $value
      set id3v1ReverseLookup($value) $index
   }
   set v1Genres [lsort $v1Genres]
   set TagIDs      [list Artist Title Album Track Media Year Genre Note Comp Enc Desc]
   ;# TFW: This s/b moved to table namespace
   set TableCols   [list Key        Folder     File       Title      Artist     Album      Track      Media      Year    Genre      Note       Comp       Enc        Desc       Rate    Sample  Duration Size    Date  Gain       Tag]
   set TableWidths [list 0          25         40         28         20         20         0          0          0       0          25         0          0          25         0       0       0        0       0     0          0]
   set TableJust   [list right      left       left       left       left       left       right      left       right   left       left       left       left       left       right   right   right    right   right right      right]
   set TableType   [list dictionary dictionary dictionary dictionary dictionary dictionary dictionary dictionary integer dictionary dictionary dictionary dictionary dictionary integer real    timify   commify ascii dictionary ascii]
   set TableEdit   [list 0          0          1          1          1          1          1          1          1       1          1          1          0          0          0       0       0        0       0     0          0]
   variable mySound [snack::sound -debug 0]
}

;##
;#
;#
set todo {
   - Get true size of V2 tag and read that much
}

##
# Return the offset to the start of music so the ID3V2 tag can
# be skipped by a streaming server
#
proc id3Tag::id3V2Offset {fid} {
   ;# Have ID, get data
   fconfigure $fid -translation binary
   if {[catch {set block [read $fid 10]}] } then {
      return -code error $result
   }
   if {[catch {seek $fid 0 start} result] } then {
      return 0
   }
   ;##
   ;# If this is an ID3 V2, need offset to start of stream
   ;#
   if {[string range $block 0 2] == "ID3"} {
      ;# Determine the frame length and read the rest of the id3 header
      binary scan [string range $block 6 9] "c1c1c1c1" a b c d
      set length [expr {$a*2097152 + $b*16384 + $c*128 +$d}]
      if {$length < 0} {
         return 0
      } else {
         return $length
      }
   }
   return 0
}
###############################################################################
# Function   : ideTag::id3V2Get
# Description: Return a V2 tag from using a file name, a list of all known fields
# Author     : Tom Wilkason
# Date       : 3/17/2002
###############################################################################
proc id3Tag::id3V2Get {file} {
   variable ID3types
   array set result {}
   if {[catch {set fid [open $file r]}]} {
      return [array get result]
   }
   ;# Have ID, get data
   fconfigure $fid -translation binary
   if {[catch {set block [read $fid 10]}] } then {
      close $fid
      return [array get result]
   }

   if {[string range $block 0 2] == "ID3"} {
      set Pairs [list]
      ;# Determine the frame length and read the rest of the id3 header
      binary scan [string range $block 6 9] "c1c1c1c1" a b c d
      set length [expr {$a*2097152 + $b*16384 + $c*128 +$d}]
      if {$length <= 0} {
         close $fid
         return [list]
      }
      set block [read $fid $length]
      ;# Scan for tags and save their location
      foreach {type description} $ID3types {
         set lookup($type) [string trim $description]
         set loc [string first $type $block]
         if {$loc >= 0} {
            lappend Pairs [list $type $loc]
         }
      }
      ;# Sort by first to last and build up a list of the start
      ;# and end position of each tag then extract it and add
      ;# its description and the tag data to a list
      set newPairs [lsort -index 1 -integer $Pairs]
      for {set i 0} {$i < [llength $newPairs]} {incr i} {
         set loc1 [lindex [lindex $newPairs $i] 1]
         set loc2 [lindex [lindex $newPairs [expr {$i+1}]] 1]
         if {$loc2==""} {
            set loc2 [expr {$loc1+60}]       ;#last tag
         }
         set nam1 [lindex [lindex $newPairs $i] 0]
         ;# Extract the tag with any codes
         set String [string range $block [expr {$loc1 + 4+7}] [expr {$loc2 - 1}]]
         ;# Clean up result
         set String [id3Clean $String]
         set result($nam1) $String
      }
      set result("Tag") V2
   }
   close $fid
   return [array get result]
}
#{TITLE=Lookin' Out The Window (live)}
#{ARTIST=Stevie Ray Vaughan And Double Trouble}
#{ALBUM=Stevie Ray Vaughan And Double Trouble (Box Set)}
#{GENRE=Blues}
#{DATE=2000}
#{COMMENT=Another Comment}
#{TRACKNUMBER=1}
##
# Retrieve ogg data for a file
#
proc id3Tag::id3oggGet {file} {
   variable mySound
   variable id3v1Lookup
   $mySound config -file $file
   array set result {}
   if {[catch {$mySound config -comment} data] } then {
      return [list]
   } else {
      foreach {entry} $data {
         foreach {tag value} [split $entry =] {
            set value [id3Clean $value]
            switch -- [string tolower $tag] {
               "title"       {set result("TIT2") $value}
               "artist"      {set result("TPE1") $value}
               "album"       {set result("TALB") $value}
               "genre"       {set result("TCON") $value}
               "date"        {set result("TYER") $value}
               "tracknumber" {set result("TRCK") $value}
               "comment"     {set result("TIT3") $value}
               default {}
            }
         }
      }
      set result("Tag") OGG
   }
   return array get result
}
###############################################################################
# Function   : ideTag::id3V1Get
# Description: Return a V1 tag from using a file name, a list of known fields
# Author     : Tom Wilkason
# Date       : 3/17/2002
###############################################################################
proc id3Tag::id3V1Get {file} {
   variable id3v1Lookup
   array set result {}
   if {[catch {set fid [open $file r]} ec]} {
      return [list]
   }
   fconfigure $fid -translation binary
   ;##
   ;# ID3V1.2 tags are in the last 256 bytes of the file in a fixed format
   ;#
   if {[catch {seek $fid -256 end} ec] } {
      close $fid
      return [list]
   }
   if {[catch {set block [read $fid 256]} ec] } then {
      close $fid
      return [list]
   }
   close $fid
   binary scan $block "a3 a30 a30 a30 a15 a20 a3 a30 a30 a30 a4 a28 ccc" \
      ext extTitle extArtist extAlbum extComment extGenre \
      id title artist album  year comment zero track genre
   ;# Support ID3V1.2 Extensions
   if {[string equal $ext "EXT"]} {
      set title  "[id3Clean $title][id3Clean $extTitle]"
      set artist "[id3Clean $artist][id3Clean $extArtist]"
      set album  "[id3Clean $album][id3Clean $extAlbum]"
      set comment  "[id3Clean $comment][id3Clean $extComment]"
   }
   if {[string equal $id "TAG"]} {
      set result("TIT2") [id3Clean $title]
      set result("TPE1") [id3Clean $artist]
      set result("TALB") [id3Clean $album]
      set result("TYER") [id3Clean $year]
      set result("TIT3") [id3Clean $comment]
      ;# V1.1 spec allows last comment string to be the track, if not then a comment
      if {$track==0 || $zero != 0} {
         set track ""
      } elseif {[string is integer -strict $track]} {
         set track [expr {($track + 0x100) % 0x100}]
      } else {
         set track ""
      }
      set result("TRCK") $track
      ;# Sub Genre and tag type
      if {[string equal $ext "EXT"]} {
         set result("TPOS") [id3Clean $extGenre]
      }
      if {![catch {set Genre $id3v1Lookup($genre)}]} {
         set result("TCON") $Genre
      } else {
         set result("TCON") $id3v1Lookup(12)
      }
   }
   return [array get result]
}
###############################################################################
# Function   : id3Tag::cleanTrack
# Description: Format a track with atleast two digits
# Author     : Tom Wilkason
# Date       : 10/12/2002
###############################################################################
proc id3Tag::cleanTrack {track} {
   if {[catch {format "%2.2d" [string trimleft $track 0]} Track] } then {
      return $track
   } else {
      return $Track
   }
}
proc id3Tag::isogg {file} {
   return [string equal -nocase [file extension $file] ".ogg"]
}
##
# Update the Ogg tag with new data (if needed)
#
proc id3Tag::id3oggModify {file _Data} {
   variable mySound
   $mySound config -file $file
   set oldTag [lsort [$mySound config -comment]]
   upvar $_Data Data
   parray Data
   set newTag [list]
   foreach {idTag oggTag} {
      Title  TITLE
      Artist ARTIST
      Album  ALBUM
      Track  TRACKNUMBER
      Genre  GENRE
      Note   COMMENT
      Year   DATE
   } {
      if {[info exists Data($idTag)]} {
         lappend newTag "$oggTag=$Data($idTag)"
      }
   }
   set newTag [lsort $newTag]
   if {![string equal $oldTag $newTag]} {
      $mySound config -comment $newTag
   }
   $mySound config -file ""
   return 1
}
###############################################################################
# Function   : id3V1Modify
# Description: Modify the ID3V1 tag of a file
# Author     : Tom Wilkason
# Date       : 2/7/2001
###############################################################################
proc id3Tag::id3V1Modify {file _Data} {
   upvar $_Data Data
   variable v1Parts
   variable id3v1Lookup
   variable id3v1ReverseLookup
   variable mmMatch
   variable lastGenre
   ##
   # Handle ogg data here
   #
#   if {[string equal -nocase [file extension $file] ".ogg"]} {
#      id3oggModify $file Data
#      return
#   }
   ;##
   ;# Read in current ID3 data then compare to determine if any changes were made
   ;#
   set tagExists [id3Label $file id3V1Data V1]
   if {!$tagExists} {
      if {[isogg $file]} {
         if {[id3Label $file id3altData ogg]} {
            array set id3V1Data [array get id3altData]
         }
      } else {
         if {[id3Label $file id3altData V2]} {
            array set id3V1Data [array get id3altData]
         }
      }
      set offset 0
   } else {
      ;# V1 or V1.2 Data
      if {$id3V1Data(Tag)=="V1.2" && $::snackAmpSettings(ID3V12)} {
         set offset -256
      } else {
         set offset -128
      }
   }
   set diff 0
   ;# Check each field
   foreach {element} $v1Parts {
      ;##
      ;# If tags don't match or incoming tag has data and existing tag doesn't
      ;#
      if {[hasData Data $element]} {
         if {[hasData id3V1Data $element] && ![string equal $id3V1Data($element) $Data($element)]} {
            ;# Both have data, but different
            set diff 1
         } elseif {![hasData id3V1Data $element]} {
            ;# New incoming field
            set diff 1
         }
         ;# For multi-match tags, either replace or discard them
         ;# Ignore the < Match > fields, use existing data
         ;# Note: TFW If id3V1Data($element) doesn't exist (new tag) then what should we do? Use blanks?
         if {$Data($element) == $mmMatch} {
            if {[info exists id3V1Data($element)]} {
               ;# Use existing data (not the multi-patch string)
               set Data($element) $id3V1Data($element)
            } else {
               ;# Don't write that portion of tag
               set Data($element) ""
            }
         }
      } elseif {[info exists id3V1Data($element)]} {
         ;# Incoming blank, copy over existing if it exists
         set Data($element) $id3V1Data($element)
      } else {
         ;# Otherwise just blank it out
         set Data($element) ""
      }
   }
   ;##
   if {$diff == 0} {
      return
   }
   ;##
   ;# We know we have changes, ready for write
   ;#
   if {![file writable $file] || $::snackAmpSettings(ID3ReadOnly)} {
      tk_messageBox -type ok -icon warning -message "You don't have write permission for $file"
      return {}
   }
   set mtime [file mtime $file]
   if {[catch {set fid [open $file r+]}]} {
      tk_messageBox -type ok -icon warning -message "Could not open file $file for writing"
      return {}
   }
   fconfigure $fid -translation binary
   if {[catch {seek $fid $offset end} result] } {
      close $fid
      return
   }
   ;##
   ;# Handle Genre, default to 12 (Other)
   set genre $Data(Genre)
   if {[info exists id3v1ReverseLookup($genre)]} {
      set Genre $id3v1ReverseLookup($genre)
      set lastGenre $genre
   } else {
      set Genre 12
   }

   ;##
   ;# Handle Track, use zero (blank) if not valid, don't interpret
   ;# octal numbers as octal
   set Track [string trimleft $Data(Track) 0]
   if {[string is integer -strict $Track]} {
      set T c
   } else {
      set Track "\0"
      set T a
   }
   ;##
   ;# Write either V1 or V1.2 Tags
   if {$::snackAmpSettings(ID3V12)} {
      ;# Support ID3V1.2 Extensions
      foreach {item start} {
         Title 30 Artist 30 Album 30 Note 28 SubGenre 0
      } {
         set ext($item) [string range $Data($item) $start end]
      }
      set fstring "a3 a30 a30 a30 a15 a20 a3 a30 a30 a30 a4 a28 c${T} c"
      set block [binary format $fstring \
         EXT $ext(Title)   $ext(Artist)  $ext(Album) $ext(Note) $ext(SubGenre) \
         TAG $Data(Title) $Data(Artist) $Data(Album) $Data(Year) $Data(Note) 0 $Track $Genre]
   } else {
      set fstring "a3 a30 a30 a30 a4 a28 c${T} c"
      set block [binary format $fstring \
         TAG $Data(Title) $Data(Artist) $Data(Album) $Data(Year) $Data(Note) 0 $Track $Genre]
   }
   puts -nonewline $fid $block
   close $fid
   ;##
   ;# Restore the old timestamp if needed
   if {$::snackAmpSettings(preserveTime)} {
      if {[catch {file mtime $file $mtime} result] } then {
      }
   }
}
###############################################################################
# Function   : id3Tag::removeTag
# Description: Remove a tag from a file it one exists
#              Does not work, tcl won't truncate
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::removeTag {files} {
   foreach {file} $files {
      if {[catch {set fid [open $file r+]}]} {
         tk_messageBox -type ok -icon warning -message "Could not open file $file for writing"
         return {}
      }
      fconfigure $fid -translation binary
      ;##
      ;# Now check for ID3V1 tags, these are much easier
      ;# Return codes for ID3V2 so only one tag type is dealt with
      ;# ID3V1 tags are in the last 128 bytes of the file in a fixed format
      if {[catch {seek $fid -128 end} result] } {
         close $fid
         return
      }
      ;# TFW: Here is where we know if a tag exists
      set block [read $fid 128]
      if {[string range $block 0 2] != "TAG"} {
         ;# No Tag
         seek $fid 0 end
      } else {
         ;# Has a tag, close will truncate here
         seek $fid -128 end
      }
      ;# Note: This function does not really truncate the file.
      close $fid
   }
}
###############################################################################
# Function   : id3Tag::padTo
# Description: Pad/truncate a string to some length
# Author     : Tom Wilkason
# Date       : 3/17/2002
###############################################################################
proc id3Tag::padTo {string len} {
   return [string range [format "%-${len}s" $string] 0 [incr len -1]]
}
###############################################################################
# Function   : id3Editor
# Description: Window to edit the ID3 info for a file
# Author     : Tom Wilkason
# Date       : 2/8/2001
###############################################################################
proc id3Tag::id3Editor {fnames} {
   set i 0
   variable v1Parts
   variable id3v1Lookup
   variable editData
   variable mmMatch
   foreach fname $fnames {
      if {![file exists $fname]} {
      }
   }
   switch -- [llength $fnames] {
      0 {
         tk_messageBox -type ok -icon warning -message "No files specified"
         return
      }
   }
   set here [focus]
   ;# Get a unique window, note $W is also a global variable
   ;# holding stuff for this instance of the GUI
   while {[winfo exists .ide$i]} {incr i}
   set W .ide$i
   upvar #0 $W data
   toplevel $W -cursor $::TA(arrow)
   wm protocol $W WM_DELETE_WINDOW "destroy $W;unset ::$W"
   ;# get current data and line to global with the same name
   ;# as this widget (to allow multiple editors at once)
   ;# Save current file name
   ;##
   ;# Determine if one or multiple files are being edited, behaviour
   ;# is different for multi-edits
   ;#
   if {[llength $fnames] == 1} {
      set multiEdit 0
      wm title $W $fname
   } else {
      set multiEdit 1
      wm title $W "Editing [llength $fnames] tracks"
   }
   set useFnames [list]
   ;# Note: The ${W}(tag) represent what goes into the GUI fields
   foreach fname $fnames {
      catch {unset fnameData}
      set hasTag [id3Label $fname fnameData]
      if {$::snackAmpSettings(ID3OKCreate)==0 && ([llength $fnames] > 1 && $hasTag == 0)} {
         ;##
         ;# Remove file name from consideration
         ;#
         continue
      } else {
         lappend useFnames $fname
      }
      ;# Note: TFW, files with no tag data don't set the multi-match field!! fnameData is blank!!
      ;# Bug, if all but one are blank then the non-blank field will be used instead of multi-match
      foreach {retField} $v1Parts {
         ;# If previously found one, see if it is different
         set fTag [blankForNull fnameData $retField]
         if {[info exists data($retField)]} {
            ;# Set to multi match tag if all the fields are not the same.
            if {![string equal $data($retField) $fTag]} {
               set data($retField) $mmMatch
            }
         } else {
            ;# First time check, use actual data
            set data($retField) $fTag
         }
      }
   }
   ;# Get V2 unique data so user can copy it over (if one file selected)
   if {! $multiEdit} {
      set data(fname) $fnames
      ;# This is a bug AFAIAK, file commands don't work if item is a single list length
      set ftest [lindex $fnames 0]
      if {[isogg $fname]} {
         id3Label $fname id3altData ogg
         set altTag "OGG"
      } else {
         id3Label $fname id3altData V2
         set altTag "ID3V2"
      }
   } else {
      set altTag "Not Shown"
      ;##
      ;# Only edit files with existing tags unless
      ;# no files have tags, then use them.
      ;#
      if {[llength $useFnames] == 0} {
         set data(fname) $fnames
      } else {
         set data(fname) $useFnames
      }
   }
   ;##
   ;# Build the GUI
   ;#
   set i 0
   set span 5

   ;# header
   grid [label $W.tag -text "Field"] [label $W.v2 -text "$altTag Tag"] x [label $W.v1 -text "ID3V1 Tag"]

   ;# Rows of all editable fields
   foreach {Index} $v1Parts {
      if {![info exists id3altData($Index)]} {
         set id3altData($Index) {}
      }
      label $W.v2lb$Index -text $id3altData($Index) \
         -anchor w -relief sunken -width 40
      balloon::define $W.v2lb$Index "$altTag Data for $Index"

      button $W.v2bt$Index -bd 0 -image NavForward \
         -command [list set ::${W}($Index) $id3altData($Index)]
      balloon::define $W.v2bt$Index "Copy $altTag Data '$id3altData($Index)' to V1 $Index field"

      label $W.lb$Index -text $Index -anchor w
      if {$Index=="Genre"} {
         if {![info exists data($Index)] || $data($Index)==""} {
            set data($Index) "Not Set"
         }
         ;# Make a cascaded menu like font names (or reduce options)
         menubutton $W.en$Index -relief raised -indicatoron 1 -pady 0 \
            -textvariable ::${W}($Index) -menu $W.en$Index.menu -direction flush
         balloon::define $W.en$Index "Click to select a genre"
         widgetWatch::setWatch $W.en$Index ::${W}($Index)
         menu $W.en$Index.menu \
            -postcommand [list id3Tag::postGenreNames $W.en$Index.menu ::${W}($Index)] -tearoff 0
      } else {
         entry $W.en$Index -textvariable ::${W}($Index) -width 50
         widgetWatch::setWatch $W.en$Index ::${W}($Index)
         balloon::define $W.en$Index "ID3V1 Data for $Index"
      }
      if {[lsearch -exact [list Artist Album Title] $Index] > -1} {
         button $W.http$Index -bd 0 -image web -command [list browser::allMusic ::${W}($Index) $Index]
         balloon::define $W.http$Index "Search the All Music Guide web site for $Index information"
         grid $W.lb$Index $W.v2lb$Index $W.v2bt$Index $W.en$Index $W.http$Index -sticky ew
      } else {
         grid $W.lb$Index $W.v2lb$Index $W.v2bt$Index $W.en$Index -sticky ew

      }
   }
   ;##
   ;# Rename file based on tag
   ;#
   if {! $multiEdit} {
      button $W.lbTag2File -text "Rename File" -font menu \
         -relief raised -command [list id3Tag::id3Rename ::${W}(fname) $W.enTag2File]
      balloon::define $W.lbTag2File "Push this to Rename the file to the name on the right"
      set data(newName) [file root [file tail $data(fname)]]
      entry $W.enTag2File -textvariable ::${W}(newName)
      widgetWatch::setWatch $W.enTag2File ::${W}(newName)

      grid $W.lbTag2File $W.enTag2File - - -sticky ew

      ;##
      ;# If a URL shortcut, put that info in also
      ;#
      if {[playurl::isusk $ftest]} {
##         set data(URL) [HttpD::Decode [playurl::readurl $ftest]]
         set data(URL) [playurl::readurl $ftest]
         label $W.lbURL -text "Change URL" -font menu
         balloon::define $W.lbURL "Change the URL this URL shortcut refers to"
         set data(newURL) $data(URL)
         entry $W.enlbURL -textvariable ::${W}(newURL)
         widgetWatch::setWatch $W.enlbURL ::${W}(newURL)
         grid $W.lbURL $W.enlbURL - - -sticky ew
      }
   }

   grid columnconfigure $W 1 -weight 1
   grid columnconfigure $W 3 -weight 2
   ;# Line
   grid [frame $W.l[incr i] -height 2 -borderwidth 3 -relief sunken] -pady 3 -columnspan 5 -sticky nsew
   ;##
   ;# Frame for OK/Cancel/Apply buttons
   ;#
   grid [frame $W.but] -columnspan 5

   button $W.but.lbcddb -text "Freedb Query" -font menu \
      -command [list browser::cddb ::$W] \
      -borderwidth 1  -relief raised
   balloon::define $W.but.lbcddb "Push this to guess a file name based on the tag"
   if {! $multiEdit} {
      ;##
      ;# Tag file based on name
      ;#
      button $W.but.lbMakeFname -text "Guess Name" -font menu \
         -command [list id3Tag::guessFileName ::$W newName] \
         -borderwidth 1  -relief raised
      balloon::define $W.but.lbMakeFname "Push this to guess a file name based on the tag"

      button $W.but.lbFile2Tag -text "Guess Tag" -font menu \
         -command [list id3Tag::cbSmartTagName ::${W}(fname) ::$W] \
         -borderwidth 1  -relief raised
      balloon::define $W.but.lbFile2Tag "Push this to create a tag based on the file name"
   }
   #fix
   set fix [button $W.but.[incr i] -width 8 -font menu -text "Fix Case" -relief raised \
      -command [list id3Tag::id3SingleTagToNameFix ::$W] -borderwidth 1  -relief raised]
   balloon::define $fix "Push this to automatically correct file name spacing and capitalization"

   ;# Apply and close
   set ok [button $W.but.[incr i] -width 8 -font menu -text "OK" \
      -command [list id3Tag::cbModify ::${W}(fname) $W 1] \
      -borderwidth 1  -relief raised]
   balloon::define $ok \
   "Push this to apply and save the current settings then close this dialog\n[join [set ::${W}(fname)]\n]"

   ;# Apply
   set app [button $W.but.[incr i] -width 8 -font menu -text "Apply" \
      -command [list id3Tag::cbModify ::${W}(fname) $W 0] \
      -borderwidth 1  -relief raised]
   balloon::define $app "Push this apply and save the current settings\n[join [set ::${W}(fname)]\n]"

   ;# Cancel
   set can [button $W.but.[incr i] -width 8 -font menu -text "Cancel" \
      -command "destroy $W;unset ::$W" \
      -borderwidth 1 -relief raised]
   balloon::define $can "Push this to ignore changes made and restore the previous settings"

   if {! $multiEdit} {
      grid $W.but.lbcddb $W.but.lbMakeFname $W.but.lbFile2Tag $fix $ok $app $can  -padx 10 -pady 2
   } else {
      grid $W.but.lbcddb $fix $ok $app $can  -padx 10 -pady 2
   }
   ;##
   ;# Key bindings
   ;#
   bind $W <Return> [list $ok invoke]
   bind $W <Escape> [list $can invoke]
   ontop::pinOnSystemMenu {} $W
   update idletasks
   myIcon $W
   focus $W
}
###############################################################################
# Function   : blankForNull
# Description: Return a blank or real data for some array element
#
# Author     : Tom Wilkason
###############################################################################
proc blankForNull {_Data element} {
   upvar $_Data Data
   if {[info exists Data($element)]} {
      return $Data($element)
   } else {
      return ""
   }
}

###############################################################################
# Function   : id3NameToTag
# Description: Window to edit the proposed tag names based on file name data
# Author     : Tom Wilkason
# Date       : 2/8/2001
;# TFW: Flag the fields if the name changes, need function to compare entire tags
###############################################################################
proc id3Tag::id3NameToTag {fnames {smart 0}} {
   set i 0
   set tr 0
   variable v1Parts
   variable id3v1Lookup
   variable editData
   variable mmMatch
   if {[llength $fnames] == 0} {
      tk_messageBox -type ok -icon warning -message "No files specified"
      return
   }
   foreach fname $fnames {
      if {![file exists $fname]} {
      }
   }
   set here [focus]
   ;# Get a unique window, note $W is also a global variable
   ;# holding stuff for this instance of the GUI
   while {[winfo exists .ntIdent$i]} {incr i}
   set W .ntIdent$i
   upvar $W MyVal
   toplevel $W -cursor $::TA(arrow)
   if {$smart} {
      wm title $W "Name To Tag Editor"
   } else {
      wm title $W "ID3 Table Editor"
   }
   wm protocol $W WM_DELETE_WINDOW "destroy $W;unset ::$W"
   ;# get current data and line to global with the same name
   ;# as this widget (to allow multiple editors at once)
   ;# Save current file name
   ;# Note: The ${W}($fname,tag) represent what goes into the GUI fields
   ;##
   ;# Build the GUI
   ;#
   if {[llength $fnames] > 8} {
      set hull [scrolledFrame::Frame $W.data -initHeight $::snackAmpSettings(scrolledCanvasHeight)]
   }  else {
      set hull [frame $W.data]
   }
   set span 6
   ;# Genre menubutton
   ;# Artist and Albmum menu buttons
   foreach {Type} [list Artist Album Genre] {
      set ::${W}($Type) "$Type"
      set mb [menubutton $hull.lb$Type -pady 2 -relief raised -indicatoron 1 \
          -text [set ::${W}($Type)] -menu $hull.lb$Type.menu -direction flush -width 10 -font entry]
      balloon::define $mb "Click to select a common $Type for all files"
      if {$Type=="Genre"} {
         menu $mb.menu \
            -postcommand [list id3Tag::postGenreNames $mb.menu ::${W}($Type)] -tearoff 0
      } else {
         menu $mb.menu \
            -postcommand [list id3Tag::postTypeNames $mb.menu ::${W} $Type] -tearoff 0
      }
      trace variable ::${W}($Type) w id3Tag::commonType
      ;# When variable is updated during postcommand, call commonType to set others to same
   }

   ;# Grid out the labels
   grid \
        [label $hull.lb[incr i] -text "Guess"] \
        [label $hull.lb[incr i] -text "Change"]  \
        $hull.lbArtist \
        $hull.lbAlbum  \
        [label $hull.lb[incr i] -text "Title"] \
        [label $hull.lb[incr i] -text "Track"] \
        $hull.lbGenre
   set i 0
   ;##

   ;# Build one row for each file
   ;#
   set tag 0
   ;# Data
   set ent 1
   foreach fname $fnames {
      set toGrid [list]
      ;# Get existing tag data
      ;# Determine data from parsed name
      ;# Only updates entries where
      ;# the file name provides it
      foreach {field} {Artist Album Title Track Genre} {
         set fnameData($field) ""
      }
      ;# Build smart tag if desired
      if {$smart} {
         ;# TFW: Todo Indicate in entry box if the data has been changed
         ;# Between ID tag and proposed tag data
         cbSmartTagName fname fnameData
      }
      ;# Overlay with existing ID3 data
      set hasTag [id3Label $fname fnameData]
      set ::${W}($tag,oldFullName) $fname
      foreach {field} {Artist Album Title Track Genre} {
         set ::${W}($tag,$field) $fnameData($field)
      }
      ;# Default to true
      set ::${W}($tag,ok) 1
      lappend toGrid [button $hull.bt[incr i] -relief raised -pady 0 -text "Guess Tag" \
         -command [list id3Tag::cbOneSmartTagName $fname $tag ::${W}]]
      balloon::define $hull.bt$i "Press this to guess the tags for \n$fname"

      lappend toGrid [checkbutton $hull.en[incr i] -variable ::${W}($tag,ok) -font {Helvetica 5}]
      balloon::define $hull.en$i "Check this to have OK/Apply modify the tag in \n$fname"
      foreach {field width} {Artist 28 Album 28 Title 28 Track 3} {
         set item [entry $hull.en$field$ent -width $width -textvariable ::${W}($tag,$field)]
         widgetWatch::setWatch $item ::${W}($tag,$field)
         lappend toGrid $item
         balloon::define $item "Modify $field data then press OK or Apply to make the change. Ctrl-N to auto number."
         if {$field=="Track"} {
              ;# Bind Control N to track to auto number those below
              bind $item <Control-n> [list id3Tag::id3NameToTagNumTrack $hull $ent]
         }
      }
      incr ent
      ;# Make a cascaded menu like font names (or reduce options)
      set mb [menubutton $hull.en[incr i] -pady 2 -relief raised -indicatoron 1 \
         -textvariable ::${W}($tag,Genre) -menu $hull.en$i.menu -direction flush -width 10]
      balloon::define $mb "Click to select a genre"
      menu $mb.menu \
         -postcommand [list id3Tag::postGenreNames $mb.menu ::${W}($tag,Genre)] -tearoff 0
      widgetWatch::setWatch $mb ::${W}($tag,Genre)
      lappend toGrid $mb
      eval grid $toGrid -sticky ew
      incr tag
   }

   grid columnconfigure $hull 2 -weight 1
   grid columnconfigure $hull 3 -weight 1
   grid columnconfigure $hull 4 -weight 1
   ;##
   ;# Frame for OK/Cancel/Apply buttons
   ;#
   pack [frame $W.but] -fill x -expand false -side bottom
   ;# Line
   pack [frame $W.l[incr i] -height 2 -borderwidth 3 -relief sunken] -fill x -expand false -side bottom
   ;# Data
   pack $W.data -side top -expand true -fill both

   ;# Check All
   set checkAll [button $W.but.[incr i] -font menu -text "Check All" \
      -command [list id3Tag::cbSetOK ::$W 1] \
      -borderwidth 1  -relief raised]
   balloon::define $checkAll "Push this to check all checkboxes"

   ;# Check None
   set checkNone [button $W.but.[incr i] -font menu -text "Check None" \
      -command [list id3Tag::cbSetOK ::$W 0] \
      -borderwidth 1  -relief raised]
   balloon::define $checkNone "Push this to un-check all checkboxes"

   ;# Guess Tags
   set guessTags [button $W.but.[incr i] -font menu -text "Guess Tags" \
      -command [list id3Tag::cbManySmartTagName ::$W] \
      -borderwidth 1  -relief raised]
   balloon::define $checkNone "Push this guess tags based on the file name"

   ;# Apply and close
   set ok [button $W.but.[incr i] -width 8 -font menu -text "OK" \
      -command [list id3Tag::cbNameToTag ::$W 1] -borderwidth 1  -relief raised]
   balloon::define $ok "Push this to apply and save the current settings then close this dialog"
   ;# Apply
   set app [button $W.but.[incr i] -width 8 -font menu -text "Apply" \
      -command [list id3Tag::cbNameToTag ::$W 0] \
      -borderwidth 1  -relief raised]
   balloon::define $app "Push this apply and save the current settings"

   ;# Cancel
   set can [button $W.but.[incr i] -width 8 -font menu -text "Cancel" \
      -command "destroy $W;unset ::$W" \
      -borderwidth 1 -relief raised]
   balloon::define $can "Push this to ignore changes made and restore the previous settings"
   grid $checkAll $checkNone $guessTags $ok $app $can  -padx 10 -pady 2
   ;##
   ;# Key bindings
   ;#
   bind $W <Return> [list $ok invoke]
   bind $W <Escape> [list $can invoke]

   ontop::pinOnSystemMenu {} $W
   update idletasks
   myIcon $W
   focus $W
}
;##
;# Option menu that takes a list
;#
proc listOptionMenu {w varName choices} {
   upvar #0 $varName var
   menubutton $w -textvariable $varName -indicatoron 1 -menu $w.menu \
   -relief raised  -anchor c \
   -direction flush
   menu $w.menu -tearoff 0
   foreach i $choices {
      if {![info exists var]} {
         set var $i
      }
      $w.menu add radiobutton -label $i -variable $varName
   }
   return $w.menu
}

###############################################################################
# Function   : id3Tag::id3NameToTagNumTrack
# Description: Auto number tracks below based on this one
#
# Author     : Tom Wilkason
###############################################################################
#     bind $hull.lb$i <Control-n> [list id3Tag::id3NameToTagNumTrack $hull.lb $i]
proc id3Tag::id3NameToTagNumTrack {hull index} {
   set len [string length $hull.enTrack]
   set start 1
   foreach {entry} [lsort -dictionary [winfo children $hull]] {
      if {[string match $hull.enTrack* $entry]} {
         set enIndex [string range $entry $len end]
         set gvalue [$entry cget -textvariable]
         if {$enIndex == $index} {
            set start [set $gvalue]
            if {![string is integer -strict $start]} {
               set start 1
               set $gvalue $start
            }
         } elseif {$enIndex >= $index} {
            incr start
            set $gvalue $start
         }
      }
   }
}

###############################################################################
# Function   : id3Tag::commonType
# Description: Callback to change all genres for block editor
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::commonType {_Glob Element args} {
   upvar $_Glob Glob
   set value $Glob($Element)
   foreach {item} [array names Glob "*,$Element"] {
      ;# Traced, use full global name
      set ${_Glob}($item) $value
   }
}
###############################################################################
# Function   : id3Tag::cbNameToTag
# Description: Retag a set of files
#
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::cbNameToTag {_W {close 0}} {
   upvar #0 $_W W
   ;# Process each file that is checked
   foreach {element} [lsort [array names W *,ok]] {
      ;# If checkbox checked, try to rename it
      if {$W($element)} {
         set tag [lindex [split $element ,] 0]
         set fname $W($tag,oldFullName)
         ;# Blank then Get existing data
         foreach {field} {Artist Album Title Track Comment} {
            set fnameData($field) ""
         }
         id3Label $fname fnameData V1
         set changed 0
         foreach {field} {Artist Album Title Track Genre} {
            ;# Copy in only existing non-blank data
            if {[info exists W($tag,$field)] && [string length $W($tag,$field)] > 0} {
               set fnameData($field) $W($tag,$field)
               incr changed
            }
         }
         ;# Don't bother to update if the data hasn't changed
         if {$changed && $::snackAmpSettings(ID3ReadOnly)==0} {
            id3V1Modify $fname fnameData
         }
      }
   }
   ;# If close widget when done indicated.
   if {$close} {
      destroy [string trimleft $_W :]
      unset $_W
   }
}
###############################################################################
# Function   : id3TagToName
# Description: Window to edit the proposed file names based on tag data
# Author     : Tom Wilkason
# Date       : 2/8/2001
;# TFW: Flag the fields if the name changes
###############################################################################
proc id3Tag::id3TagToName {fnames} {
   set i 0
   variable v1Parts
   variable id3v1Lookup
   variable editData
   variable mmMatch
   global fnameData ;# Note, due to upvar #0, TFW Fix later
   if {[llength $fnames] == 0} {
      tk_messageBox -type ok -icon warning -message "No files specified"
      return
   }
   foreach fname $fnames {
      if {![file exists $fname]} {
      }
   }
   set here [focus]
   ;# Get a unique window, note $W is also a global variable
   ;# holding stuff for this instance of the GUI
   while {[winfo exists .tnIdent$i]} {incr i}
   set W .tnIdent$i
   toplevel $W -cursor $::TA(arrow)
   wm title $W "Tag To Name Editor"
   wm protocol $W WM_DELETE_WINDOW "destroy $W;unset ::$W"
   ;##
   ;# Build the GUI
   ;#
   set i 0
   set span 3
   ;# TFW: Would be nice to be smarter about doing this, compute the desired height
   if {[llength $fnames] > 8} {
      set hull [scrolledFrame::Frame $W.data -initHeight $::snackAmpSettings(scrolledCanvasHeight)]
   }  else {
      set hull [frame $W.data]
   }
   set ::TA(smartName) $::snackAmpSettings(smartName)
   grid [label $hull.snl -text "Name Template"] \
        [entry $hull.sne -textvariable ::snackAmpSettings(smartName)] \
        -sticky ew
         widgetWatch::setWatch $hull.sne ::snackAmpSettings(smartName)
   balloon::define $hull.sne \
      "Enter naming scheme for converting tags to file names:\n%%A - Artist, %%C - Album, %%N - Track Number, %%T - Title"

   ;# header
   grid [button $hull.rlbh -text "Replace Text" -relief raised -command [list id3Tag::id3TagToNameSubstitute ::$W]] \
        [entry $hull.rlbf -textvariable ::${W}(fromText) -width 70] \
        [entry $hull.rlbt -textvariable ::${W}(toText) -width 70] \
        -sticky ew
   balloon::define $hull.rlbh "Push this to replace text in names (Change field must be checked)"
   balloon::define $hull.rlbf "Enter Text to Replace here"
   balloon::define $hull.rlbf "Enter Replacement Text here"

   ;# header
   grid [label $hull.lb[incr i] -text "Change"] \
        [label $hull.lb[incr i] -text "Old Name"] \
        [label $hull.lb[incr i] -text "New Name"] \
        -sticky ew
   set i 0
   ;##
   ;# Build one row for each file
   ;#
   set tag 0
   foreach fname $fnames {
      ;# Get existing tag data
      ;# Propose new file name
      set ::${W}($tag,oldFullName) $fname
      set fn [file root [file tail $fname]]
      set ::${W}($tag,oldName) $fn
      set ::${W}($tag,newName) $fn
      set ::${W}($tag,ok) 1
      ;# Note using a very small font allows the checkbuttons to pack tighter
      grid [checkbutton $hull.en[incr i] -variable ::${W}($tag,ok) -font {Helvetica 5}] \
         [label $hull.en[incr i] -width 70 -textvariable ::${W}($tag,oldName) -relief sunken -anchor w] \
         [entry $hull.en[incr i] -width 70 -textvariable ::${W}($tag,newName)] \
         -sticky ew
         widgetWatch::setWatch $hull.en$i ::${W}($tag,newName)

      incr tag
   }
   grid columnconfigure $hull 1 -weight 1
   grid columnconfigure $hull 2 -weight 1
   ;##
   ;# Frame for OK/Cancel/Apply buttons
   ;#
   pack [frame $W.but] -fill x -expand false -side bottom
   ;# Line
   pack [frame $W.l[incr i] -height 2 -borderwidth 3 -relief sunken] \
      -expand false -fill x -side bottom
   ;# Data
   pack $W.data -side top -expand true -fill both -side top
   ;# Check All
   set checkAll [button $W.but.[incr i] -font menu -text "Check All" \
      -command [list id3Tag::cbSetOK ::$W 1] \
      -borderwidth 1  -relief raised]
   balloon::define $checkAll "Push this to check all checkboxes"

   ;# Check None
   set checkNone [button $W.but.[incr i] -font menu -text "Check None" \
      -command [list id3Tag::cbSetOK ::$W 0] \
      -borderwidth 1  -relief raised]
   balloon::define $checkNone "Push this to un-check all checkboxes"

   ;# guess
   set guess [button $W.but.[incr i] -width 8 -font menu -text "Guess" -relief raised \
      -command [list id3Tag::id3TagToNameGuess ::$W] -borderwidth 1  -relief raised]
   balloon::define $guess "Push this to guess the correct file names based on tags"

   #fix
   set fix [button $W.but.[incr i] -width 8 -font menu -text "Fix Case" -relief raised \
      -command [list id3Tag::id3TagToNameFix ::$W] -borderwidth 1  -relief raised]
   balloon::define $fix "Push this to automatically correct file name spacing and capitalization"

   ;# Apply and close
   set ok [button $W.but.[incr i] -width 8 -font menu -text "OK" \
      -command [list id3Tag::cbTagToName ::$W 1] -borderwidth 1  -relief raised]
   balloon::define $ok "Push this to apply and save the current settings then close this dialog"
   ;# Apply
   set app [button $W.but.[incr i] -width 8 -font menu -text "Apply" \
      -command [list id3Tag::cbTagToName ::$W 0] \
      -borderwidth 1  -relief raised]
   balloon::define $app "Push this apply and save the current settings"

   ;# Cancel
   set can [button $W.but.[incr i] -width 8 -font menu -text "Cancel" \
      -command "destroy $W;unset ::$W" \
      -borderwidth 1 -relief raised]
   balloon::define $can "Push this to ignore changes made and restore the previous settings"
   grid $checkAll $checkNone $guess $fix $ok $app $can  -padx 10 -pady 2
   ;##
   ;# Key bindings
   ;#
   bind $W <Return> [list $ok invoke]
   bind $W <Escape> [list $can invoke]

   ontop::pinOnSystemMenu {} $W
   update idletasks
   myIcon $W
   focus $W
}
###############################################################################
# Function   : id3Tag::id3TagToNameSubstitute
# Description: Replace some text in enabled file names
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::id3TagToNameSubstitute {_W} {
   upvar #0 $_W W
   foreach {element} [lsort [array names W *,ok]] {
      foreach {key xx} [split $element ,] {break}
      if {$W($element)} {
         ;# _W is traced variable, use full name when setting
         #regsub  -- $W(fromText) $W($key,oldName) $W(toText) ${_W}($key,newName)
         #regsub -- $W(fromText) $W($key,newName) $W(toText) ${_W}($key,newName)
         set ${_W}($key,newName) [string map [list $W(fromText) $W(toText)] [set ${_W}($key,newName)]]
      }
   }
}
###############################################################################
# Function   : id3Tag::id3TagToNameSubstitute
# Description: Replace some text in enabled file names
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::id3TagToNameGuess {_W} {
   upvar #0 $_W W
   global fnameData ;# needs to be global
   foreach {element} [lsort [array names W *,ok]] {
      foreach {tag xx} [split $element ,] {break}
      catch {unset fnameData}
      set fname $W($tag,oldFullName)
      id3Label $fname fnameData
      set fn [file root [file tail $fname]]
      set sfn [smartFileName fnameData]
      if {[string length $sfn] > 0 && ![string equal $sfn $fn]} {
         ;# Use orig name, traced variable
         set ${_W}($tag,newName) $sfn
         set ${_W}($tag,ok) 1
      }
   }
}
###############################################################################
# Function   : id3Tag::id3TagToNameFix
# Description: Clean the file name
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::id3TagToNameFix {_W {patt *,ok}} {
   upvar #0 $_W W
   global fnameData ;# needs to be global
   foreach {element} [lsort [array names W $patt]] {
      foreach {tag xx} [split $element ,] {break}
      set fname $W($tag,newName)
      set fn [fixplus::cleanName $fname]
      if {[string length $fn] > 0 && ![string equal $fn $fname]} {
         ;# Use orig name, traced variable
         set ${_W}($tag,newName) $fn
         set ${_W}($tag,ok) 1
      }
   }
}
###############################################################################
# Function   : id3Tag::id3TagToNameFix
# Description: Clean the file name
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::id3SingleTagToNameFix {_W {patt *}} {
   upvar #0 $_W W
   global fnameData ;# needs to be global
   foreach {element} [lsort [array names W $patt]] {
      set fname $W($element)
      set fn [fixplus::cleanName $fname]
      if {[string length $fn] > 0 && ![string equal $fn $fname]} {
         ;# Use orig name, traced variable
         set ${_W}($element) $fn
      }
   }
}
###############################################################################
# Function   : id3Tag::cbTagToName
# Description: Rename a set of files
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::cbTagToName {_W {close 0}} {
   upvar #0 $_W W
   foreach {element} [lsort [array names W *,ok]] {
      ;# If checkbox checked, try to rename it
      if {$W($element)} {
         set tag [lindex [split $element ,] 0]
         set oldFullName $W($tag,oldFullName)
         set newBase     $W($tag,newName)
         set newFullName [file join [file dirname $oldFullName] "$W($tag,newName)[file extension $oldFullName]"]
         if {![string equal $oldFullName $newFullName]} {
            if {[catch {catalog::RenameFile $oldFullName $newFullName} result] } then {
               tk_messageBox -icon warning -message "Could not rename\n$oldFullName to \n$newFullName\n$result"
            } else {
               catalog::RenameEntry $oldFullName $newFullName
               ;# Update the fields
               set W($tag,oldFullName) $newFullName
               set W($tag,oldName)     [file root [file tail $newFullName]]
            }
         }
      }
   }
   ;# If close widget when done indicated.
   if {$close} {
      destroy [string trimleft $_W :]
      unset $_W
   }
}
;##
;# Callback to set/clear checkboxes
;#
proc id3Tag::cbSetOK {_W how} {
   upvar #0 $_W W
   foreach {field} [lsort [array names W *,ok]] {
      set W($field) $how
   }
}

###############################################################################
# Function   : id3Tag::guessFileName
# Description: Guess a file name
# Author     : Tom Wilkason
# Date       : 3/19/2002
###############################################################################
proc id3Tag::guessFileName {_W index} {
   upvar $_W Data
   set Data($index) [smartFileName $_W]
}
###############################################################################
# Function   : id3Tag::id3Rename
# Description: Rename a file based on the tag name
# Author     : Tom Wilkason
# Date       : 3/18/2002
###############################################################################
proc id3Tag::id3Rename {_fname widget} {
   upvar $_fname fnames
   ;# Note: TFW: Can only rename one file now, can make more intellegent
   ;# with substitutions and such for multiple files later.
   set fname [lindex $fnames 0]
   set newName [$widget get]
   set newfname [file join [file dirname $fname] "$newName[file extension $fname]"]
   if {[string equal $newfname $fname] || [string length newName] < 1} {
      return $fname
   }
   if {[catch {
      catalog::RenameFile $fname $newfname
      catalog::RenameEntry $fname $newfname
      set fnames [list $newfname]
   } result] \
   } then {
     tk_messageBox -icon warning -message "Could not rename\n$fname to \n$newfname\n$result\n$::errorInfo"
   }
}
###############################################################################
# Function   : postTypeNames
# Description: On pop-up, post the common types
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::postTypeNames {Menu _Array Element} {
   upvar #0 $_Array Array
   ;##
   ;# Get list of current entries
   ;#
   set last [$Menu index end]
   set added [list]
   if {![string match "none" $last]} {
      for {set i 0} {$i <= $last} {incr i} {
         lappend added [$Menu entrycget $i -label]
      } ;# end for
   }
   ;##
   ;# Add any unique items in the array to the menu
   ;#
   foreach {item} [lsort [array names Array "*,$Element"]] {
      set value $Array($item)
      if {[string length $value] > 0 && [lsearch $added $value]==-1} {
         ;# TFW: What we really want is to set te $item fields directly
         ;# not the Element which is also a label
         $Menu add command -label "$value" \
            -command [list set ${_Array}($Element) $value]
         lappend added $value
      }
   }
}
###############################################################################
# Function   : postGenreNames
# Description: On pop-up, post the genres, if already built then post menu
#              Menu is shared for all buttons to save memory
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::postGenreNames {Menu _Element} {
   variable v1Genres
   if {[$Menu index end] == "none" || [$Menu index end] == 0} {
      foreach {genre} $v1Genres {
         set first [string index $genre 0]
         lappend genreNames($first) $genre
      }
      $Menu delete 0 end
      foreach {Value} [lsort [array names genreNames]] {
         $Menu add cascade -label $Value -menu $Menu.f$Value
         menu $Menu.f$Value -tearoff 0
         foreach {item} $genreNames($Value) {
           $Menu.f$Value add command -label "$item" \
            -command [list set $_Element $item]
         }
      }
   }
}

###############################################################################
# Function   : smartFileName
# Description: Return a smart file name based on available tag data
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::smartFileName {_Array} {
   upvar #0 $_Array Data
   set name ""
   set sp [string trim $::snackAmpSettings(splitChar)]
   set fname $::snackAmpSettings(smartName)
   #TFW: Substitute the fields with appropriate data
   # %A - %C - %N - %T for example
   foreach {field} [list Artist Album Track Title] {code} [list %A %C %N %T] {
      if {[hasData Data $field] && $Data($field) != "0"} {
         ;# Substitute tag with data if it exists
         if {$field=="Track"} {
            ;# Format tracks using two digits
            set Data($field) [cleanTrack $Data($field)]
         }
         set fname [string map "[list $code] [list $Data($field)]" $fname]
      } else {
         ;# Remove tag
      }
   }
   ;# Remove unused codes
   regsub -all  -- {%A|%C|%N|%T} $fname {} fname
   ;# Collapse spaces and other bad juju to single space
   while {[regsub -all  -- {  |/|\\|\?|:|\*} $fname { } fname]} {}
   set fname [string map {\" '} $fname]     ;#"
   ;# Collapse holes for unused params
   while {[regsub -all -- "( $sp)( $sp)+" $fname {\1} fname]} {}
   set fname [string trim $fname " $sp"]
   return $fname
}
###############################################################################
# Function   : cbOneSmartTagName
# Description: Move data from a single smart tag into an indexed array
#              used by the block editor.
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::cbOneSmartTagName {fname index _Array} {
   upvar $_Array Data
   cbSmartTagName fname oneData
   foreach {item} [array names oneData] {
      if {![string equal $Data($index,$item) $oneData($item)]} {
         ;# Traced, use full global name
         set ${_Array}($index,$item) $oneData($item)
         set ${_Array}($index,ok) 1
      }
   }
}
###############################################################################
# Function   : cbOneSmartTagName
# Description: Move data from a single smart tag into an indexed array
#              used by the block editor.
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::cbManySmartTagName {_Array} {
   upvar $_Array Data
   foreach {item} [array names Data *,oldFullName] {
      set fname $Data($item)
      set index [lindex [split $item ,] 0]
      catch {unset oneData}
      cbSmartTagName fname oneData
      foreach {item} [array names oneData] {
         if {![string equal $Data($index,$item) $oneData($item)]} {
            ;# Traced, use full global name
            set ${_Array}($index,$item) $oneData($item)
            set ${_Array}($index,ok) 1
         }
      }
   } ;# end for
}
###############################################################################
# Function   : cbSmartTagName
# Description: Fill in tag data based on a file name
# Author     : Tom Wilkason
###############################################################################
proc id3Tag::cbSmartTagName {_fname _Array} {
   upvar $_Array Data
   upvar $_fname fname

   ;# TFW: Can be smarter about which entry is the track number
   set sp [string trim $::snackAmpSettings(splitChar)]
   set parts [split [file root [file tail [fixplus::cleanName $fname]]] $sp]
   switch -- [llength $parts] {
      1 {
         set Data(Title) [lindex [string trim $parts] 0]
      }
      2 {
         ;# Artist - Title
         ;# Track - Title
         foreach {First Title} $parts {
            if {[string is double $First]} {
               set Data(Track) [string trim $First]
            } else {
               set Data(Artist) [string trim $First]
            }
            set Data(Title)  [string trim $Title]
         }
      }
      3 {
         ;# Artist - Album - Title
         ;# Album - Track - Title
         ;# Track - Artist - Title
         foreach {Artist Album Title} $parts {
            if {[string is double $Album]} {
               set Data(Album) [string trim $Artist]
               set Data(Track) [string trim $Album]
               set Data(Title)  [string trim $Title]
            } else {
               if {[string is double $Artist]} {
                  set Data(Track)  [string trim $Artist]
                  set Data(Artist) [string trim $Album]
                  set Data(Title)  [string trim $Title]
               } else {
                  ;# Default
                  set Data(Artist) [string trim $Artist]
                  set Data(Album) [string trim $Album]
                  set Data(Title)  [string trim $Title]
               }
            }
         }
      }
      4 {
         foreach {Artist Album Track Title} $parts {
            set Data(Artist) [string trim $Artist]
            set Data(Album)  [string trim $Album]
            set Data(Title)  [string trim $Title]
            set Data(Track)  [string trim $Track]
         }
      }
      5 {
         ;# TBD: handle Artist AlbA - AlbB - Track - Title
         foreach {Artist Album xx Track Title} $parts {
            set Data(Artist) [string trim $Artist]
            set Data(Album)  "[string trim $Album], [string trim $xx]"
            set Data(Title)  [string trim $Title]
            set Data(Track)  [string trim $Track]
         }
      }
      default {}
   } ;# End Switch
   if {[info exists Data(Track)]} {
      if {[string is double $Data(Track)]} {
         ;# Handle octal interpretation
         set Data(Track) [scan $Data(Track) %d]
      } else {
         set Data(Track) ""
      }
   }
   if {[info exists Data(Genre)] && $Data(Genre) == "Not Set" && [info exists lastGenre]} {
      set Data(Genre) $lastGenre
   }
   return
}
###############################################################################
# Function   : cbModify
# Description: Callback to apply the ID3 changes
# Author     : Tom Wilkason
# Date       : 2/7/2001
###############################################################################
proc id3Tag::cbModify {_fnames W {close 0}} {
   upvar $_fnames fnames
   upvar $W data
   if {$::snackAmpSettings(ID3ReadOnly)==0} {
      foreach {fname} $fnames {
         ;# Make a copy of the common array since it is modified in place
         array set localArray [array get ::$W]
         id3Tag::id3V1Modify $fname localArray
         ##
         # Update the URL data at the beginning of the data if required.
         #
         if {[info exists data(URL)] && [info exists data(newURL)] && ![string equal $data(URL) $data(newURL)]} {
            if {[catch {
               set fid [open $fname a]
               seek $fid 0 start
;#                if {[regexp  -nocase -- {^(http://.{1}?:.{1}?/)(.*)} $data(newURL) -> front url]} {
;#                   set url "$front[HttpD::Encode $url]"
;#                } else {
;#                   set url [HttpD::Encode $data(newURL)]
;#                }
;#                playurl::writeurl [HttpD::Encode $url] $fid
               playurl::writeurl $data(newURL) $fid
               close $fid
            } result] } then {
               catch {close $fid}
            }
         }
         ;##
         ;# If this song is the currently linked song then
         ;# update the array that is linked to the displayed
         ;# fields.
         ;#
         if {[string equal [soundControl::fileName] $fname]} {
            array set ::songArray [array get localArray]
         }
      }
   }
   if {$close} {
      destroy [string trimleft $W :]
      unset ::$W
   }
}
###############################################################################
# Function   : id3Label
# Description: Return an appropriate ID3 Label in an array
#              Additional tags are appended to the Desc field (V2 has soo many...)
# Author     : Tom Wilkason
# Date       : 2/7/2001
###############################################################################
proc id3Tag::id3Label {file _Array {types "V1 V2 ogg"}} {
   upvar $_Array Array
   ;# Force only ogg data
#   if {[isogg $file]} {
#      set types ogg
#   }
   ;# Get data V1 then V2
   foreach type $types {
      set data [id3${type}Get $file]
      if {[llength $data] > 0} {
         foreach {TagID Description Value} $data {
            if {[string length $Value] > 0} {
               #set Value [string map {\{ ( \} ) \n " "} $Value]
               set Value [id3Clean $Value]
               switch -- $TagID {
                  TPE1 {set Array(Artist)   $Value}
                  TIT2 {set Array(Title)    $Value}
                  TALB {set Array(Album)    $Value}
                  TRCK {set Array(Track)    $Value}
                  TMED {set Array(Media)    $Value}
                  TYER {set Array(Year)     $Value}
                  TCON {set Array(Genre)    $Value}
                  TIT3 {set Array(Note)     $Value}
                  TCOM {set Array(Comp)     $Value}
                  TENC {set Array(Enc)      $Value}
                  TPOS {set Array(SubGenre) $Value}
                  Tag  {set Array(Tag)      $Value}
                  TLEN {}
                  COMM {}
                  PCNT {}
                  default {
                     append Array(Desc) "$Description: $Value"
                  }
               }
            } ;# End Switch
         }
         #set Array(Tag) $type
         return 1
      } ; #end if data
   }
   return 0
}
###############################################################################
# Function   : id3Clean
# Description: Remove garbage from an ID3 tag
# Author     : Tom Wilkason
# Date       : 2/11/2001
###############################################################################
proc id3Tag::id3Clean {String} {
   regsub -all  -- {\0|þ|ÿ|[[:cntrl:]]} $String {} String
#   regexp {(.+?)([^([:alnum:]|[:space:]|[:punct:])])} $String xx String
   ;# Clamp to 128 len just in case
   return [string trim $String]
   #return [stringTitle [string range [string trim $String] 0 128 ]]
}
###############################################################################
# Function   : formatID3Data {List}
# Description: If a list of ID3 info is passed in, this will format it for
#              use on a balloon pop-up. Non-blank entries are not returned.
# Author     : Tom Wilkason
# Date       : 11/11/2001
###############################################################################
proc id3Tag::formatID3Data {_Data} {
   variable TagIDs
   upvar $_Data Data
   set Info {}
   ;# for each tag, if it exists then append the info
   foreach Tag $TagIDs {
      if {[hasData Data $Tag]} {
         append Info "$Tag \t: $Data($Tag)\n"
      }
   }
   return $Info
}
###############################################################################
# Function   : balloonSongInfo
# Description: Pop-up ballon help on a selected song
# Author     : Tom Wilkason
# Date       : 11/4/2001
###############################################################################
proc balloonSongInfo {W fullName} {
   ;##
   ;# ID3 Info
   ;#
   if {[set fullName [catalog::findIfExists $fullName]]!={}} {
      ;##
      ;# Snack and ID3 info
      ;#
      set tempSound [snack::sound -debug 0 -file $fullName]
      set Info [id3Tag::songDetails $fullName $tempSound Details]
      ;# snack:Bug 0 length files don't get closed properly on a destroy
      $tempSound destroy
      destroy $W.balloon
      balloon::show $W [winfo pointerx .] [winfo pointery .] $Info
   }
}
###############################################################################
# Function   : songDetails
# Description: Return the details of a song in both an array and a text
#              string suitable for balloon help.
# Author     : Tom Wilkason
# Date       : 11/20/2001
###############################################################################
proc id3Tag::songDetails {fullName Sound _Details} {
   upvar $_Details Details
   foreach {index} [array names Details] {
      set Details($index) {}
   }
   ;# Get the bitrate info
   if {[catch {
      switch -- [$Sound config -fileformat] {
         MP3 {set rate "[expr {[$Sound config -bitrate]/1000}] kbps"}
         OGG {set rate "[expr {[$Sound config -nominalbitrate]/1000}] kbps"}
         WAV {set rate "[expr {[$Sound config -rate]/1000}] kHz"}
         default {set rate "Unknown"}
      } ;# End Switch
   }]} then {
      set Details(rate)     "Unknown"
      set Details(sampRate) "Unknown"
      set Details(length)   "Unknown"
      set Details(duration) "00:00"
      set Details(Sample)   "0 Khz"
   } else {
      set Details(rate) $rate
      set Details(sampRate) [expr {double([$Sound cget -frequency])/1000.}]
      set len [$Sound length -units sec]
      set Details(length) $len
      set Details(duration) [clock format [expr {int($len)}] -format "%M:%S"]
      set Details(Sample) "[expr {[$Sound cget -frequency]/1000.}] Khz"
   }
   ;##
   ;# File info
   ;#
   if {[catch {file stat $fullName Stat} result]} {
      return Unknown
   }
   set Details(fSize) "[commify $Stat(size)] Bytes"
   set Details(fDate) [clock format $Stat(mtime) -format "%Y-%m-%d %H:%M"]
   ;##
   ;# Balloon help
   ;#
   set Info         "File\t: [file tail $fullName]\n"
   append Info      "Folder\t: [file dirname $fullName]\n"
   if {[id3Tag::id3Label $fullName Details]} {
      append Info [id3Tag::formatID3Data Details]
      set Details(ID3) $Info
   } else {
      set Details(ID3) {}
   }
   id3Tag::appendIfNotBlank Info "Size\t:"     $Details(fSize)
   id3Tag::appendIfNotBlank Info "Date\t:"     $Details(fDate)
   id3Tag::appendIfNotBlank Info "Duration\t:" $Details(duration)
   id3Tag::appendIfNotBlank Info "Bitrate\t:"  $Details(rate)
   id3Tag::appendIfNotBlank Info "Freq\t:"     $Details(Sample)
   if {[gainControl::exists $fullName] && $::snackAmpSettings(autoLevel)} {
      set Details(levelFactor) [gainControl::get $fullName]
      id3Tag::appendIfNotBlank Info "Gain\t:"  [gainControl::levelText [gainControl::get $fullName]]
   } else {
      set Details(levelFactor) "Not Set"
   }
   set Info [string trim $Info]
   return $Info
}
###############################################################################
# Function   : songData
# Description: Return the details of a song in both an array and a text
#              string suitable for balloon help.
# Author     : Tom Wilkason
# Date       : 11/20/2001
###############################################################################
proc id3Tag::songData {fullName Sound _Details} {
   variable TableCols
   upvar $_Details Details
   foreach {index} $TableCols {
      set Details($index) {}
   }
   set type [string toupper [string trim [file extension $fullName] .]]
   ;# Forcing a file type skips a guess step in the engine
   if {[catch {$Sound config -file $fullName -fileformat $type} result] } then {
      set Rate 0
      set Details(Rate) $Rate
      set Details(Sample) 0.0
      set Details(Duration) 0.0
      set Details(Gain) 0.0
   } else {
      if {[catch {
         switch -- [$Sound config -fileformat] {
            MP3 {set Rate [expr {[$Sound config -bitrate]/1000}]}
            OGG {set Rate [expr {[$Sound config -nominalbitrate]/1000}]}
            WAV {set Rate [expr {[$Sound config -rate]/1000}]}
            default {set Rate 0}
         } ;# End Switch
      }]} then {
         set Rate 0
      } else {
         set Details(Rate) $Rate
         set Details(Sample) [expr {double([$Sound cget -frequency])/1000.}]
         set Details(Duration) [$Sound length -units sec]
         if {[catch {gainControl::get $fullName} gain]} {
            set Details(Gain) 0.0
         } else {
            set Details(Gain) [gainControl::levelText $gain]
         }
      }
   }
   set Details(File)   [file tail $fullName]
   set Details(Folder) [file dirname $fullName]

   ;# Get the bitrate info
   ;##
   ;# ID3 Data, if no tag then set Title = File root name
   ;#
   if {[id3Tag::id3Label $fullName Details]==0} {
      set Details(Title) [file rootname $Details(File)]
   }
   return 1
}
###############################################################################
# Function   : id3Tag::appendIfNotBlank
# Description:
# Author     : Tom Wilkason
# Date       : 11/11/2001
###############################################################################
proc id3Tag::appendIfNotBlank {_Array Title Data} {
   upvar $_Array Array
   if {[string length $Data]>0} {
      append Array "$Title $Data\n"
   }
}
package provide snID3 1.0



