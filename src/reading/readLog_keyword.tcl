# we try to set log level by keywords
proc getLogLevel {line} {
# set LogLevels "G V D I W E A F"
# set LogLevelsLong "Generic Verbose Debug Info Warning Error Assert Fatal"
	if {[string match -nocase "*error*" $line]} {
		return E
	} elseif {[string match -nocase "*fatal*" $line]} {
	 	return F
	} elseif {[string match -nocase "*warn*" $line]} {
		return W
	} elseif {[string match -nocase "*trace*" $line]} {
	 	return V
	} elseif {[string match -nocase "*debug*" $line]} {
	 	return D
	} elseif {[string match -nocase "*info*" $line]} {
	 	return I
	} elseif {[string match -nocase "*assert*" $line]} {
	 	return A
	}
    return G
}
