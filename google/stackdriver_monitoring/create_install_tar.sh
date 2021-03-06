#!/bin/bash
#
# Copyright 2017 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <zipfile>"
    exit -1
fi

SOURCE_DIR=$(readlink -f `dirname $0`)
BUILD_DIR=$(readlink -f "$SOURCE_DIR/../../..")
TEMP_DIR=$(mktemp -d)
TARGET_PATH=$(readlink -f $1)

function make_spinnaker_monitor_zip() {
  local zip_file="$TEMP_DIR/monitor_spinnaker.zip"

  cd "$SOURCE_DIR"
  zip -r "$zip_file" `ls *.py | grep -v _test.py`

  cp spinnaker_metric_tool.py $TEMP_DIR/__main__.py
  cd $TEMP_DIR
  zip $zip_file __main__.py
  rm -f __main__.py

  cd "$BUILD_DIR/spinnaker"
  zip -r $zip_file pylib

  cd "$BUILD_DIR/citest"
  zip -r $zip_file citest
}

function make_install_tar() {
  local tar_file="$TEMP_DIR/install.tz"
  local staging_dir="$TEMP_DIR/monitor_spinnaker"
  mkdir $staging_dir

  cd "$SOURCE_DIR"
  cp *.json README.md $TEMP_DIR/monitor_spinnaker.zip $staging_dir
  cat requirements.txt | grep -v mock > $staging_dir/requirements.txt

  cd $TEMP_DIR
  tar czf $tar_file monitor_spinnaker
}

make_spinnaker_monitor_zip
make_install_tar

cp "$TEMP_DIR/install.tz" "$TARGET_PATH"
rm -rf $TEMP_DIR

echo "WROTE $TARGET_PATH"
