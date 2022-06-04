#!/bin/bash

if [ "$EUID" -ne 0 ]
then
    echo;echo "[!] You must run the installer as root!";echo
    exit
fi

apt update
apt install -y python3 golang gobuster nmap seclists sslscan whatweb
go install github.com/tomnomnom/assetfinder@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
go install github.com/tomnomnom/waybackurls@latest
wget https://raw.githubusercontent.com/santoru/shcheck/master/shcheck.py
wget https://raw.githubusercontent.com/Ogglas/Orignal-Slowloris-HTTP-DoS/master/slowloris.pl
chmod +x shcheck.py slowloris.pl
