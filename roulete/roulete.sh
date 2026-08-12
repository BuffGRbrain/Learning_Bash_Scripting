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

function roulete_output(){
	prediction=$1
	echo -e " \n[+] El usuario aposto a $prediction \n"
	result=$(shuf -i 0-37 -n 1)
	echo -e "\n El resultado fue $result \n "
	if (( result % 2 == 0  )); then 
		if (( result == 0)); then 
			echo -e "\n The House wins \n"
			return 1;
		elif [ "par" == "$prediction"  ]; then
			return 0 #Un code exitoso es par
		fi
	else
		if [ "impar" == "$prediction"  ]; then
			return 0
		fi 
	fi
	echo -e "\n The House wins \n"
	return 1;
}

function helpPanel(){
	echo "METE DINERO Y APUESTA XD";
	echo "Tecnicas disponibles: martingala/l_inversa"
}

function printArray(){
	array=("$@");
	for element in "${array[@]}"; do
		echo " Item : $element";
	done
}


function sumArray(){

	array=("$@");
	declare -i sum=0;
	for element in "${array[@]}"; do
		(( sum += element  ));
	done
	echo "Current Total: $sum";

}

declare -a labrouchere=(1 2 3 4); #TODO Add more array options, to bet 15, 21, 28 and so on. 

declare -i extremos;

function l_inversa(){
	current_money=$1;
	echo -e "[+] Iniciamos a apostar con labrouchere inversa con el siguiente array de base:  \n"
	printArray "${labrouchere[@]}";
	echo -n "[+] Criterio de apuesta: " && read even_odd;
	if [[ $even_odd == "par" || $even_odd == "impar"  ]]; then 
		echo "Criterio de apuesta valido";
	else
		echo -e "\n SKILL ISSUE: Criterios aceptados \"par\" o \"impar\" "
		return 1;
	fi
	echo -e "\n Se va a apostar en bloques de a 10 el total de $current_money  a $even_odd \n";
	
	play_counter=0;#Contador de apuestas
	loss_counter=0;#Contador de resultados desfavorables
	win_counter=0;
	while [[ $current_money -gt 9 ]]; do #10 or more to bet in 10 increments
		echo -e "\n Se tiene $current_money y se apostara 10 \n" ;
		
		labrouchere=(1 2 3 4);	
		while (( ${#labrouchere[@]} > 1 )); do #If its empty, there is no more money to bet 
			roulete_output $even_odd; #El output es 0 si gana y 1 si pierde así como en Linux. 
			apostando=$? #Captura output del ultimo comando 
			if [[ $apostando == 0 ]]; then #WIN
				
				extremos=$(( labrouchere[0] + labrouchere[-1]  ))
				labrouchere+=($extremos)	
				labrouchere=("${labrouchere[@]}") #Re-Index
				echo "[!] Has ganado $extremos pavos"
				printArray "${labrouchere[@]}";
				#Print current labrouchere status
				(( win_counter++ ));

			else	#unwin xd
				
				extremos=$(( labrouchere[0] + labrouchere[-1]  ))

				echo "[!] Has perdido $extremos pavos"

				unset 'labrouchere[0]';
				unset 'labrouchere[-1]';
				labrouchere=("${labrouchere[@]}") #Re-Index	
				#PRINT CURRENT LABROUCHERE STATUS			
					
				printArray "${labrouchere[@]}";
				(( loss_counter++ )) ;
			fi
		
			(( play_counter++ ));
			declare -i sum=0;
			for element in "${labrouchere[@]}"; do
				(( sum += element  ));
			done
			echo "[!!] Dinero total actual luego de $play_counter jugadas : $sum"
			if [[ $sum -ge 40  ]]; then 
				echo "[Has ganado 30 pavos y recuperaste los 10 inciales, se reinicia labrouchere]"
				(( current_money +=  sum - 10  ))
				
				echo -e "[\$\$] Dinero restante $current_money"
				break
			else 
				sum=0;
			fi 
		done	
		
		if [[ $sum -eq 0  ]]; then 
			echo "Perdiste 10 euros"
			echo -e "\n Resultados finales: \n Total Jugadas: $play_counter  \n Total ganadas: $win_counter \n Total perdidas: $loss_counter";
			((current_money-=10))
			echo -e "[\$\$] Dinero restante $current_money"
		fi
		
	done
	echo -e "\n Resultados finales: \n Total Jugadas: $play_counter  \n Total ganadas: $win_counter \n Total perdidas: $loss_counter";
	echo -e "[\$\$] Dinero restante $current_money"

}
#Metodo: SI se pierde,se apuesta el doble en lo mismo.
function martingala(){
	current_money=$1;
	echo -e "\n [+] Dinero actual: $current_money";	
	echo -n "[+] Cantidad a apostar: " && read initial_bet;
	
	
	# Check if numeric using echo and grep
	if echo "$initial_bet" | grep -q '^[0-9]\+$'; then
	    echo "Success: '$initial_bet' is a valid integer."
	else
	    echo "Error: '$initial_bet' is not numeric."
	fi

	echo -n "[+] Criterio de apuesta: " && read even_odd;
	if [[ $even_odd == "par" || $even_odd == "impar"  ]]; then 
		echo "Criterio de apuesta valido";
	else
		echo -e "\n SKILL ISSUE: Criterios aceptados \"par\" o \"impar\" "
		return 1;
	fi
	echo -e "\n Se va a apostar $initial_bet a $even_odd \n";

	current_bet=$initial_bet;
	play_counter=0;#Contador de apuestas
	loss_counter=0;#Contador de resultados desfavorables
	win_counter=0;
	while [[ $current_money -gt 0 ]]; do 
		echo -e "\n Se tiene $current_money y se aposatara $current_bet \n" ;
		roulete_output $even_odd; #El output es 0 si gana y 1 si pierde así como en Linux. 
		apostando=$? #Captura output del ultimo comando 
		echo -e "El resultado de la ruleta fue $apostando \n"
		if [[ $apostando == 0 ]]; then 
			(( current_money += current_bet ));#Mantiene su plata y gana lo mismo que aposto., SI gana mantiene la plata
			(( current_bet = initial_bet )); #AL ganar se reinicia
			(( win_counter++ ));

		else	
			(( current_money -= current_bet ));#No gana nada	
			(( current_bet += current_bet )); #Duplica si pierde
			(( loss_counter++ )) ;
		fi
		
		(( play_counter++ ));
		if (( current_bet > current_money  )); then 
			echo "NO tienes dinero para apostar THE HOUSE ALWAYS WINS";
			echo -e "\n Dinero restante: $current_money , Dinero a apostar segun Martingala $current_bet \n"
			break
		fi	

	done
	echo -e "\n Resultados finales: \n Total Jugadas: $play_counter  \n Total ganadas: $win_counter \n Total perdidas: $loss_counter";
}

#Indicadores
declare -i parameter_counter=0 #entero declarado en 0
declare location="$(pwd)"
declare temp_location="htbmachines_bundle"
mkdir -p "/tmp/$temp_location"
#Menu de inputs viables
#: para listar varios
while getopts "m:t:h" arg; do
        case $arg in
                m) initial_money=$OPTARG; let parameter_counter+=1;;
                h) helpPanel;; #Indicamos la funcion a llamar
                t) tecnica=$OPTARG; let parameter_counter+=1;;
        esac
done

echo "$parameter_counter";


if [ $initial_money ] && [ $tecnica  ]; then
	echo "Apostando $initial_money with technique $tecnica";
	if [ $tecnica == 'martingala'  ] ;then 
		martingala $initial_money;
	elif [ $tecnica == 'l_inversa'  ] ; then
		echo "Se apostara a la inversa"
		l_inversa $initial_money;
	else
		echo "La tecnica ingresada no es correcta"
		helpPanel;
	fi
else
	helpPanel;
fi
