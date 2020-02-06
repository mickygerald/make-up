#!/bin/bash

# load helper
my_dir="$(dirname "$0")"
source "$my_dir/../../helper.bash"

echo
echo "$I18N_TASK Start developing"
echo

ok=false

# try craft 3
if [ "$IDENT_DOCKER" = true ]; then
  # up docker container
  $my_dir/../craft-3/up.bash

  # try craft 3 (requires docker)
  $my_dir/../craft-3/start.bash

  ok=true
fi

# todo 
# install phpcs pre-commit hook
# if [ ! -f ".git/hooks/pre-commit" ]; then
# 	# copy the pre-commit bash script to the .git directory
# 	mkdir -p ./.git/hooks
# 	cp $my_dir/../php-linting/pre-commit.bash ./.git/hooks/pre-commit
# 	chmod +x ./.git/hooks/pre-commit

#   ok=true
# fi

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
