#!/bin/sh

TEA4CUPS=cups-tea4cups
CONFFILE="/etc/cups/tea4cups.conf"
SCRIPT="/usr/local/sbin/usercode.sh"
CODECONFFILE="/usr/local/etc/usercode.conf"
OPTION="UserCode"
PJLOPTION="USERCODE"

#XDIALOG=yad
XDIALOG=zenity
DIALOG='whiptail --title "Gestión de códigos de usuario"'

help() {
   echo "
$(basename $0)
   Habilita/deshabilita la petición del código de usuario en impresoras
   que lo exijan para imprimir.

   Al habilitar la petición, en todas los trabajos se comprobara si
   se ha proporcionado previamente el código y, si no es así, se pedirá
   interactivamente. La petición se realiza después de que el sistema
   haya procesado el documento y antes de enviarse a la impresora, por
   lo que enre la orden de impresión y la solicitud puede producirse una
   demora apreciable, si el fichero es largo.

   Requisitos previos:

   + tea4cups, aunque se intentará instalar si no lo está aún.
   + Tener YA instalada la impresora en cups.

Opciones:

   -h|--help              Muestra este mensaje de ayuda.
   -c|--config [PRINTER]  Configura las opciones de código para la impresora.
                          Si no se incluye el nombre de la impresora, se
                          presentará un menú para seleccionar sobre
                          cuál de las impresionas instaladas se quiere
                          llevar a cabo la acción.
"
}

# Comprueba si un paquete está instalado
check_install() {
   dpkg -l $1 2>/dev/null | grep -q ^ii
}

# Impresoras instaladas con su dispositivo.
get_printers() {
   LC_ALL=C lpstat -v 2> /dev/null | sed -nr 's;^device for \b([^/]+):\s+(tea4cups:)?/?/?(.*);\1 \3 \2;p'
}

# Prepara las impresoras como opciones para whiptail
# $1: Lista de impresoras tal como la saca get_printers
prepara_opciones() {
   echo "$1" | awk '{print $1, $2, $3?"ON":"OFF"}'
}

# Lista los cambios en las impresoras: "+" es añadir gestión; "-", quitar.
# $1: Lista de impresoras tal como la saca get_printers
# $2: Impresoras con gestión habilitada. Por ejemplo: "RICOH" "OTRA_RICOH"
lista_cambios() {
   HAB="^("$(echo "$2" | sed -r 's:"::g; s: :|:g; /^$/s::qwwqwjjq:')")\$"
   # +, si estaba deshabilitada y se habilita la gestión; y
   # -, si estaba habilitada, pero se deshabilita.
   echo "$1" | awk '{
      if($1 ~ /'$HAB'/ && $3 == "") print "+", $1;
      else if($1 !~ /'$HAB'/ && $3 != "") print "-", $1
   }'
}

# Habilita la gestión de códigos.
# $1: Nombre de la impresora.
# $2: Dispositivo de impresión.
habilita() {
   lpadmin -p "$1" -v "tea4cups:$2"
   echo "
[$1]
prehook_insercode: $SCRIPT
" >> "$CONFFILE"
}

# Deshabilita la gestión de códigos.
# $1: Nombre de la impresora.
# $2: Dispositivo de impresión.
deshabilita() {
   lpadmin -p "$1" -v "$2"
   sed -i '/^\['$1'\]/{N;$!N;d}' "$CONFFILE"
}

# Cambio en la configuración de una impresora
# $1: Lista de impresoras tal como la saca get_printers
# $2: Nombre de la impresora
config() {
   local PRINTER="$2"
   local LISTA="$(echo "$1" | awk '$3 != "" {print $1, " OFF"}')"
   local NUM=$(printf "$LISTA" | wc -l)
   if [ -z "$PRINTER" ]; then
      case $NUM in
         0) eval $DIALOG --msgbox '"No hay definidas impresoras con tea4cups"' 8 40
            exit 255
            ;;
         1) PRINTER=$(echo "$LISTA" | cut -d\  -f1)
            break
            ;;
         *) eval $DIALOG --noitem --radiolist '"Escoja la impresora a configurar"' $((NUM+7)) 30 $NUM $LISTA 2> "$TMPFILE" "|| return 255"
            PRINTER=$(tr -d '"' < "$TMPFILE")
      esac
   else
      if ! echo "$LISTA" | grep -q "^$PRINTER\>"; then
         eval $DIALOG --msgbox "'"La impresora *$PRINTER* no existe o no usa tea4cups"'" 8 40
         return 3
      fi
   fi

   usercode_options "$TEAPRINTERNAME" "$CODECONFFILE"

   eval $DIALOG --inputbox '"Opción de impresión para definir el código"' 6 55 $OPTION 2> "$TMPFILE" "|| return 255"
   OPTION=$(cat $TMPFILE)
   eval $DIALOG --inputbox '"Opción PJL para definir el código"' 6 55 $PJLOPTION 2> "$TMPFILE" "|| return 255"
   PJLOPTION=$(cat $TMPFILE)
   if [ -f "$CODECONFFILE" ] && grep -q "^$PRINTER\b" "$CODECONFFILE"; then
      sed -ri '/^'$PRINTER'=/{s:=.*:'"=$OPTION $PJLOPTION"': ; q}' "$CODECONFFILE"
   else
      echo "$PRINTER=$OPTION $PJLOPTION" >> "$CODECONFFILE"
   fi
   return 0
}

# Obtiene del archivo de configuración cuál es
# la opción que indica el código de usuario la impresiora.
# El archivo se compone de líneas:
#
#   NOMBRE_IMPRESORA=NombreOpcion PJLNombreOpcion
#
# $1: Nombre de la impresora.
# $2: Archivo de configuración
usercode_options() {
   [ -f "$2" ] || return 255
   eval $(awk -F'[=[:space:]+]' -v OFS='\n'  '$1 == "'"$1"'" {print "OPTION=" $2, "PJLOPTION=" $3; exit}' "$2")
}

# Gestión de argumentos
while [ $# -gt 0 ]; do
   case $1 in
      -c|--config)
         CONFIG=1
         shift
         PRINTER=$1
         [ -z "$PRINTER" ] || shift
         ;;
      -h|--help)
         help
         exit 0
         ;;
      -*)
         echo "$1: Opción desconocida" >&2
         help >&2
         exit 1
         ;;
      *)
         echo `basename $0` no admite argumentos >&2
         help >&2
         exit 1
   esac
done

TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" TERM INT EXIT

LISTA=$(get_printers)

check_install $TEA4CUPS || apt-get install -y $TEA4CUPS
if [ $? -ne 0 ]; then
   eval $DIALOG --msgbox '"Imposible instalar tea4cups. Lo siento."' 7 40
   exit 4
fi


check_install $XDIALOG || apt-get install -y $XDIALOG
if [ $? -ne 0 ]; then
   eval $DIALOG --msgbox '"Imposible instalar $XDIALOG. Lo siento."' 7 40
   exit 4
fi

[ -z "$CONFIG" ] || { config "$LISTA" $PRINTER ; exit $?; }

NUM=$(echo "$LISTA" | wc -l)
NUM=$((NUM+1))
if [ $NUM -eq 0 ]; then
   eval $DIALOG --msgbox '"No hay impresoras instaladas"' 7 40
   exit 255
fi

eval $DIALOG --checklist '"Seleccione las impresoras que requiran código"' $((NUM+7)) 55 $NUM '$(prepara_opciones "$LISTA")' 2> "$TMPFILE" || exit $?

CAMBIOS=`lista_cambios "$LISTA" "$(cat $TMPFILE)"`
echo "$CAMBIOS" | while read hab nombre; do
   device=$(echo "$LISTA" | awk '$1 == "'$nombre'" {print $2}')
   case "$hab" in
      +)
         habilita "$nombre" "$device"
         ;;
      -)
         deshabilita "$nombre" "$device"
         ;;
      *)
         true
   esac
done

if [ ! -f "$SCRIPT" ]; then
   sed '1,/^exit 0/d; s:^DIALOGPROG=$:&'$XDIALOG':; s:^OPTION=$:&'$OPTION':; s:^PJLOPTION=$:&'$PJLOPTION':; s:^CODECONFFILE=$:&'"$CODECONFFILE"':' $0 > "$SCRIPT"
   chown root:lpadmin "$SCRIPT"
   chmod +x "$SCRIPT"
fi

# Si se ha habilitado alguna impresora
if echo "$CAMBIOS" | grep -q '^+'; then
   eval $DIALOG --msgbox '"Se ha supuesto que *UserCode* es la opción que aplica en la impresión el código de usuario. Si no es así, puede cambiarlo usando la opción -c del programa"' 11 45
fi

exit 0
#!/bin/sh
#
# Gancho de tea4cups para preguntar por el código de usuario
# en las impresoras que lo requiren.
#
# Configuracion manual:
#
# 0) Tener instalada la impresora en cups.
#
# 1) Instalar el paquete cups-tea4cups.
#
# 2) En /etc/cups/tea4cups.conf incluir:
# 
#      [NOMBRE_DE_MI_IMPRESORA]
#      prehook_insertcode: /path/a/usercode.sh
#
# 3) Ejecutar:
#    
#     # lpadmin -p NOMBRE_DE_MI_IMPRESORA -v tea4cups:DISPOSITIVO
#
#    donde dispositivo es el que ya tenga configurado la impresora y que
#    puede consultarse con:
#
#     # lpstats -s

export DISPLAY=":0.0"
DIALOGPROG=
OPTION=
PJLOPTION=
CODECONFFILE=
DIALOG="$DIALOGPROG --title 'Impresora $TEAPRINTERNAME'"

usercode_options() {
   [ -f "$2" ] || return 255
   eval $(awk -F'[=[:space:]+]' -v OFS='\n'  '$1 == "'"$1"'" {print "OPTION=" $2, "PJLOPTION=" $3; exit}' "$2")
}

usercode_options "$TEAPRINTERNAME" "$CODECONFFILE"

# Sólo en caso de que no se incluya el código de usuario.
if echo "$TEAOPTIONS" | grep -Pq '^(?:^(?:(?!'$OPTION'=).)*)$|\b'$OPTION'=[^0-9]+\b'; then
   CODE=$(su $TEAUSERNAME - -c "$DIALOG --entry --hide-text --text \"Código de departamento\"")
   if [ $? -ne 0 -o -z "$CODE" ]; then
      su $TEAUSERNAME - -c "$DIALOG --info --text \"Impresión cancelada\""
   else
      # Añade el código al propio fichero de impresión
      sed -i '3a@PJL SET '$PJLOPTION'="'$CODE'"' $TEADATAFILE
   fi
fi
