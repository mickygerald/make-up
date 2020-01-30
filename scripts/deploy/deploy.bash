#!/bin/bash

# load helper
my_dir="$(dirname "$0")"
source "$my_dir/../../helper.bash"

echo
echo "  ${BLUE}TASK${NC} Deploy"
echo

ok=false

# try gitlab-ci
if [ -f ".gitlab-ci.yml" ]; then
  $my_dir/../git/gitlab-ci.bash

  ok=true
fi

# try git-ftp
if [ -f ".git-ftp-config" ]; then
  $my_dir/../git/git-ftp.bash
  
  ok=true
fi

# try '$ npm run deploy'
deploycommand=$(npm run deploy --if-present)
if [ -n "$deploycommand" ]; then
  echo "  → ${BOLD}Task found in ./package.json${NC}"
  echo "    $ npm run deploy"

  ok=true
fi

# more-make-up
MORE_MAKE_UP="${0/make-up/more-make-up}"
if [ -f "$MORE_MAKE_UP" ]; then
  echo
  echo "  ${BLUE}TASK${NC} Run more Make-up from $MORE_MAKE_UP"
  echo

  $MORE_MAKE_UP

  echo
  echo "  ${GREEN}SUCCESS${NC} Done"
  echo

  ok=true
fi

if [ "$ok" = true ]; then
  echo
  echo "  ${GREEN}SUCCESS${NC} Done"
  echo
else
  echo
  echo "  ${RED}ERROR${NC} Could not find a method to execute command"
  echo
fi
