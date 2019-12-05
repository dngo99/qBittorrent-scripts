#!/bin/bash

dst=""
verbose="false"
tmp=""

function rename() {
	group=$3
	title=$4
	season=$5
	episode_num=$6
	episode_ver=$7
	episode_title=$8
	information=$9
	extension=${10}
	if [[ "$season" =~ 0+([1-9][0-9]*) ]]; then
		season=${BASH_REMATCH[1]}
	fi
	if [[ "$episode_num" =~ 0+([1-9][0-9]*) ]]; then
		episode_num=${BASH_REMATCH[1]}
	fi
	if [ "$episode_title" != "" ]; then
		episode_title=" - "$episode_title
	fi
	printf -v season "%02d" "$season"
	printf -v episode_num "%03d" "$episode_num"
	if [ "$verbose" = "true" ]; then
		echo "	Pre-Processing:"
		echo "		Group: $3"
		echo "		Title: $4"
		echo "		Season: $5"
		echo "		Episode #: $6"
		echo "		Episode Version: $7"
		echo "		Episode Title: $8"
		echo "		Information: $9"
		echo "		Extension: ${10}"
		echo "	Post-Processing:"
		echo "		Group: $group"
		echo "		Title: $title"
		echo "		Season: $season"
		echo "		Episode #: $episode_num"
		echo "		Episode Version: $episode_ver"
		echo "		Episode Title: $episode_title"
		echo "		Information: $information"
		echo "		Extension: $extension"
	fi
	if [ "$2" == "false" ]; then
		if ! [ -d "$dst/$title" ]; then
			mkdir -p "$dst/$title"
		fi
		echo "MOVING: $1"
		#mv -n "$1" "$dst/$title/"
		mv "$1" "$dst/$title/"
# 		touch "$dst/$title/$1"
	elif [ "$season" = "00" ] || [ "$episode_num" = "000" ]; then
		echo "FAILED SPECIAL: $1"
	elif [ "$episode_ver" == ".5" ]; then
		echo "FAILED OVA: $1"
	else
		new_name=$group" "$title" - "$season"x"$episode_num$episode_ver
		new_name=$new_name$episode_title" "$information$extension
		echo "RENAMING... OLD: $1"
		echo "RENAMING... NEW: $new_name"
		if ! [ -d "$dst/$title" ]; then
			mkdir -p "$dst/$title"
		fi
		#mv -n "$1" "$dst/$title/$new_name"
		mv "$1" "$dst/$title/$new_name"
		touch "$dst/$title/$new_name"
	fi
	return 0
}

function parse() {
	NAME=$1
	NAME=${NAME//_/ }
	# skip non-media files
	if ! [[ $NAME =~ .*[.](mkv|avi|mp4) ]]; then
		echo "SKIPPING non-media: $1"
		return 0
	fi
	# skip OVAs
	if [[ $NAME =~ .*\ (OVA|OVA\ ?[0-9]+|\(OVA\))\ .* ]]; then
		echo "SKIPPING OVA: $1"
		return 0
	fi
	# skip EDs
	if [[ $NAME =~ .*\ (NC)?ED\ ?[0-9]*.* ]]; then
		echo "SKIPPING ED: $1"
		return 0
	fi
	# skip OPs
	if [[ $NAME =~ .*\ (NC)?OP\ ?[0-9]*.* ]]; then
		echo "SKIPPING OP: $1"
		return 0
	fi
# 	regex_1="(\[[^]]+\])\ (.*)\ -\ ([0-9]{2})x([0-9]{3})(.[0-9]+)?\ -?\ ?([^[(]*)?\ ?([[(].*+\]*[])])([.].{3})"
	regex_1="(\[[^]]+\])?\ ?(.*)\ -\ ([0-9]{2})x([0-9]{3})(.[0-9]+)?\ -?\ ?([^[(]*)?\ ?([[(].*[])])([.].{3})"
	if [[ $NAME =~ $regex_1 ]]; then
		if [ "$verbose" = "true" ]; then
			echo "regex_1: "$1
		fi
		rename "$1" "false" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"\
		"${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}" "${BASH_REMATCH[5]}"\
		"${BASH_REMATCH[6]}" "${BASH_REMATCH[7]}" "${BASH_REMATCH[8]}"
		return 0
	fi
	regex_2="(\[[^]]+\])?\ ?(.*?[^\ -])\ S?([0-9]+)\ -?\ ?([0-9]{1,3})(.?[0-9]?)\ -?\ ?([^[(]*)?\ ?([[(].*[])])([.].{3})"
	if [[ $NAME =~ $regex_2 ]]; then
		if [ "$verbose" = "true" ]; then
			echo "regex_2: "$1
		fi
		rename "$1" "true" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"\
		"${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}" "${BASH_REMATCH[5]}"\
		"${BASH_REMATCH[6]}" "${BASH_REMATCH[7]}" "${BASH_REMATCH[8]}"
		return 0
	fi
	regex_3="(\[[^]]+\])?\ ?(.*?[^\ -])\ -?\ ?([0-9]{1,3})(.[0-9])?\ -?\ ?([^[(]*)?\ ?([[(].*[])])([.].{3})"
	if [[ $NAME =~ $regex_3 ]]; then
		if [ "$verbose" = "true" ]; then
			echo "regex_3: "$1
		fi
		rename "$1" "true" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"\
		"1" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}" "${BASH_REMATCH[5]}"\
		"${BASH_REMATCH[6]}" "${BASH_REMATCH[7]}"
		return 0
	fi
	echo "FAILED: $1"
	return 0
}

function anime_helper() {
	for INPUT in *; do
		if [ -d "$INPUT" ]; then
			if [[ $INPUT =~ [Ss]pecials? ]]; then echo "SKIPPING SPECIALS: $1"; continue; fi
			if [[ $INPUT =~ [Ee]xtras? ]]; then echo "SKIPPING EXTRAS: $1"; continue; fi
			tmp="$INPUT"
			cd "$INPUT"
			anime_helper "$INPUT"
			cd "../"
			echo "REMOVING: $tmp"
			rmdir "$tmp"
		elif [ -e "$INPUT" ]; then
			parse "$INPUT" "$1"
		else
			continue
		fi
	done
	return 0
}

if [ "$1" = "-V" ] || [ "$1" = "-v" ]; then
	verbose="true"
fi

# source is a directory, verbose
if [ $# -eq 3 ] && [ -d "$2" ]; then
	dst="${3%/}"
	cd "$2"
	anime_helper
# 	echo "REMOVING: $2"
# 	rmdir "$2"
# source is a directory, no verbose
elif [ $# -eq 2 ] && [ -d "$1" ]; then
	dst="${2%/}"
	cd "$1"
	anime_helper
# 	echo "REMOVING: $1"
# 	rmdir "$1"
# source is a file, verbose
elif [ $# -eq 3 ] && [ -e "$2" ]; then
	dst="${3%/}"
	cd "$(dirname "$2")"
	parse "$(basename "$2")"
# source is a file, no verbose
elif [ $# -eq 2 ] && [ -e "$1" ]; then
	dst="${2%/}"
	cd "$(dirname "$1")"
	parse "$(basename "$1")"
else
	echo "Usage: $0 -v|v source destination"
fi
exit 0
