#!/bin/sh
#
# Script que emula a pam_ssh.
# ...
#
#   auth     [default=2 success=ignore]  pam_exec.so seteuid quiet expose_authtok /usr/local/bin/pam_ssh.sh
#   session  optional                    pam_env.so  readenv=0 user_readenv=1 user_envfile=.cache/ssh-agent/environment
#   session  optional                    pam_exec.so /usr/local/bin/pam_ssh.sh

# Para que haga las veces de SSH_ASKPASS
if [ -z "$PAM_SERVICE" ]; then
   cat
   exit 0
fi

while [ $# -gt 0 ]; do
   eval $1
   shift
done
[ -n "$start_if" ] || start_if="login,slim,lightdm,xdm,gdm,kdm"

get_ssh_auth_dir() {
   echo $(getent passwd "$PAM_USER" | cut -d: -f6)/.cache/ssh-agent
}

check_service() {
   echo "$start_if" | grep -qw "$PAM_SERVICE"
}

last_session() {
   w | grep -qw "$PAM_USER"
   [ $? -eq 1 ]
}

add_passphrase() {
   export SSH_AUTH_SOCK SSH_AGENT_PID
   cat | SSH_ASKPASS="$1" su "$PAM_USER" -c "setsid ssh-add"
}

SSH_AUTH_DIR=$(get_ssh_auth_dir)

case $PAM_TYPE in
   auth)
      check_service || exit 1
      if [ -f "$SSH_AUTH_DIR/environment" ]; then
         . "$SSH_AUTH_DIR/environment"
         pgrep -u "$PAM_USER" ssh-agent | grep -qw "$SSH_AGENT_PID" && exit 0
      fi
      rm -f "$SSH_AUTH_DIR"/agent.sock
      su - "$PAM_USER" -c 'mkdir -p '"$SSH_AUTH_DIR"
      eval $(su - "$PAM_USER" -c 'ssh-agent -a '"$SSH_AUTH_DIR"'/agent.sock')
      echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK" > "$SSH_AUTH_DIR/environment"
      echo "SSH_AGENT_PID=$SSH_AGENT_PID" >> "$SSH_AUTH_DIR/environment"
      chown "$PAM_USER" "$SSH_AUTH_DIR/environment"
      add_passphrase "$(readlink -f "$0")"
      ;;
   close_session)
      check_service || exit 0
      last_session || exit 0
      ssh-agent -k
      rm -rf "$SSH_AUTH_DIR"
      ;;
   *)
      exit 0
esac
