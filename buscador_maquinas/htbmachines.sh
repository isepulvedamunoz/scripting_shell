#!/bin/bash
# Colours
greenColour="\\e[0;32m\\033[1m"
endColour="\\033[0m\\e[0m"
redColour="\\e[0;31m\\033[1m"
blueColour="\\e[0;34m\\033[1m"
yellowColour="\\e[0;33m\\033[1m"
purpleColour="\\e[0;35m\\033[1m"
turquoiseColour="\\e[0;36m\\033[1m"
grayColour="\\e[0;37m\\033[1m"

function ctrl_c(){
echo -e "\
\
${redColour}[!] Saliendo... ${endColour}\
"
exit 1
}

trap ctrl_c INT

#Variables globales

main_url="https://htbmachines.github.io/bundle.js"



function helpPanel(){
  echo -e "\n[+] Uso:"

  echo -e "\tu) Descargar o actualizar archivos necesarios"
  echo -e "\tm) Buscar por un nombre de maquina"
  echo -e "\ti) Buscar por dirección IP"
  echo -e "\ty) Otener link de la resolución de la máquina en Youtube"
  echo -e "\td) Buscar por la dificultad de una maquina"
  echo -e "\to: Buscar por el sistema Operativo de la máquina"
  echo -e "\ts) Buscar por skills"
  echo -e "\th) Mostrar panel de ayuda"


}


function searchMachine(){
  machineName="$1"
  echo "$machineName"
}


function updateFiles(){
  echo -e "\n[+] Comprobando si hay actualizaciones\n"

  sleep 2

  if [ ! -f bundle.js ]; then
    echo "El archivo no existe. Descargando archivos necesarios..."
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo "Todos los archivos han sido descargados."

  else
    echo "Comprobando si hay actualizaciones pendientes......"
    curl -s $main_url > bundle_temp.js
    js-beautify bundle_temp.js | sponge bundle_temp.js
    md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
    md5_original_value=$(md5sum bundle.js | awk '{print $1}')

    if [ "$md5_temp_value" == "$md5_original_value" ]; then
      echo "No hay actualizaciones"
      rm bundle_temp.js
    else
      echo "Si hay actualizaciones"
      sleep 1
      rm bundle.js && mv bundle_temp.js bundle.js
      echo -e "[+] Los archivos han sido actualizados"


    fi


    echo $md5_temp_value
    echo $md5_original_value
  fi

 # curl -s $main_url > bundle.js
 # js-beautify bundle.js | sponge bundle.js
}


function searchMachine(){
  machineName="$1"

  machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d ','| tr -d '"' | sed 's/^ *//' | sed 's/:/ -> /')"
  
  if [ "$machineName_checker" ]; then

    echo -e "\n [+] Listando las propiedades de la máquina\n" 
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d ','| tr -d '"' | sed 's/^ *//' | sed 's/:/ -> /'
  else   
    echo -e "\n [+] La máquina proporcionada no existe.\n" 
  fi
}


function searchIP(){
  idAddress="$1"
  
  machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  
  if [ "$machineName" ]; then

    echo -e "[+] La máquina correspondiente para la IP es $machineName!!"
    searchMachine $machineName
  else
    echo -e "[+] La IP proporcionada no existe!"
  fi


}


function getYoutubeLink(){
  machineName="$1"
  youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube | awk 'NF{print $NF}')"
  
  if [ "$youtubeLink" ]; then
    echo -e "[+] El tutorial para esta maquina esta en el siguiente enlace: $youtubeLink"
  else
    echo -e "[+] La máquina proporcionada no existe!"
  fi
}



function getMachinesDifficulty(){
  difficulty="$1"

  resultsCheck="$(cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$resultsCheck" ]; then
    echo -e "[+] Representando las maquinas que poseen un nivel de dificultad $difficulty"
    cat bundle.js | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "[+] La dificultad proporcionada no existe!"
  fi

}


function getOSMachines(){
  os="$1"

  resultsCheck="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$resultsCheck" ]; then
    echo -e "[+] Representando las maquinas que poseen un sistema operativo $os"
    cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "[+] El sistema operativo proporcionado no existe!"
  fi

}


function getOSDifficultyMachines(){
  os="$1"
  difficulty="$2"

  resultsCheck="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$resultsCheck" ]; then
    echo -e "[+] Representando las maquinas que poseen un sistema operativo $os y un nivel de dificultad $difficulty"
    cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$difficulty\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "[+] No hay máquinas que cumplan con los criterios proporcionados!"
  fi

}



function getMachinesBySkills(){
  skills="$1"

  resultsCheck="$(cat bundle.js| grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | awk 'NF{print $NF}'  | tr -d '"' | tr -d ',' | column)"

  if [ "$resultsCheck" ]; then
    echo -e "[+] Representando las maquinas que poseen la skill $skills"
    cat bundle.js| grep "skills: " -B 6 | grep "$skills" -i -B 6 | grep "name: " | awk 'NF{print $NF}'  | tr -d '"' | tr -d ',' | column
  else
    echo -e "[+] La skill proporcionada no existe!"
  fi

}


#Indicadores
declare -i parameter_counter=0

declare -i chivato_difficulty=0
declare -i chivato_os=0


while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName="$OPTARG"; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress="$OPTARG"; let parameter_counter+=3;;
    y) machineName="$OPTARG"; let parameter_counter+=4;;
    d) difficulty="$OPTARG"; chivato_difficulty=1; let parameter_counter+=5;;
    o) os="$OPTARG"; chivato_os=1; let parameter_counter+=6;;
    s) skills="$OPTARG"; let parameter_counter+=7;;
    h) ;;
  esac
done


if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateFiles
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOSMachines $os
elif [ $parameter_counter -eq 7 ]; then
  getMachinesBySkills "$skills"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  getOSDifficultyMachines $os $difficulty
else
  helpPanel

fi

