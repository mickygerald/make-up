#!/bin/bash

# load helper
my_dir="$(dirname "$0")"
source "$my_dir/helper.bash"

echo
echo "  ${BLUE}TASK${NC} List all available environment variables"
echo

env

echo
echo "  ${GREEN}SUCCESS${NC} Done"
echo