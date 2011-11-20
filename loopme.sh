#!/bin/bash
until (toutf.py ./tsubame*/*-stripped.txt) do
  echo "crash with error code $?. Reopening.." >$2
  sleep 1
done
