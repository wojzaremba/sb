function str = capitalize(str)

str = regexprep(str,'(\<[a-z])','${upper($1)}');