#!/bin/bash

# sudo sh -c 'wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor'

# echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" | sudo tee /etc/apt/sources.list.d/virtualbox.list

# sudo apt update

# apt list ~nvirtualbox-[0-9]


# # ajout User au groupe vboxusers pour USB
# sudo usermod -aG vboxusers $USER

# # installation kernel

# uname -r

# # Par exemple, si la commande renvoie 3.11-2-amd64, cela veut dire que le noyau est 311

# sudo apt install --reinstall linux-headers-$(uname -r) virtualbox-dkms dkms