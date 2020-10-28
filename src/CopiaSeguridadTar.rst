1. El directorio /home/share tiene:

   + Originariamente el siguiente contenido.

     .. code:: none

        +-- ficheroA.txt (que contiene una letra a).
        +-- ficheroB.txt (que contiene una letra b).
        +-- mio
             +-- cuentas.txt (contiene el número 123).
             +-- amigos (que contiene "nadie me quiere").

   + Pasado un día, ocurren los siguientes cambios:

     * Desaparece :file:`ficheroB.txt`.
     * Se crea :file:`ficheroC.txt` (que contiene una letra c).
     * Se altera :file:`cuentas.txt` (que pasa a contener
       el número 1234).
   
   + Pasado otro día, ocurre esto:

     * Se altera :file:`ficheroA.txt` (que contiene dos aes).
     * Se crea :file:`ficheroD.txt` (que contiene una d).
     * Conozco a un nuevo amigo, así que borro la frase
       del archivo y añado su nombre "Pepito".

   + Y el cuarto día:

     * Desaparece :file:`cuentas.txt`.
     * Añado otro amigo a la lista: "María".
