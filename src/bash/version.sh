#!/bin/bash

# sanity
set -eu -o pipefail

MAJOR=0
MINOR=0

# usage
export USAGETXT=\
"
Usage: $0

Purpose: The script will update the version in the VERSION.info file. By default it will increment the patch level by 1.

Options:
    -m do a minor update instead
    -M do a major update instead

Note:
    -m and -M are obviously mutually exclusive
    versions are of the form major.minor.patch
"

# helper function
# shellcheck disable=SC1091
source functions.sh

# handle the options
while getopts mM option
do
    case "$option" in
        m) MINOR=1;;
        M) MAJOR=1;;
	\?) usage;;
    esac
done
shift $((OPTIND - 1))

# sanity

[[ ${MAJOR} -eq 1 ]] && [[ ${MINOR} -eq 1 ]] && abort "-m and -M are mutually exclusive"

# update the common
git submodule update --remote
cd ../../UPSCb-common
cversion=$(git status . | head -1 | cut -d" " -f4)

# parse the existing version
cd ..
tversion=$(head -1 VERSION.info | cut -d" " -f2)
M=$(echo "${tversion}" | cut -d. -f1)
m=$(echo "${tversion}" | cut -d. -f2)
p=$(echo "${tversion}" | cut -d. -f3)

if [ ${MAJOR} -eq 1 ]; then
	M=$((M + MAJOR))
	m=0
	p=0
elif [ ${MINOR} -eq 1 ]; then
	m=$((m + MINOR))
	p=0
else
	p=$((p+1))
fi

# update the version
echo \
"template: ${M}.${m}.${p}
UPSCb-common: $cversion
" > VERSION.info
