# we try to set log level by keywords
proc getLogLevel {line} {
	# LogLevels "V D I W E A F"
	# if the string line contains a keyword it goes to the loglevel here:  error=>E  warning=>W
	if {[string match -nocase "*error*" $line]} {
		return E
	} elseif {[string match -nocase "*warning*" $line]} {
		return W
	#  elseif {[string match -nocase "*info*" $line]} {
	# 	return I
	# } elseif {[string match -nocase "*debug*" $line]} {
	# 	return D
	 } elseif {[string match -nocase "*fatal*" $line]} {
	 	return F
	# } elseif {[string match -nocase "*alert*" $line]} {
	# 	return A
	# }
	 }
    return V
}
