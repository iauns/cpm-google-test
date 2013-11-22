#!/bin/bash

if [ ! -d ./cookbooks ]; then
  mkdir cookbooks
fi

if [ ! -d ./cookbooks/build-essential ]; then
  git clone https://github.com/opscode-cookbooks/build-essential.git ./cookbooks/build-essential
fi

if [ ! -d ./cookbooks/apt ]; then
  git clone https://github.com/opscode-cookbooks/apt.git ./cookbooks/apt
fi

if [ ! -d ./cookbooks/nodejs ]; then
  git clone https://github.com/mdxp/nodejs-cookbook.git ./cookbooks/nodejs
fi

if [ ! -d ./cookbooks/git ]; then
  git clone https://github.com/opscode-cookbooks/git.git ./cookbooks/git
fi
