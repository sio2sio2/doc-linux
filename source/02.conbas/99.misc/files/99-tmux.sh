# Si hay ya sesión abierta, nos conectamos a ella.
case "$TERM" in
   linux|vt*) alias tmux='tmux attach || tmux new-session' ;;
   *) alias tmux='tmux -2 attach || tmux -2 new-session' ;;
esac

if which tmux >/dev/null 2>&1 &&  # tmux instalado
      [[ $- = *i* ]] &&  # Interactiva
      [ "$(logname)" = "$(whoami)" ] &&  # No procedemos de su[do]
      [[ $TERM != screen* ]] && [ -z "$TMUX" ] && # No usamos ya screen  ni tmux
      [[ $TERM != vt* ]]; then  # No es conexión por puerto serie
   tmux
fi
