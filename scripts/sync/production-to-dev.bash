#!/bin/bash

# load helper
my_dir="$(dirname "$0")"
source "$my_dir/../../helper.bash"

echo
echo "  ${BLUE}TASK${NC} Synchronize database and uploads from environment ${GREEN}production${NC} to ${WHITE}dev${NC}"
echo

echo
echo "  ${BLUE}TASK${NC} Get database from ${GREEN}production${NC}"
echo

E_PRODUCTION_DB_DUMP_NAME=production.sql.gz

# check if all neccesary information is given
if
  [ ! -n "$E_PRODUCTION_SSH_USER" ] ||
    [ ! -n "$E_PRODUCTION_SSH_HOST" ] ||
    [ ! -n "$E_PRODUCTION_DB_USER" ] ||
    [ ! -n "$E_PRODUCTION_DB_PASS" ] ||
    [ ! -n "$E_PRODUCTION_DB_NAME" ] ||
    [ ! -n "$E_PRODUCTION_PROJECT_HOME" ]
then
  echo
  echo "  ${RED}ERROR${NC} Some information is missing in your ${WHITE}.env${NC} file (@see below)."
  echo
  echo "  → E_PRODUCTION_SSH_USER=$E_PRODUCTION_SSH_USER"
  echo "  → E_PRODUCTION_SSH_HOST=$E_PRODUCTION_SSH_HOST"
  echo "  → E_PRODUCTION_DB_USER=$E_PRODUCTION_DB_USER"
  echo "  → E_PRODUCTION_DB_PASS=$E_PRODUCTION_DB_PASS"
  echo "  → E_PRODUCTION_DB_NAME=$E_PRODUCTION_DB_NAME"
  echo "  → E_PRODUCTION_PROJECT_HOME=$E_PRODUCTION_PROJECT_HOME"
else
  # dump database
  ssh -T "$E_PRODUCTION_SSH_USER@$E_PRODUCTION_SSH_HOST" 'mysqldump -u' "$E_PRODUCTION_DB_USER"' -p'"$E_PRODUCTION_DB_PASS"' '"$E_PRODUCTION_DB_NAME"' | gzip -f > '"$E_PRODUCTION_PROJECT_HOME"'/'"$E_PRODUCTION_DB_DUMP_NAME"

  # copy database dump from production to dev
  scp "$E_PRODUCTION_SSH_USER@$E_PRODUCTION_SSH_HOST":$E_PRODUCTION_PROJECT_HOME/$E_PRODUCTION_DB_DUMP_NAME $E_PRODUCTION_DB_DUMP_NAME

  # remove dump from production
  ssh -T "$E_PRODUCTION_SSH_USER@$E_PRODUCTION_SSH_HOST" 'rm' "$E_PRODUCTION_PROJECT_HOME"'/'"$E_PRODUCTION_DB_DUMP_NAME"

  if [ -f "$E_PRODUCTION_DB_DUMP_NAME" ]; then
    # restore database
    $my_dir/../backup/restore.bash $E_PRODUCTION_DB_DUMP_NAME

    # remove dump
    rm $E_PRODUCTION_DB_DUMP_NAME

    echo
    echo "  ${GREEN}SUCCESS${NC} Synchronized database"
    echo
  else
    echo
    echo "  ${RED}ERROR${NC} No file found that could be used to restore database"
    echo
  fi
fi

echo
echo "  ${BLUE}TASK${NC} Synchronize uploads"
echo

# check if all neccesary information is given
if
  [ ! -n "$E_PRODUCTION_SSH_USER" ] ||
    [ ! -n "$E_PRODUCTION_SSH_HOST" ] ||
    [ ! -n "$E_PRODUCTION_UPLOADS" ] ||
    [ ! -n "$E_DEV_UPLOADS" ]
then
  echo
  echo "  ${RED}ERROR${NC} Some information is missing in your ${WHITE}.env${NC} file (@see below)."
  echo
  echo "  → E_PRODUCTION_SSH_USER=$E_PRODUCTION_SSH_USER"
  echo "  → E_PRODUCTION_SSH_HOST=$E_PRODUCTION_SSH_HOST"
  echo "  → E_PRODUCTION_UPLOADS=$E_PRODUCTION_UPLOADS"
  echo "  → E_DEV_UPLOADS=$E_DEV_UPLOADS"
else
  # create dir
  mkdir -p $E_DEV_UPLOADS

  # sync uploads
  rsync -F -L -a -z -e ssh $E_PRODUCTION_SSH_USER@$E_PRODUCTION_SSH_HOST:$E_PRODUCTION_UPLOADS/* $E_DEV_UPLOADS --delete-after --progress

  echo
  echo "  ${GREEN}SUCCESS${NC} Synchronized uploads to ./$E_DEV_UPLOADS (There may be additional output above)"
  echo
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
