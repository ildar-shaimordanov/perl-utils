#!/usr/bin/awk -f

# slurp a stuff and burp...
# ... | awk -f sponge.awk [-v ORS="\r\n"] [-v append=1] [-v file=file]

NR == 1	{ lines = $0 }
NR != 1	{ lines = lines ORS $0 }

END	{
	if ( ! file ) { file = "-" }
	if ( append ) {
		print lines >> file;
	} else {
		print lines >  file;
	}
}
