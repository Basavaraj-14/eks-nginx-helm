#!/bin/bash

git --version

if [ $? -eq 0 ]; then
    echo "git is installed"
else
    echo "git is not installed"
fi
