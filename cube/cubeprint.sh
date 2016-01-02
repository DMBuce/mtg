#!/bin/bash

url="$1"
cubefile="$datadir/$user.dat"
#[[ ! -f "$cubefile" ]] && \
	curl -s "$url" \
	| grep -o '<a rel="nofollow" class="cardPreview [^>]*>[^<]*<' \
	| grep -o '>.*<' \
	| sed 's/^>//; s/<$//'

