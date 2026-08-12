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
	echo -e "\t ${purpleColour} -y <MACHINENAME> ${endColour} ${grayColour}  Buscar url yotube por nombre de maquina ${endColour}"
	echo -e "\t ${purpleColour} -d <difficultad> ${endColour} ${grayColour}  Buscar máquinas por dificultad ${endColour}"
	echo -e "\t ${purpleColour} -o <so> ${endColour} ${grayColour}  Buscar máquinas por so ${endColour}"
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
	machinename="$( grep "ip: \"$ipadd\"" bundle.js -B 3 | grep "name: " | awk '{print$2}' | sed 's/[",]//g')"
	if [[ -z "$machinename" ]]; then 
		echo -e "\n ${redColour} No existe ninguna máquina con la IP: $ipadd  ${endColour}"
		return 1;
	fi
	searchMachine $machinename
}

function searchYT(){
	machinename="$1";
	if machine_exist $1; then 
		echo "The machine does not exist"
	else 
	        echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Searching youtube link for machine: $machinename ${endColour} \n";
		#url="$(awk "/name: \"$machinename\"/,/youtube:/ { if ($1 ~ /youtube:/) print $NF }" ./bundle.js | sed 's/[",]//g')";	
		url="$(awk "/name: \"$machinename\"/,/youtube:/" bundle.js | tail -1 | awk 'NF{print$NF}' | sed 's/[",]//g')"
		echo -e "\n ${yellowColour}[+]${endColour} ${grayColour}Youtube URL : $url ${endColour} \n";
	fi
}

function machine_exist(){
	name="$(awk "/name: \"$1\"/" bundle.js)"
	if [[ -z name  ]]; then #Si la maquina existe
		return 1;
	else 
		return 0;
	fi
}

function filter_os(){
	so=$1
	#machines="$(grep "so: \"$1\"" -B 5 bundle.js | grep name | awk 'NF{print$NF}' | tr -d '"' | tr -d ',' | column)"
	machines="$(grep "so: \"$1\"" -B 5 bundle.js | grep name | awk 'NF{print$NF}' | tr -d '"' | tr -d ',' | column)"
	if [[ -z $machines  ]]; then
		echo -e "\n ${redColour} No existe ninguna máquina con el os: $so  ${endColour}"
		return 1;
	else 	
		echo -e "\n ${yellowColour}[+]${endColour} ${grayColour} Se encontraron las máquinas con os: $so: \n $machines ${endColour} \n";
	fi

}

function filter_diff(){
	diff=$1
	machines="$(grep "dificultad: \"$diff\"" -B 5 bundle.js | grep name | awk 'NF{print$NF}' | tr -d '"' | tr -d ',' | column)"
	if [[ -z $machines  ]]; then
		echo -e "\n ${redColour} No existe ninguna máquina con dificultad: $diff  ${endColour}"
		return 1;
	else 	
		echo -e "\n ${yellowColour}[+]${endColour} ${grayColour} Se encontraron las máquinas con dificultad: $diff: \n $machines ${endColour} \n";
	fi
}

function filter_diff_os(){	
	diff=$1
	so=$2
	echo -e "\n Se buscaran las maquinas con dificultad : $diff y so: $so";
	a="$(filter_os $so | xargs -n1)"
	b=$(filter_diff $diff | xargs -n1);
	echo "$a" | grep -Fxf <(echo "$b")
}

#Indicadores
declare -i parameter_counter=0 #entero declarado en 0
declare location="$(pwd)"
declare temp_location="htbmachines_bundle"
mkdir -p "/tmp/$temp_location"
#Menu de inputs viables
#: para listar varios
while getopts "n:i:y:o:d:hu" arg; do
	case $arg in
		n) machineName=$OPTARG; let parameter_counter+=1;;
		h) ;; #Indicamos la funcion a llamar
		u) let parameter_counter+=2;;
		i) ipadd=$OPTARG; let parameter_counter+=3;; #Caracteristica de la maquina, para mostrar todas las que hagan match
		y) machineName=$OPTARG; let parameter_counter+=4;; 
		o) so=$OPTARG; let parameter_counter+=5;; 
		d) difficulty=$OPTARG; let parameter_counter+=6;; 
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName; #TODO escribir la funcion	
elif [ $parameter_counter -eq 2  ]; then
	updatejsbundle;
elif [ $parameter_counter -eq 3  ]; then
	searchIP $ipadd; #Pensar como hacerlo como lista para poner varios filtros a la vez
elif [ $parameter_counter -eq 4  ]; then
	searchYT $machineName ; 
elif [ $parameter_counter -eq 5  ]; then
	filter_os $so ;
elif [ $parameter_counter -eq 6  ]; then
	filter_diff $difficulty ;
elif [ $parameter_counter -eq 11  ]; then #Se filtra por os y dificultad a la vez
	filter_diff_os $difficulty $so;
else
	helpPanel;
fi
