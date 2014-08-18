#!/bin/bash

VERSION=1.0
GRUBCFG="/etc/default/grub"
GRUBBKP="/var/tmp/grub $(date +'%m-%d-%Y %H%M%S')"

function isroot {
        if [ $(id -u) -eq 0 ]; then
                return 1
        else
                return 0
        fi
}

if [ -z $1 ]; then
        echo "Missing parameter. Type $0 --help for further information."
        exit
fi

if [ ! -f $GRUBCFG ]; then
        echo "File $GRUBCFG not found. GRUB2 is really installed?"
        exit
fi

if [ $1 == "--help" ]; then
        echo "Set TERMINAL and GRUB2 resolution."
        echo " "
        echo "terminal-resolution.sh [width_resxheight_res] [-yn]"
        echo " "
        echo "-y\tAnswer Y to reboot question"
        echo "-n\tNo reboot"
        echo " "
        echo "NOTE: You must be root in order to run it!"
        echo " "
        exit
fi

if [ isroot ]; then
        echo "Setting TERMINAL"
        echo "Backup original file '$GRUBCFG' to '$GRUBBKP'"

        cp "$GRUBCFG" "$GRUBBKP"
        sed -i 's/#GRUB_GFXMODE/GRUB_GFXMODE/' "$GRUBCFG"
        sed -i 's/^\(GRUB_GFXMODE=\).*/\1'$1'/' "$GRUBCFG"

        if [ $(grep -ci "GRUB_GFXPAYLOAD_LINUX" "$GRUBCFG") ]; then
                echo "GRUB_GFXPAYLOAD_LINUX=keep" >> "$GRUBCFG"
        else
                sed -i 's/^\(GRUB_GFXPAYLOAD_LINUX=\).*/\1keep/' "$GRUBCFG"
        fi

        update-grub2

        if [ "$2" == "-y" ]; then
                reboot
        else
                if [ "$2" == "-n" ]; then exit; fi

                read -p "Reboot? (y/n) "
                if [ $REPLY == "y" ] || [ $REPLY == "Y" ]; then
                        reboot
                fi
        fi
else
        echo "Error: You must be root in order to run"
        exit
fi
