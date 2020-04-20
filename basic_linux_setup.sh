#!/usr/bin/env bash

set -eux

for dotfile in vimrc bashrc tmux.conf pdbrc inputrc gitconfig; do
  cp ".$dotfile" ~
done
