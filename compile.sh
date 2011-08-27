#! /bin/bash
function bold_echo {
  echo ----------------------------
  echo $1
  echo ----------------------------
}

function comment_import {
  sed "s/\(@import $2\)/\/\/ \1/g" $1/AppController.j > $1/AppController.j.release
  mv $1/AppController.j.release $1/AppController.j
}

function uncomment_import {
  sed "s/\/\/ \(@import $2\)/\1/g" $1/AppController.j > $1/AppController.j.release
  mv $1/AppController.j.release $1/AppController.j
}

function set_uses_frameworks {
  # If they use the framework, then comment out the source import and
  # uncomment the framework import
  # 
  # Else do the opposite
  if $2; then
    uncomment_import $1 "\<CoreLecture\/CoreLecture.j\>"
    uncomment_import $1 "\<LiveLectureUtilities\/LiveLectureUtilities.j\>"
    comment_import $1 "\"..\/CoreLecture\/CoreLecture.j\""
    comment_import $1 "\"..\/LiveLectureUtilities\/LiveLectureUtilities.j\""
  else
    comment_import $1 "\<CoreLecture\/CoreLecture.j\>"
    comment_import $1 "\<LiveLectureUtilities\/LiveLectureUtilities.j\>"
    uncomment_import $1 "\"..\/CoreLecture\/CoreLecture.j\""
    uncomment_import $1 "\"..\/LiveLectureUtilities\/LiveLectureUtilities.j\""
  fi
}

function build {
  bold_echo "Building $1"
  cd $1
  jake release
  cd ..
}

function copy_framework_to_applications {
  bold_echo "Copying $1 to Editor and Presenter"
  cp -R $1/Build/Release/$1 Editor/Frameworks/$1
  cp -R $1/Build/Release/$1 Presenter/Frameworks/$1
}

function build_and_copy_framework {
  build $1
  copy_framework_to_applications $1
}

function build_release {
  bold_echo "Building release version of $1"
  set_uses_frameworks $1 true
  build $1
  rm -R ./$1.release
  cp -R $1/Build/Release/$1 ./$1.release
  bold_echo "Done building release version of $1"
  set_uses_frameworks $1 false
}

build_and_copy_framework CoreLecture
build_and_copy_framework LiveLectureUtilities

build_release Editor
build_release Presenter

bold_echo Finished