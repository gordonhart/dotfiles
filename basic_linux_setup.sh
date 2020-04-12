#!/usr/bin/env bash

set -eux

for dotfile in vimrc bashrc tmux.conf pdbrc inputrc; do
  cp ".$dotfile" ~
done
