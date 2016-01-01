#!/bin/bash

inputfile="./avgcube.in"
datadir="./data"

msg() {
	local message="$1"
	shift
	printf "$message\n" "$@"
}

err() {
	msg "$@" >&2
}

mkdir -p "$datadir"

while read user url; do
	url="http://www.cubetutor.com/viewcube/${url##*/}"
	cubefile="$datadir/$user.dat"
	#[[ ! -f "$cubefile" ]] && \
		curl -s "$url" \
		| grep -o '<a rel="nofollow" class="cardPreview [^>]*>[^<]*<' \
		| grep -o '>.*<' \
		| sed 's/^>//; s/<$//' \
		| sort -u \
		> "$cubefile"

	## sanity check
	#expectcards="$(curl -s "$url" | egrep -o '\([0-9]+ cards\)' | egrep -o '[0-9]+')"
	#numcards="$(wc -l "$cubefile")"
	#numcards="${numcards%% *}"
	#if (( $numcards != "$expectcards" )); then
	#	err "%d cards in %s, %d expected" "$numcards" "$cubefile" "$expectcards"
	#fi
done < "$inputfile"

#sort "$datadir"/*.dat | uniq -c | sort -rn

