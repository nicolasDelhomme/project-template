#!/bin/bash -l

# safe
set -eu -o pipefail
set -x

# populate the UPSCb-common
cd ../.. && git submodule init && git submodule update --remote

# copy the helper
cd src/bash && cp ../../UPSCb-common/src/bash/functions.sh .

# source the helper
# shellcheck disable=SC1091
source "functions.sh"

# set variables

# default
PI=
PIPELINE="rnaseq"

# shellcheck disable=SC2034
USAGETXT=\
"
Usage: $0 [options] <slurm account> <species> <version>
    Options:
        g: PIs group name. Create the project directory within the PI's project folder. Off by default.
        p: Set the pipeline template to use, default to ${PIPELINE}
"

# get the command line args (species and version)
ACCOUNT=
SPECIES=
VERSION=

# process the arguments
[[ $# -ne 3 ]] && abort "This script expects three arguments, the account, the specie and the version"

ACCOUNT=$1
shift

SPECIES=$1
shift

VERSION=$1
shift

# create a project directory
cd ../..
mkdir nextflow
ln -s /mnt/reference .

# shellcheck disable=SC2046
proj=$(basename $(realpath .))

[[ -n "${PI}" ]] && [[ -d /mnt/picea/projects/"${PI}" ]] \
&& [[ ! -d /mnt/picea/projects/"${PI}"/"${proj}" ]] && \
mkdir -p /mnt/picea/projects/"${PI}"/"${proj}"/raw && \
ln -s /mnt/picea/projects/"${PI}"/"${proj}" data

# copy the upscb-config and nf template and edit them
cp "UPSCb-common/nextflow/template/${PIPELINE}_${SPECIES}_${VERSION}.json" nextflow/nf-params.json
sed -i "s:<reference>:/mnt/reference:" nextflow/nf-params.json
sed -i "s:<project>:$(realpath .):" nextflow/nf-params.json

cp UPSCb-common/nextflow/config/upscb.config nextflow/
sed -i "s:<account>:${ACCOUNT}:" nextflow/upscb.config

# print out a message with an example nf command line
echo \
"Setup complete!

1. You know need to create the doc/sample_sheet.csv file
2. Validate the nf-params.json and upscb.config file in the nextflow directory
3. Commit the newly created files
4. Run the nextflow pipeline using the parameters: -profile singularity,upscb -c nextflow/slurm.config -params-file nextflow/nf-params.json

Lycka till!
"