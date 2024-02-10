#!/bin/bash

export BASEDIR=$( cd $(dirname $0) && pwd )

echo "BASEDIR=$BASEDIR"

(
  cd $BASEDIR
  for file in profiles/*/*profile.yaml
  do
    name=$(basename $file .profile.yaml)
    echo "--- Profile ${name} ---"
    if ( lxc profile show "${name}" &> /dev/null )
    then
      echo "Profile ${name} already exists. Skipping..."
    else
      echo "Profile ${name} does not exists. Creating..."
      lxc profile create "${name}"
    fi
    echo "Updating..."
    echo lxc profile edit "${name}" < "${file}"
  done
)
