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

# Run on the virtual container (typically by docker run) to execute the solr build
# NOTE: this file is explicily not executable on disk, should only be run explicitly by docker+bash

[[ "${PWD##*/}" == "workspace" ]] || (echo "Must be run (by docker) inside workspace" && exit -1)

if [ -z "$1" ]; then echo "First arg must be a non blank GIT ref" && exit -1; fi

set -e
set -x

java -version
ant -version

if [ ! -d lucene-solr ]; then
  git clone https://git-wip-us.apache.org/repos/asf/lucene-solr.git
fi
cd lucene-solr

git clean -fdx
git reset --hard
git fetch
git checkout "$1"
git merge
if [ -f ../custom.patch ]
then
  echo "Appying custom.patch..."
  git apply < ../custom.patch
fi


ant ivy-bootstrap # redundent but cheap

source ../run-user-command.sh
