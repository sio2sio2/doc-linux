#!/bin/sh

#
# Convierte código hexadecimal en binario
# (requiere bc, que puede no estar instalado)
# $1: El número en hexadecimal
#
hex2dec() {
   echo "ibase=16;$1" | bc
}


#
# Obtiene n bytes al azar expresados en hexadecimal
# $1: Número de bytes. 1, si no se especifica.
#
random_x() {
   # hexdump -n${1:-1} -ve '"%02X"' /dev/urandom
   # od debería ser más portable que hexdump,
   # aunque debemos eliminar espacios y pasar a mayúsculas.
   od -v -An -tx1 -N${1:-1} /dev/urandom | tr -d '\n ' | tr '[:lower:]' '[:upper:]'
}


#
# Obtiene un número decimal aleatorio entre 0 y 2**n-1.
# $1: El valor de n.
#
random() {
   hex2dec $(random_x "$1")
}


RANDOM=$((`random`%10+1))     # Número entre 1 y 10 (sí, no son equiprobables)

echo "Acabo de pensar un número entre 1 y 10."

while [ "$num" != "$RANDOM" ]; do
   read -p "Intente averiguarlo: " num
done

echo "¡¡¡Correcto!!!"
