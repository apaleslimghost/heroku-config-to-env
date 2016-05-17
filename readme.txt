Usage: heroku-config-to-env heroku-app-name [path/to/env.sh]

path/to/env.sh is optional. if it's provided, the file will be written
and made executable. if it's blank or '-', it's written to stdout.

`export` is prepended to each line, unless -e is set or the path ends with .env

Options:
	-i PATTERN	ignore any config var matching PATTERN. can be used multiple times
	-l VAR=val	add an entry setting `VAR` to `val`. use with -i to prevent duplicates
	-e		don't prepend `export` to each line
	-h		show this help
