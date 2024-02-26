#!/bin/bash

if [ "$EUID" -ne 0 ]
    then
        echo;echo "[!] You must run the setup as root!";echo
        exit
fi

echo;echo "-> Installing dependencies and starting services...";echo

sudo apt install nmap dirb sslscan dnsutils sendemail postfix golang subfinder -y

curr_path=$(/bin/pwd); \
cd /opt; \
git clone https://github.com/projectdiscovery/httpx.git; \
cd httpx/cmd/httpx; \
go build; \
mv httpx /usr/local/bin/; \
cd $curr_path;

sudo systemctl enable postfix && sudo service postfix start

python3 -m pip install --upgrade requests
python3 -m pip install --upgrade ultimate_sitemap_parser
python3 -m pip install --upgrade shcheck

echo;echo "-> Done!";echo
