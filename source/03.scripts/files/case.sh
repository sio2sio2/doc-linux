#!/bin/sh

read -p "Escriba un carácter: " CHAR
echo

case $CHAR in
   [0-9])
      echo "Ha introducido un número"
      ;;
   [a-zA-Z])
      echo "Ha introducido una letra"
      ;;
   *)
      echo "No tengo ni idea de lo que ha introducido"
      ;;
esac
