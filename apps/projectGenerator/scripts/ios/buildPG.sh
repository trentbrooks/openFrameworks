#!/bin/bash
set -e
cd ..
git clone --depth=1 https://github.com/openframeworks/openFrameworks
mv projectGenerator openFrameworks/apps/
cd openFrameworks/apps/projectGenerator
echo "Building openFrameworks PG - iOS"
xcodebuild -configuration Release -target projectGeneratorSimple -project projectGeneratorSimple/projectGeneratorSimple.xcodeproj GCC_PREPROCESSOR_DEFINITIONS="MAKE_IOS=1"
ret=$?
if [ $ret -ne 0 ]; then
      echo "Failed building Project Generator"
      exit 1
fi
if [ "${TRAVIS_REPO_SLUG}/${TRAVIS_BRANCH}" = "openframeworks/projectGenerator/master" ]; then
    mv projectGeneratorSimple/bin/data/settings/projectGeneratorSettings_production.xml projectGeneratorSimple/bin/data/settings/projectGeneratorSettings.xml
    cp scripts/ssh_config ~/.ssh/config
    chmod 600 scripts/id_rsa
    mv projectGeneratorSimple/bin projectGenerator_ios
    zip -r projectGenerator_ios.zip projectGenerator_ios
    scp -i scripts/id_rsa projectGenerator_ios.zip tests@192.237.185.151:projectGenerator_builds/projectGenerator_ios_new.zip
    ssh -i scripts/id_rsa tests@192.237.185.151 "mv projectGenerator_builds/projectGenerator_ios_new.zip projectGenerator_builds/projectGenerator_ios.zip"
fi
rm scripts/id_rsa

