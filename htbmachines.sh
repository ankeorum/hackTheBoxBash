#!/bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

#Ctrl+C
function ctrl_c(){
  echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
  tput cnorm && exit 1
}

trap ctrl_c INT

#Variables Globales
main_url="https://htbmachines.github.io/bundle.js"

function helpPanel(){
  echo -e "\n\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}\n"
  echo -e "\t${purpleColour}-u:${endColour} \t${grayColour}Actualizar registro de máquinas${endColour}"
  echo -e "\t${purpleColour}-m:${endColour} \t${grayColour}Buscar por un nombre de máquina${endColour}"
  echo -e "\t${purpleColour}-y:${endColour} \t${grayColour}Buscar link de youtube${endColour}"
  echo -e "\t${purpleColour}-d:${endColour} \t${grayColour}Buscar según dificultad de la máquina${endColour}"
  echo -e "\t${purpleColour}-o:${endColour} \t${grayColour}Buscar por sistema operativo${endColour}"
  echo -e "\t${purpleColour}-s:${endColour} \t${grayColour}Buscar por skill${endColour}"
  echo -e "\t${purpleColour}-i:${endColour} \t${grayColour}Buscar por dirección IP${endColour}"
  echo -e "\t${purpleColour}-h:${endColour} \t${grayColour}Mostrar este panel de ayuda${endColour}\n"
  # echo -e "\n\n${yellowColour}[+]${endColour} ${grayColour}Uso:${endColour}\n"
}

function updateMachineList(){
  echo -e "\n\n${greenColour}[+]${endColour} ${blueColour}Comenzando las actualizaciones...${endColour}"
  if [ ! -f bundle.js ]; then
    tput civis
    echo -e "\t${purpleColour}[+]${endColour} \t${grayColour}Descargando registro de máquinas...${endColour}"
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\t${purpleColour}[+]${endColour} \t${grayColour}Registro de máquinas descargado${endColour}"
    tput cnorm
  else
    tput civis
    echo -e "\t${purpleColour}[+]${endColour} \t${grayColour}Actualizando registro de máquinas...${endColour}"
    rm bundle.js
    curl -s $main_url > bundle.js
    js-beautify bundle.js | sponge bundle.js
    echo -e "\t${purpleColour}[+]${endColour} \t${grayColour}Registro de máquinas actualizado${endColour}"
    tput cnorm
  fi
}

function searchMachine(){
  machineName="$1"

  machineNameChecker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//')"
  if [ $parameter_counter -eq 3 ]; then
    echo -e "${yellowColour}[+]${endColour} \t${grayColour}La máquina ${endColour}${blueColour}$machineName${endColour}${grayColour} corresponde a la IP consultada y sus detalles son:${endColour}"
    cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
  else
    if [ "$machineNameChecker" ]; then
      echo -e "${yellowColour}[+]${endColour} \t${grayColour}Listando las propiedades de la máquina ${endColour}${blueColour}$machineName${endColour}${grayColour}:${endColour}"
      cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//'
    else
      echo -e "${redColour}[+]${endColour} \t${grayColour}La máquina ${endColour}${blueColour}$machineName${endColour}${grayColour} no existe${endColour}"
    fi
  fi
}

function searchIP(){
  ipAddress="$1"
  
  machineNameCheckerIP="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
  
  if [ "$machineNameCheckerIP" ]; then
    machineName="$(cat bundle.js | grep "ip: \"$ipAddress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"
    echo -e "${yellowColour}[+]${endColour} \t${grayColour}Buscando la máquina correspondiente a la IP:${endColour} ${blueColour} $ipAddress${endColour}${grayColour}...${endColour}\n"
    searchMachine $machineName
  else
    echo -e "${redColour}[!]${endColour} \t${grayColour}La máquina con la dirección IP:${endColour}${blueColour} $ipAddress${endColour}${grayColour} no existe${endColour}\n"
  fi
}

function searchYoutube(){
  machineNameYt="$1"
  
  youtubeLinkChecker="$(cat bundle.js | awk "/name: \"$machineNameYt\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube: | awk 'NF{print $NF}')"
  if [ "$youtubeLinkChecker" ]; then
    youtubeLink="$(cat bundle.js | awk "/name: \"$machineNameYt\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta:" | tr -d '"' | tr -d ',' | sed 's/^ *//' | grep youtube: | awk 'NF{print $NF}')"
    echo -e "${yellowColour}[+]${endColour} \t${grayColour}La guía para la resolución de la máquina${endColour}${blueColour} $machineNameYt${endColour}${grayColour} es: ${endColour}${blueColour}$youtubeLink${endColour}\n"
  else
    echo -e "${redColour}[!]${endColour} \t${grayColour}La máquina${endColour}${blueColour} $machineNameYt${endColour}${grayColour} no existe${endColour}\n"
  fi
  }

  function getMachinesDifficulty(){
    diff="$1"

    results_check="$(cat bundle.js | grep "dificultad: \"$diff\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

  if [ "$results_check" ]; then
    echo -e "\n${yellowColour}[+]${endColour}${grayColour} Representando las máquinas con la dificultad${endColour}${blueColour} $diff${endColour}${grayColour}:${endColour}\n"
    cat bundle.js | grep "dificultad: \"$diff\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
  else
    echo -e "${redColour}[!]${endColour} \t${grayColour}La dificultad indicada no existe${endColour}\n"
  fi
  }

  function getOsMachines(){
    os="$1"

    results_check="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

    if [ "$results_check" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas del sistema operativo:${endColour}${blueColour} $os${endColour}${grayColour} que hemos encontrado son las siguientes\n${endColour}"
    cat bundle.js | grep "so: \"$os\"" -B 5 | grep name | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
      echo -e "${redColour}[!]${endColour} \t${grayColour}No hemos encontrado ninguna máquina con el sistema operativo indicado${endColour}\n"
      
    fi
  }

  function getOsDifficultyMachines(){
    diff="$1"
    os="$2"

    results_check="$(cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$diff\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    if [ "$results_check" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas del sistema operativo:${endColour}${blueColour} $os${endColour}${grayColour} y con una dificultad:${endColour}${blueColour} $diff${endColour}${grayColour} que hemos encontrado son las siguientes\n${endColour}"
      cat bundle.js | grep "so: \"$os\"" -C 4 | grep "dificultad: \"$diff\"" -B 5 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
      echo -e "${redColour}[!]${endColour} \t${grayColour}No hemos encontrado ninguna máquina los criterios indicado${endColour}\n"
    fi 
  }

  function getSkillsMachine(){
    skill="$1"

    results_check="$(cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"
    if [ "$results_check" ]; then
      echo -e "\n${yellowColour}[+]${endColour}${grayColour} Las máquinas con la skill:${endColour}${blueColour} $skill${endColour}${grayColour} que hemos encontrado son las siguientes\n${endColour}"
      cat bundle.js | grep "skills: " -B 6 | grep "$skill" -i -B 6 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
    else
      echo -e "${redColour}[!]${endColour} \t${grayColour}No hemos encontrado ninguna máquina con la skill indicada${endColour}\n"     
    fi
  }
#Indicadores
declare -i parameter_counter=0

#Chivatos
declare -i chivato_difficulty=0
declare -i chivato_os=0

while getopts "m:ui:y:d:o:s:h" arg; do
  case $arg in
    m) machineName=$OPTARG; let parameter_counter+=1;;
    u) let parameter_counter+=2;;
    i) ipAddress=$OPTARG; let parameter_counter+=3;;
    y) machineNameYt=$OPTARG; let parameter_counter+=4;;
    d) difficulty=$OPTARG; chivato_difficulty=1; let parameter_counter+=5;;
    o) os=$OPTARG; chivato_os=1; let parameter_counter+=6;;
    s) skill=$OPTARG; let parameter_counter+=7;;
    h) ;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
  updateMachineList
elif [ $parameter_counter -eq 3 ]; then
  searchIP $ipAddress
elif [ $parameter_counter -eq 4 ]; then
  searchYoutube $machineNameYt
elif [ $parameter_counter -eq 5 ]; then
  getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
  getOsMachines $os
elif [ $parameter_counter -eq 7 ]; then
  getSkillsMachine "$skill"
elif [ $chivato_difficulty -eq 1 ] && [ $chivato_os -eq 1 ]; then
  getOsDifficultyMachines $difficulty $os
else
  helpPanel
fi
