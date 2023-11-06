#!/bin/bash

cd core
flutter pub get
cd ..

cd modules
for dir in */; do
    cd $dir
    flutter pub get
    cd ..
done
cd ..

cd app
flutter pub get
cd .
