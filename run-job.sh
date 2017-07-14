#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


# Run on the host machine (typically by jenkins) to trigger docker to run "run-inside-docker.sh"

if [ -z "${JDK_TAG}" ]; then echo "JDK_TAG must be non-blank" && exit -1; fi
if [ -z "${GIT_REF}" ]; then echo "GIT_REF must be non-blank" && exit -1; fi
if [ -z "${USER_COMMANDS}" ]; then echo "USER_COMMANDS must be non-blank" && exit -1; fi

set -e
set -x

# we'll overwrite later if there's a patch
JOB_DESCRIPTION="${GIT_REF} w/ ${JDK_TAG}"

# This dir has to be writable by the in-container jenkins user
# which should already be handled as long as the current effective user is the same
# as the effective user that ran build-docker-image.sh (see vars in that script)
mkdir -p workspace  

# main wrapper script for dealing with git and applying other commands
cp run-inside-docker.sh workspace/

# optional custom patch a user may have uploaded to jenkins
# Note: Jenkins uses the same string for the file name, and the ENV var,
# so we're requiring CUSTOM_PATCH (instead of custom.patch) so bash can read the ENV var
if [ ! -z "${CUSTOM_PATCH}" ]; then
  if  [ ! -f ./CUSTOM_PATCH ]; then
    echo "Found ENV{CUSTOM_PATCH}=${CUSTOM_PATCH} -- but ./CUSTOM_PATCH not found, jenkins bug?" && exit -1;
  fi
  echo "Copying user supplied patch to workspace/custom.patch"
  cp ./CUSTOM_PATCH ./workspace/custom.patch
  JOB_DESCRIPTION="${GIT_REF} + ${CUSTOM_PATCH} w/ ${JDK_TAG}"
else
  rm -f ./CUSTOM_PATCH ./workspace/custom.patch
fi

# the bash commands the user wants to run
echo "${USER_COMMANDS}" > workspace/run-user-command.sh

echo "JOB DESCRIPTION: ${JOB_DESCRIPTION}"
docker run \
  -v $PWD/workspace:/home/jenkins \
  -u jenkins -w /home/jenkins \
  "hossman/solr-jenkins-docker-tester:${JDK_TAG}" bash run-inside-docker.sh "${GIT_REF}"

