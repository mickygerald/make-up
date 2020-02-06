#!/bin/bash

# load helper
my_dir="$(dirname "$0")"
source "$my_dir/../../helper.bash"

echo
echo "$I18N_TASK Deploy"
echo

ok=false

# try gitlab-ci
if [ "$IDENT_GITLAB_CI" = true ]; then
  $my_dir/../git/gitlab-ci.bash

  ok=true
fi

# try git-ftp
if [ "$IDENT_GIT_FTP" = true ]; then
  $my_dir/../git/git-ftp.bash
  
  ok=true
fi

# try '$ npm run deploy'
if grep -q \"deploy\" "package.json"; then
  echo
  echo "  → ${BOLD}Task found in ./package.json${NC}"
  echo "    $ npm run deploy"

  echo
  echo -n "$I18N_QUESTION Run 'npm run deploy'? (y/n)"
  read answer

  if [ "$answer" != "${answer#[Yy]}" ]; then

    echo
    echo "$I18N_TASK Run '$ npm run deploy'"
    echo

    npm run deploy

    echo
    echo "$I18N_SUCCESS Success"
    echo
  else
    echo
    echo "$I18N_WARNING Skipped '$ npm run deploy'"
    echo
  fi

  ok=true
fi

# more-make-up
MORE_MAKE_UP="${0/make-up/more-make-up}"
if [ -f "$MORE_MAKE_UP" ]; then
  echo
  echo "$I18N_TASK Run more Make-up from $MORE_MAKE_UP"
  echo

  $MORE_MAKE_UP

  echo
  echo "$I18N_SUCCESS Done"
  echo

  ok=true
fi

if [ "$ok" = true ]; then
  echo
  echo "$I18N_SUCCESS Done"
  echo
else
  echo
  echo "$I18N_ERROR Could not find a method to execute command"
  echo
fi
