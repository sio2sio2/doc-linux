#!/bin/sh
#
# Script que para el usuario arranca fetchmail
# ...
#
#   session  optional                    pam_exec.so /usr/local/bin/pam_fetchmail.sh

FETCHMAIL="/usr/bin/fetchmail"

check_service() {
   echo "$start_if" | grep -qw "$PAM_SERVICE"
}

get_home() {
   getent passwd "$1" | cut -d: -f6
}

last_session() {
   w | grep -qw "$PAM_USER"
   [ $? -eq 1 ]
}

while [ $# -gt 0 ]; do
   eval $1
   shift
done
[ -n "$start_if" ] || start_if="login,slim,lightdm,xdm,gdm,kdm"
if [ -n "$rc" ]; then
   [ "${rc##/*}" != "" ] && rc="$(get_home "$PAM_USER")/$rc"
else
   rc="$(get_home "$PAM_USER")/.fetchmailrc"
fi

case $PAM_TYPE in
   open_session)
      check_service || exit 0
      pgrep -cu "$PAM_USER" fetchmail >/dev/null || runuser -u "$PAM_USER" -- $FETCHMAIL -f "$rc"
      ;;
   close_session)
      check_service || exit 0
      last_session || exit 0
      [ -f "$rc" ] && runuser -u "$PAM_USER" -- $FETCHMAIL --quit 2>/dev/null
      ;;
   *)
      exit 0
esac
