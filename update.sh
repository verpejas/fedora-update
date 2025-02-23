#!/bin/bash

# Define color codes
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Function to handle SIGINT (Ctrl+C)
cleanup() {
    echo -e "\n${RED}Received SIGINT. Stopping the current task...${RESET}"
    
    # Kill all background jobs
    jobs -p | xargs -r sudo kill -SIGTERM
    
    # Ensure `dnf` is properly terminated
    sudo pkill -SIGTERM dnf 2>/dev/null
    sudo pkill -SIGTERM librepo 2>/dev/null

    echo -e "${RED}Exiting script safely.${RESET}"
    exit 1
}

# Trap SIGINT and call cleanup function
trap cleanup SIGINT

# Print the initial message in yellow
echo -e "${YELLOW}This script will: 
 - refresh DNF package cache, 
 - perform upgrade through DNF, 
 - install Flatpak updates, 
 - check device firmware updates using 'fwupdmgr' 

Provide your sudo password when asked!...
${RESET}"

# Run updates
flatpak update && sudo dnf upgrade --refresh

# Firmware updates
fwupdmgr refresh --force
fwupdate_status=$(fwupdmgr get-updates 2>&1)

# Color the actual output (No updates or actual updates)
echo -e "${YELLOW}$fwupdate_status${RESET}"

# Reboot prompt (Red)
echo -e "${RED}"
read -r -t 30 -p "Do you want to reboot now? [Y/N] (default: N): " reboot_answer
echo -e "${RESET}"
reboot_answer=${reboot_answer,,}  # Convert to lowercase

if [[ "$reboot_answer" == "y" || "$reboot_answer" == "yes" ]]; then
    echo -e "${RED}Rebooting now...${RESET}"
    sudo reboot
else
    echo -e "${RED}Exiting without rebooting.${RESET}"
fi
