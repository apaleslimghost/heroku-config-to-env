Usage: heroku-config-to-env heroku-app-name [path/to/env.sh]

path/to/env.sh is optional. if it's provided, the file will be written
and made executable. if it's blank or '-', it's written to stdout.

Options:
	-i PATTERN	ignore any config var matching PATTERN. can be used multiple times
	-l VAR=val	add an entry setting VAR to val. use with -i to prevent duplicates
	-h		show this help
