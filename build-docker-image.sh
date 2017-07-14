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



# Run on the host machine (typically by jenkins) to ensure the docker image is up to date
# with the most current version of the JDK

if [ -z "${JDK_TAG}" ]; then echo "JDK_TAG must be non-blank" && exit -1; fi

set -e
set -x

mkdir -p build/docker

sed -e "s/%%%JDK_TAG%%%/${JDK_TAG}/g" \
    -e "s/%%%JENKINS_UID%%%/$(id -u)/g" \
    -e "s/%%%JENKINS_GID%%%/$(id -g)/g" \
    < Dockerfile.template > build/docker/Dockerfile

cd build/docker

docker build -t "hossman/solr-jenkins-docker-tester:${JDK_TAG}" .
