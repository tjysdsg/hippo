#!/usr/bin/env bash

# fail if any command fails
set -e
# debug log
set -x

cd ..
git clone https://github.com/flutter/flutter.git
export PATH=`pwd`/flutter/bin:$PATH

flutter channel stable
flutter doctor

echo "Installed flutter to `pwd`/flutter"

flutter build ios --release --no-codesign
