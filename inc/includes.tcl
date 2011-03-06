package require mysqltcl

set mysql_host localhost
if {[info exists env(MYSQL_HOST)]} {
	set mysql_host $env(MYSQL_HOST)
}
set mysql_user musicbox
if {[info exists env(MYSQL_USER)]} {
	set mysql_user $env(MYSQL_USER)
}
set mysql_pass rosa
if {[info exists env(MYSQL_PASS)]} {
	set mysql_pass $env(MYSQL_PASS)
}
set mysql_db musicbox
if {[info exists env(MYSQL_DB)]} {
	set mysql_db $env(MYSQL_DB)
}

set timeout 50

set mysql_handle [::mysql::connect -host $mysql_host -user $mysql_user -password $mysql_pass -encoding utf-8 -multistatement true]
::mysql::use $mysql_handle $mysql_db
::mysql::exec $mysql_handle "SET character_set_client=utf8;"
::mysql::exec $mysql_handle "SET character_set_connection=utf8;"
::mysql::exec $mysql_handle "SET character_set_results=utf8;"

proc get_setting {mysql_handle name} {
	set name [::mysql::escape $mysql_handle $name]
	return [::mysql::sel $mysql_handle "SELECT value FROM settings WHERE name = '$name';" -list]
}

set root_folder [get_setting $mysql_handle music_folder]
