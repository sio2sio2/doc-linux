#!/bin/sh
#
# Crea un sistema enjaulado
# $1: Directorio de la jaula
# stdin: Listado de ejecutables a incluir en la jaula.

CHDIR="$1"
[ -n "$1" ] || { echo "Falta jaula" >&2; exit 1; }

shift

# Ejecutables que se incluirán en la jaula
EXE="`cat`"

[ -n "$EXE" ] || { echo "No hay ejecutables que enjaular"; exit 2; }

# Obtiene las dependencias de un ejecutable.
depends() {
   local exe=$1

   ldd "$exe" | awk '{ if(/=>/) print $3; else if(/\//) print $1; }'
}

# Recorre los ejecutables obteniendo dependencias.
recorre() {
   for exe in $EXE; do
      [ -f $exe ] || { echo "$exe: Fichero no encontrado" >&2; continue; }
      echo $exe
      [ -x $exe ] && depends $exe
   done | sort | uniq
}

exe_libs=$(recorre)

# Copia ficheros a la jaula
for origin in $exe_libs; do
   destin="$CHDIR/$(dirname $origin)"
   mkdir -p "$destin"
   cp -vp "$origin" "$destin"
done

# Dispositivos especiales
mkdir $CHDIR/dev
mknod -m 666 $CHDIR/dev/null c 1 3
mknod -m 666 $CHDIR/dev/zero c 1 5

# passwd
ln -vsf /etc/passwd $CHDIR/etc
