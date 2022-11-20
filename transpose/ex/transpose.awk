#!/usr/bin/awk -f

# The improved version of the awk implementation borrowed from
# https://stackoverflow.com/q/1729824/3627676

{
	for (i = 1; i <= NF; i++) {
		a[NR,i] = $i
	}
}

NF > p {
	p = NF
}

END {
	for (j = 1; j <= p; j++) {
		str = a[1,j]
		for (i = 2; i <= NR; i++) {
			str = str OFS a[i,j];
		}
		print str
	}
}
