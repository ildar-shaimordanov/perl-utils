
# Preamble

**para-utils** is the set of text-oriented utilities for processing 
paragraphs. By default, a paragraph is idenitified as a bunch of text 
lines delimited by an empty or blank lines. 

Assuming the text file is the set of paragraphs, it is easier to sort, 
merge and filter some files without losing links between lines of 
paragraphs. 

For example, multiline log entries in log files could contain additional 
useful information. Using `grep -C` (or `grep -A`, or `grep -B`) doesn't 
guarantee complete extraction of particular log entries (or can extract 
other log entries not necessary at the moment). 

# Utilities

## `paragrep`

paragrep - grep-like filter for searching matches in paragraphs. 

paragrep assumes the input consists of paragraphs and prints the 
paragraphs matching a pattern. Paragraph is identified as a block of text 
delimited by an empty or blank lines. 

The initial version was very simple and was implemented as a shell 
function invoking perl inline script for grepping log files:

```bash
paragrep() {
	perl -ne '
	if ( m/$begin_of_para/ ) {
		print $line if defined $line && $line =~ /$match_pattern/;
		$line = "";
	}
	$line .= $_;
	' -s -- -begin_of_para="$1" -match_pattern="$2" "${@:3}"
}
```

Later I decided to implement it as the standalone script adding more 
functionality and flexibility. 

**Example**

Each log entry in log files usually begins with the timestamp in the 
generalized numeric form *date time*, which can be covered by the pattern 
without reflecting on which date format has been used to output dates:

```bash
paragrep -Pp '^\d+/\d+/\d+ \d+:\d+:\d+' PATTERN FILENAME
```

**Similar tools**

While working on the script I found two interesting implementations of the 
task on Python and NodeJS. But none of them is mandatory to be installed 
on the systems I support. And I don't like Python. And Perl is still alive 
and it is flexible, powerful, richful and fast scripting language in Unix.

* https://github.com/bmc/paragrep
* https://github.com/rrnewton/paragrep

## `logmerge`

Small and powerful script to merge two or more logfiles so that multilined 
entries appear in the correct chronological order without breaks of log 
entries. 

* https://github.com/ildar-shaimordanov/logmerge

# To be continued...
