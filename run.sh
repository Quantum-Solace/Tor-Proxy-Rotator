#!/usr/bin/sh

startAnonsurf() {
    read -p "Enter time between proxy switch in seconds: " proxyTime 
    echo "Time set to: ${proxyTime} seconds"  
   
    anonsurf start 
    while :
    do
        sleep $proxyTime 
        anonsurf change    
        
        ctrl_c() {
            echo "\n"
            echo "Stopping Anonsurf..."
            anonsurf stop
            exit 1
        }
        trap ctrl_c 2
    done
}

# SCRIPT START 
if [[ $EUID -ne 0 ]]; 
then
    echo "$0 is not running as root. Try using sudo"
    exit 2
fi

read -p "Do you have anonsurf installed? y/n: " choice

if [[ $choice == "y" ]] || [[ $choice == "yes" ]];
then
    apt update -y && apt full-upgrade -y && apt autoremove -y && apt install git -y && apt install tor -y
    git clone https://github.com/Und3rf10w/kali-anonsurf.git
    cd kali-anonsurf
    ./installer.sh
    read -p "Do you wish to start Anonsurf proxy rotate? y/n: " choice2
    if [[ $choice2 == "y" ]] || [[ $choice2 == "yes" ]];
    then
        startAnonsurf
    elif [[ $choice2 == "n" ]] || [[ $choice2 == "no" ]];
    then
        exit 1
    else
        exit 1
    fi
elif [[ $choice == "n" ]] || [[ $choice == "no" ]];
then 
   startAnonsurf 
else
    echo "No option selected, stopping script..."
fi
