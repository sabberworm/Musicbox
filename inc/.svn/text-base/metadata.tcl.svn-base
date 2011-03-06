source "${inc_dir}inc/id3.tcl"

proc get_metadata file_path {
	array set result {}
	set result(year) "NULL"
	set result(track_name) "Unknown"
	set result(track_name) [file tail $file_path]
	set result(artist_name) "Unknown"
	set result(album_name) "Unknown"
	set result(track_number) "NULL"
	if {[string equal -nocase [file extension $file_path] ".mp3"] || [string equal -nocase [file extension $file_path] ".ogg"]} {
		array set id3info {}
		if {[string equal -nocase [file extension $file_path] ".mp3"]} {
			array set id3info [concat [id3Tag::id3V1Get $file_path] [id3Tag::id3V2Get $file_path]]
		} else {
			array set id3info [id3Tag::id3oggGet $file_path]
		}
		if {[info exists id3info(TPE1)]} {
			set result(artist_name) $id3info(TPE1)
		}
		if {[info exists id3info(TIT2)]} {
			set result(track_name) $id3info(TIT2)
		}
		if {[info exists id3info(TALB)]} {
			set result(album_name) $id3info(TALB)
		}
		if {[info exists id3info(TYER)]} {
			set result(year) [lindex [scan $id3info(TYER) "%d%d%d%d"] 0]
		}
		if {[info exists id3info(TRCK)]} {
			set result(track_number) [lindex [scan $id3info(TRCK) "%d%d"] 0]
		}
	} elseif {[string equal -nocase [file extension $file_path] ".mp4"] || [string equal -nocase [file extension $file_path] ".m4a"]} {
		set parsley_result [open "| AtomicParsley \"$file_path\" -t"]
		fconfigure $parsley_result -translation lf -encoding utf-8
		while {-1 != [gets $parsley_result parsley_content]} {
			regexp "Atom \"(.{4})\" contains: (.+)" $parsley_content full atom contents
			if {[info exists atom]} {
				switch -- $atom {
					"©nam"		{set result(track_name) $contents}
					"©ART"		{set result(artist_name) $contents}
					"aART"		{set result(artist_name) $contents}
					"©alb"		{set result(album_name) $contents}
					"©day"		{set result(year) [lindex [scan $contents "%d%d%d%d"] 0]}
					"trkn"		{set result(track_number) [lindex [scan $contents "%d%d"] 0]}
					"©gen"		{set result(genre) $contents}
					default {}
				}
			}
		}
		close $parsley_result
	}
	if {$result(track_number) == ""} {
		set result(track_number) "NULL"
	}
	if {$result(year) == ""} {
		set result(year) "NULL"
	}
	return [array get result]
}
