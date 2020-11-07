# perl-utils

## Table of Contents

* [Preamble](#preamble)
* [Paragraph processing utilities](#paragraph-processing-utilities)
  * [`paragrep`](#paragrep)
  * [`logmerge`](#logmerge)
* [Other text-oriented utilities](#other-text-oriented-utilities)
  * [`sponge`](#sponge)
  * [`transpose`](#transpose)
* [File-oriented utilities](#file-oriented-utilities)
  * [`file-rename`](#file-rename)
* [To be continued...](#to-be-continued)

# Preamble

**perl-utils** is the set of text- and file-oriented utilities. Text-oriented scripts are supposed to be used mostly for processing paragraphs. By default, a paragraph is idenitified as a bunch of text lines delimited by an empty or blank lines.

Assuming the text file is the set of paragraphs, it is easier to sort, merge and filter some files without losing links between lines of paragraphs.

For example, multiline log entries in log files could contain additional useful information. Using `grep -C` (or `grep -A`, or `grep -B`) doesn't guarantee complete extraction of particular log entries (or can extract other log entries not necessary at the moment).

# Paragraph processing utilities

## `paragrep`

paragrep - grep-like filter for searching matches in paragraphs.

paragrep assumes the input consists of paragraphs and prints the paragraphs matching a pattern. Paragraph is identified as a block of text delimited by an empty or blank lines.

The initial version was very simple and was implemented as a shell function invoking perl inline script for grepping log files:

```bash
paragrep() {
	perl -ne '
	if ( m/$break_of_para/ ) {
		print $para if defined $para && $para =~ /$regexp/;
		$para = "";
	}
	$para .= $_;
	END {
		print $para if defined $para && $para =~ /$regexp/;
	}
	' -s -- -break_of_para="$1" -regexp="$2" "${@:3}"
}
```

or

```bash
paragrep() {
	perl -ne '
	( m/$break_of_para/ or eof ) and do {
		print $para if defined $para && $para =~ /$regexp/;
		$para = "";
	};
	$para .= $_;
	' -s -- -break_of_para="$1" -regexp="$2" "${@:3}"
}
```

Later I decided to implement it as the standalone script adding more functionality and flexibility.

**Example**

Each log entry in log files usually begins with the timestamp in the generalized numeric form *date time*, which can be covered by the pattern without reflecting on which date format has been used to output dates:

```bash
paragrep -Pp '^\d+/\d+/\d+ \d+:\d+:\d+' PATTERN FILENAME
```

Also the aliases for parsing log files and INI-like configuration files:

```bash
alias lgrep="paragrep -Pp '^\d+/\d+/\d+ \d+:\d+:\d+'"
alias cgrep="paragrep -Pp '^(#@ |#-> )?\['"
```

**Similar tools**

While working on the script I found a lot of interesting implementations of the task on different languages. Here is a quite short excerpt of them interested me:

* [paragrep in Python](https://github.com/bmc/paragrep)
* [paragrep in Haskell](https://github.com/rrnewton/paragrep)
* [Ack](https://beyondgrep.com/)
* [greple](https://github.com/kaz-utashiro/greple)
* [Example from Perl Cookbook, Chapter 6](https://resources.oreilly.com/examples/9780596003135/blob/master/cookbook.examples/ch06/paragrep)

## `logmerge`

Small and powerful script to merge two or more logfiles so that multilined entries appear in the correct chronological order without breaks of log entries.

* https://github.com/ildar-shaimordanov/logmerge

# Other text-oriented utilities

## `sponge`

sponge is Perl version of the sponge from the Debian package moreutils.

It reads standard input to memory and writes it out to the specified file. Unlike a shell redirect, the script soaks up all its input before opening the output file. This allows constructing pipelines that read from and write to the same file. If no file is specified, outputs to STDOUT.

My first release was the Perl inline script within the shell function:

```bash
sponge() {
	perl -ne '
	push @lines, $_;
	END {
		open(OUT, ">$file")
		or die "sponge: cannot open $file: $!\n";
		print OUT @lines;
		close(OUT);
	}
	' -s -- -file="$1"
}
```

Perl has many ways to do it. So, there is a bit another way also supporting the `-a` option for appending to the file:

```bash
sponge() {
	perl -e '
	$file = shift || "-";
	@lines = <>;
	open OUT, ( defined $a ? ">>" : ">" ) . $file
	or die "sponge: cannot open $file: $!\n";
	print OUT @lines;
	close OUT;
	' -s -- "$@"
}
```

Awk can do sponge as well:

```awk
# slurp a stuff and burp...
# ... | awk -f sponge.awk [-v ORS="\r\n"] [-v append=1] [-v file=file]

NR == 1	{ lines = $0 }
NR != 1	{ lines = lines ORS $0 }

END	{
	if ( ! file ) { file = "-" }
	if ( append ) {
		print lines >> file;
	} else {
		print lines > file;
	}
}
```

**Example**

An abstract example of usage is described in the tool's help and shown below:

```bash
sed '...' file | grep '...' | sponge [-a] file
```

**See also**

* http://joeyh.name/code/moreutils/
* http://backreference.org/2011/01/29/in-place-editing-of-files/

## `transpose`

This is Perl implementation of the AWK script to transpose the input file so rows become columns and columns become rows.

```awk
#!/usr/bin/awk -f

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
```

**Example**

```bash
( echo {1..5} ; echo {100..104} ) | ./transpose
```

**See also**

* https://stackoverflow.com/q/1729824/3627676
* http://www.perlmonks.org/?node_id=1162532

# File-oriented utilities

## `file-rename`

`file-rename` renames the filenames supplied according to the rule specified as the first argument. It supports several ways to rename files: applying a perl code to copy or move files; rotating names cyclically left or right; swapping two names; flipping the whole list of files.

**Example**

```bash
file-rename 's/\.bak$//' *.bak
```

**See Also**

* https://metacpan.org/pod/rename
* https://metacpan.org/pod/App::RenameUtils
* http://plasmasturm.org/code/rename/

# To be continued...
