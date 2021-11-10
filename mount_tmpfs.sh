#!/bin/bash

if [ -d /mnt/tmpfs ]; then
    echo " ";
else
    `mkdir -p /mnt/tmpfs`;
    echo "tmpfs directory is created"
fi

sudo mount -t tmpfs -o size=512M tmpfs /mnt/tmpfs
sudo cp /home/mininet/if_down.sh /mnt/tmpfs/
sudo chmod 777 -R /mnt/tmpfs/