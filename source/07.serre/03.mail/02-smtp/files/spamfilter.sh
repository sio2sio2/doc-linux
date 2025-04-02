#!/bin/sh
#
# Vease: http://wiki.apache.org/spamassassin/IntegratedSpamdInPostfix
#

# Los correos >10MB no se procesan como spam.
MAX_MESSAGE_SIZE=10485760

SENDMAIL=/usr/sbin/sendmail
SPAMASSASSIN=/usr/bin/spamc

logger "Spam filter piping to SpamAssassin, then to: $SENDMAIL $*"
${SPAMASSASSIN} -x -E -s $MAX_MESSAGE_SIZE | ${SENDMAIL} "$@"

exit $?
