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

#Global variables
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
	echo -e "\n ${yellowColour} [+] ${endColour} ${grayColour} Use cases: ${endColour} \n"
	echo -e "\t ${purpleColour} -n <MACHINENAME> ${endColour} ${grayColour}  Buscar por nombre de maquina, case sensitive ${endColour}"
	echo -e "\t ${purpleColour} -i <IP> ${endColour} ${grayColour}  Buscar nombre de maquina, por ip ${endColour}"
	echo -e "\t ${purpleColour} -u  ${endColour} ${grayColour} Actualizar el archivo de referencia ${endColour}"
	echo -e "\t ${purpleColour} -h ${endColour} ${grayColour} Mostrar panel de ayuda ${endColour} \n "

}

function searchMachine(){
	echo -e "\n ${yellowColour} [+] ${endColour} ${grayColour} Showing machine details... ${endColour} \n"
	sleep 1;
	awk "/name: \"$1\"/,/resuelta:/" bundle.js | grep -vE "id:|sku:|resuelta" | sed 's/[",^* ]//g' | awk -F: -v yellow="$yellowColour" -v gray="$grayColour" -v end="$endColour" '
{
    key=$1
    sub(/^[ \t]+/, "", key)

    value=substr($0, index($0,$2))
    sub(/^[ \t]+/, "", value)

    printf "%s%s%s:%s%s%s\n", yellow, key, end, gray, value, end
}';

}

function download_bundle(){
#curl -s X GET https://htbmachines.github.io/bundle.js | js-beautify > $location/bundle.js 
	 local location=$1
	 curl -s -X GET $main_url  | js-beautify > $location/bundle.js 
}

function updatejsbundle(){
	tput civis;
	download_bundle /tmp/"$temp_location" ;	


	if ! [[ -f "./bundle.js"  ]]; then #Checks if the file does not exist
		
		echo "File does not exist, downloading...";	
		mv /tmp/"$temp_location"/bundle.js ./bundle.js;
		sleep 1;
	else 
		echo "File is downloaded, checking for updates...";
		sleep 2;
		#File exists, so time to check for any updates
		if [[ -z "$(diff --brief /tmp/"$temp_location"/bundle.js ./bundle.js  2>/dev/null)"  ]]; then 
			echo "The file is up to date"
		else 
			mv /tmp/"$temp_location"/bundle.js ./bundle.js;
			echo "File updated";
			sleep 2;
		fi
	fi
	tput cnorm;

}

function searchIP(){
	ipadd="$1";
	echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Searching machine with IP Add: $ipadd ${endColour} \n";
	sleep 1;
	machinename="$( grep "ip: \"$ipadd\"" bundle.js -B 3 | head -n 1 | awk '{print$2}' | sed 's/[",]//g')"
	searchMachine $machinename
}

#Indicadores
declare -i parameter_counter=0 #entero declarado en 0
declare location="$(pwd)"
declare temp_location="htbmachines_bundle"
mkdir -p "/tmp/$temp_location"
#Menu de inputs viables
#: para listar varios
while getopts "n:i:hu" arg; do
	case $arg in
		n) machineName=$OPTARG; let parameter_counter+=1;;
		h) ;; #Indicamos la funcion a llamar
		u) let parameter_counter+=2;;
		i) ipadd=$OPTARG; let parameter_counter+=3;; #Caracteristica de la maquina, para mostrar todas las que hagan match
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName; #TODO escribir la funcion	
elif [ $parameter_counter -eq 2  ]; then
	updatejsbundle;
elif [ $parameter_counter -eq 3  ]; then
	searchIP $ipadd; #Pensar como hacerlo como lista para poner varios filtros a la vez
else
	helpPanel;
fi
