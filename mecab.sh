#!/bin/bash
for file in ./tsubame00*/*-stripped.txt ; do
  echo "mecab $file -o $file-tagged.txt"
done


