#!/bin/bash

# Function to start anonsurf
startAnonsurf() {
    # Prompt for time between proxy switch in minutes
    while true; do
        read -p "Enter time between proxy switch in minutes: " proxyTime
        # Validate input to ensure it's a positive integer
        if [[ "$proxyTime" =~ ^[0-9]+$ ]]; then
            break
        else
            echo "Please enter a valid number of minutes."
        fi
    done

    # Convert minutes to seconds
    proxyTime=$((proxyTime * 60))
    echo "Time set to: ${proxyTime} seconds"

    # Start anonsurf and check if it succeeds
    if ! anonsurf start; then
        echo "Failed to start Anonsurf. Please check if it is installed and try again."
        exit 1
    fi

    # Infinite loop to change proxy and show current IPs
    while :; do                                                                                                                                                                             
        echo "Current IPv4 address:"                                                                                                                                                        
        if ! curl -s icanhazip.com; then                                                                                                                                                    
            echo "Error retrieving IPv4 address."                                                                                                                                           
        fi                                                                                                                                                                                  
                                                                                                                                                                                            
        echo "Current IPv6 address (if available):"                                                                                                                                         
        if ! curl -6 -s icanhazip.com; then                                                                                                                                                 
            echo "Error retrieving IPv6 address or IPv6 not available."                                                                                                                     
        fi                                                                                                                                                                                  
                                                                                                                                                                                            
        sleep $proxyTime                                                                                                                                                                    
                                                                                                                                                                                            
        # Change proxy and check if it succeeds                                                                                                                                             
        if ! anonsurf change; then                                                                                                                                                          
            echo "Failed to change Anonsurf proxy."                                                                                                                                         
            exit 1                                                                                                                                                                          
        fi                                                                                                                                                                                  
    done                                                                                                                                                                                    
}                                                                                                                                                                                           
                                                                                                                                                                                            
# Ctrl+C handler to stop anonsurf                                                                                                                                                           
ctrl_c() {                                                                                                                                                                                  
    echo -e "\nStopping Anonsurf..."                                                                                                                                                        
    anonsurf stop                                                                                                                                                                           
    exit 0                                                                                                                                                                                  
}                                                                                                                                                                                           
                                                                                                                                                                                            
# SCRIPT START                                                                                                                                                                              
# Check if running as root                                                                                                                                                                  
if [[ $EUID -ne 0 ]]; then                                                                                                                                                                  
    echo "$0 is not running as root. Try using sudo"                                                                                                                                        
    exit 1                                                                                                                                                                                  
fi                                                                                                                                                                                          
                                                                                                                                                                                            
# Check if necessary commands are available                                                                                                                                                 
if ! command -v anonsurf &> /dev/null || ! command -v curl &> /dev/null; then                                                                                                               
    echo "This script requires 'anonsurf' and 'curl'. Please install them and try again."                                                                                                   
    exit 1                                                                                                                                                                                  
fi                                                                                                                                                                                          
                                                                                                                                                                                            
# Set trap for Ctrl+C                                                                                                                                                                       
trap ctrl_c SIGINT                                                                                                                                                                          
                                                                                                                                                                                            
# Start Anonsurf                                                                                                                                                                            
startAnonsurf   
