# fedora-update
## Utility for Fedora upgrade, flatpak update and firmware update

An automated script to perform update tasks on Fedora using DNF and flatpak, as well as firmware upgrades using fwupd

I made this thing some time ago, i use it every couple days to update my machine. The script refreshes DNF metadata, performs an upgrade as well as updates all the flatpaks. At the end it asks if you want to reboot.

The script is just a few update commands and a function to gracefully terminate DNF with SIGINT. I have it in my ~/bin folder named "myupdate", so every time i execute "myupdate" command in the terminal, it takes care of everything.

I did NOT implement non-interactive dnf, firmware or flatpak updates, just as a safety measure, so in case you spot a bad update or bad vendor, you can cancel or abort it and interact with it.

Here are the contents of the bash script fiile:
```bash
#!/bin/bash

# Define color codes
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

# Function to handle SIGINT
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

```


You can just do "nano ~/bin/myupdate" and paste the contents into it. Afterwards "chmod a+x ~/bin/myupdate" and you are ready to roll.

Hope someone finds it useful!
