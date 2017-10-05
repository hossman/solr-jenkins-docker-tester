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


This repo contains a Dockerfile template & scripts for automated testing of Solr using various
JDKs against a specified GIT reference, optionally with patches.

( This is based on earlier work done in https://github.com/hossman/solr-jdk9-jenkins-on-docker )

It is designed to be used in a parameterized jenkins job (which passes parameters as ENV
variables) which will be used to automatically build the docker image including the most recent
version of the specified openjdk base, and then build the specified GIT ref of Solr.

The file "sample-config.xml" shows how it's used by the original author.

The crux of any Jenkins config that might use this repo is:

1) Configuring "This project is parameterized" with options for:
   JDK_TAG, GIT_REF, USER_COMMANDS, and CUSTOM_PATCH (file upload, optional)
2) "Source Code Management" doing a GIT checkout of this repo URL (solr-jenkins-docker-tester)
3) The main "Build" should be "Execute Shell" with the following shell commands...

    bash -x build-docker-image.sh
    bash -x run-job.sh


In normal operation, Jenkins will create a CUSTOM_PATCH file and set ENV vars matching the
Build params when running the shell commands.

An example of how to *manually* run these commands locally for testing would be...

    $ JDK_TAG=8-jdk bash -x build-docker-image.sh
    ...
    $ USER_COMMANDS="ant test" GIT_REF=master JDK_TAG=8-jdk bash -x run-job.sh


Manually testing CUSTOM_PATCH is a bit trickier...

    $ cp ~/somewhere/to_test.patch ./CUSTOM_PATCH
    $ JDK_TAG=8-jdk bash -x build-docker-image.sh
    ...
    $ CUSTOM_PATCH=to_test.patch USER_COMMANDS="ant test" GIT_REF=master JDK_TAG=8-jdk \
      bash -x run-job.sh
    ...

Note that if you set the CUSTOM_PATCH ENV var, a ./CUSTOM_PATCH file *must* exist.
If the CUSTOM_PATCH ENV var is not set, rub-job.sh will delete ./CUSTOM_PATCH

