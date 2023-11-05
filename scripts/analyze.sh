#!/bin/bash

cd core
flutter analyze --fatal-infos
cd ..

cd modules
for dir in */; do
    cd $dir
    flutter analyze --fatal-infos
    cd ..
done
cd ..

cd app
flutter analyze --fatal-infos
cd .
