#!/bin/bash

# Function to handle clean exit on Ctrl+C
ctrl_c() {
    echo -e "\nStopping Anonsurf..."
    anonsurf stop
    exit 1
}
trap ctrl_c INT

# Function to start Anonsurf and manage proxy rotation
startAnonsurf() {
    read -rp "Enter time between proxy switch in seconds: " proxyTime
    echo "Time set to: ${proxyTime} seconds"

    if ! command -v anonsurf &> /dev/null; then
        echo "Anonsurf is not installed. Please install it first."
        exit 1
    fi

    anonsurf start

    while true; do
        sleep "$proxyTime"
        anonsurf change
    done
}

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "$0 is not running as root. Try using sudo."
    exit 2
fi

# Prompt for Anonsurf installation
read -rp "Do you have Anonsurf installed? (y/n): " choice

case "$choice" in
    [Yy]*)
        echo "Updating system and installing dependencies..."
        apt update -y && apt full-upgrade -y && apt autoremove -y && apt install -y git tor

        if [[ ! -d "kali-anonsurf" ]]; then
            echo "Cloning Anonsurf repository..."
            git clone https://github.com/Und3rf10w/kali-anonsurf.git
        fi

        cd kali-anonsurf || { echo "Failed to navigate to kali-anonsurf directory."; exit 1; }

        echo "Running Anonsurf installer..."
        ./installer.sh || { echo "Anonsurf installation failed."; exit 1; }

        read -rp "Do you wish to start Anonsurf proxy rotation? (y/n): " choice2
        case "$choice2" in
            [Yy]*)
                startAnonsurf
                ;;
            [Nn]*)
                echo "Exiting script."
                exit 0
                ;;
            *)
                echo "Invalid option selected, stopping script..."
                exit 1
                ;;
        esac
        ;;
    [Nn]*)
        startAnonsurf
        ;;
    *)
        echo "Invalid option selected, stopping script..."
        exit 1
        ;;
esac
