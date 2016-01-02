#!/bin/bash

inputfile="./avgcube.in"
datadir="./data"

msg() {
	local message="$1"
	shift
	printf "$message\n" "$@"
}

warn() {
	msg "$@" >&2
}

err() {
	msg "$@" >&2
}

cd "$(dirname "$0")"
mkdir -p "$datadir"

warn 'Searching for multiplayer cubes on cubetutor'
[[ -f "$inputfile" ]] || cubesearch.pl > "$inputfile"

warn 'Downloading cube lists'
while read id user name; do
	url="http://www.cubetutor.com/viewcube/$id"
	name="${name//\//_}"
	cubefile="$datadir/${user}_${name// /_}.dat"
	[[ ! -f "$cubefile" ]] && \
		./cubeprint.sh "$url" > "$cubefile"
done < "$inputfile"

warn 'Excluding cubes with fewer than 270 cards'
cubes=( $(wc -l data/* | awk '$1 >= 270 && $2 != "total" {print $2}') )

warn 'Creating aggregate list'
./mtgaggregate "${cubes[@]}" > avgcube.out




# old script starts below
exit

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

