#!/bin/bash

#Colores

# Colours
#greenColour="\\e[0;32m\\033[1m"
#endColour="\\033[0m\\e[0m"
#redColour="\\e[0;31m\\033[1m"
#blueColour="\\e[0;34m\\033[1m"
#yellowColour="\\e[0;33m\\033[1m"
#purpleColour="\\e[0;35m\\033[1m"
#turquoiseColour="\\e[0;36m\\033[1m"
#grayColour="\\e[0;37m\\033[1m"

#New Colors for compatibility in bash and awk, direct byte value instead of scaped with backslash
greenColour=$'\033[1;32m'
endColour=$'\033[0m'
redColour=$'\033[1;31m'
blueColour=$'\033[1;34m'
yellowColour=$'\033[1;33m'
purpleColour=$'\033[1;35m'
turquoiseColour=$'\033[1;36m'
grayColour=$'\033[1;37m'

function ctrl_c(){
        echo -e "\n\n ${redColour}[!] Saliendo.. \n"${endColour}; #COn las llaves separamos variables de texto con caracteres especiales tambien
        tput cnorm && exit 1; #Codigo error de salida
}

#Capture Control C para que no se rompa el script y se cierre bien 
trap ctrl_c INT 
# NO reiniciamos hasta ganar 5 euros, 
# Se suman los extremos y eso se apuesta en cad aiteración, si se gana poner al final lo que se gano-apuesta, luego al perder se eliminan los extremos de la secuencia 1 2 3 4, se reinicia al perder y quedarse sin numeros, la suma nos dice cuanto apostar. 
# Labrousher inversa. 
#
#
#
