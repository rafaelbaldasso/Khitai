#!/bin/bash

if [ "$EUID" -ne 0 ]
    then
        echo;echo "[!] You must run the setup as root!";echo
        exit
fi

echo;echo "-> Installing dependencies and starting services...";echo

sudo apt install nmap sslscan dnsutils sendemail postfix -y

sudo systemctl enable postfix && sudo service postfix start

wget https://raw.githubusercontent.com/santoru/shcheck/master/shcheck.py
wget https://raw.githubusercontent.com/Ogglas/Orignal-Slowloris-HTTP-DoS/master/slowloris.pl

chmod +x shcheck.py slowloris.pl

echo;echo "-> Done!";echo
