proc getLogLevel {line} {
	set fields [split $line " "]
	return [string index [lindex $fields 2]  0]
}
