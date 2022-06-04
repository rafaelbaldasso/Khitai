#!/bin/bash

### Requirements
# Kali Linux (recommended OS)
# Python3
# Assetfinder -> go install github.com/tomnomnom/assetfinder@latest
# Gobuster -> apt install gobuster
# Subfinder -> go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
# Nmap -> apt install nmap
# Seclists -> apt install seclists
# httpx -> go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
# Waybackurls -> go install github.com/tomnomnom/waybackurls@latest
# Shcheck -> wget https://raw.githubusercontent.com/santoru/shcheck/master/shcheck.py
# SSLScan -> apt install sslscan
# WhatWeb -> apt install whatweb
# Slowloris -> wget https://raw.githubusercontent.com/Ogglas/Orignal-Slowloris-HTTP-DoS/master/slowloris.pl

clear
echo -e "\033[38;2;220;20;60m
                  .
                  |
             .   ]#[   .
              \_______/
           .    ]###[    .
            \___________/             _  __  _       _   _             _
         .     ]#####[     .         | |/ / | |     (_) | |           (_)
          \_______________/          | ' /  | |__    _  | |_    __ _   _
       .      ]#######[      .       |  <   |  _ \  | | | __|  / _  | | |
        \___]##.-----.##[___/        | . \  | | | | | | | |_  | (_| | | |
         |_|_|_|     |_|_|_|         |_|\_\ |_| |_| |_|  \__|  \__ _| |_|
         |_|_|_|_____|_|_|_|
       #######################
\033[m"

if [ "$1" == "" ]
then
    echo;echo -e "\033[38;2;255;228;181m[>] Usage: sudo $0 <target>\033[m"
    echo -e "\033[38;2;255;228;181m[>] Example: sudo $0 github.com\033[m";echo
else
    if [ "$EUID" -ne 0 ]
    then
        echo;echo "[!] The tool must be executed as root!";echo
        exit
    fi
    target=$1
    PATH=$PATH:/root/go/bin
    bold=$(tput bold)
    echo;echo -e "\033[38;2;255;228;181m* All results are saved to $(pwd)/"$target".txt\033[m";echo
    PS3=$'\n''-> '
    options=("Security Headers" "Fingerprint Web Server" "SSL Scan" "Check WAF" "Subdomains Enumeration" "Discovery" "TCP Ports Scan" "UDP Ports Scan" "Slowloris DoS Test" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Security Headers")
                clear;echo;echo -e "\033[38;2;0;255;0m>>> Scanning...\033[m";echo
                c1=('python3 shcheck.py http://'$target'')
                c2=('python3 shcheck.py https://'$target'')
                echo > /tmp/headers.txt;echo -e "\033[38;2;220;20;60m${bold}>>> Security Headers (HTTP)\033[m" >> /tmp/headers.txt;echo >> /tmp/headers.txt;echo -e "\033[38;2;0;255;255m~ "$c1"\033[m" >> /tmp/headers.txt;echo >> /tmp/headers.txt
                $c1 | egrep "Analyzing headers|Effective URL|Missing|unreachable" | cut -d '(' -f1 >> /tmp/headers.txt
                echo >> /tmp/headers.txt;echo -e "\033[38;2;220;20;60m${bold}>>> Security Headers (HTTPS)\033[m" >> /tmp/headers.txt;echo >> /tmp/headers.txt;echo -e "\033[38;2;0;255;255m~ "$c2"\033[m" >> /tmp/headers.txt;echo >> /tmp/headers.txt
                $c2 | egrep "Analyzing headers|Effective URL|Missing|unreachable" | cut -d '(' -f1 >> /tmp/headers.txt
                echo >> /tmp/headers.txt
                cat /tmp/headers.txt >> $target.txt;echo >> $target.txt;echo "===========================================================================" >> $target.txt;echo >> $target.txt
                clear
                cat /tmp/headers.txt
                read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/headers.txt
                exec $0 $1
                ;;
            "Fingerprint Web Server")
                clear;echo;echo -e "\033[38;2;0;255;0m>>> Scanning...\033[m";echo
                c1=('whatweb '$target' --colour=never')
                c2=('curl -I '$target' -L -k -s')
                c3=('curl -I '$target' -L -k -X OPTIONS -s')
                echo > /tmp/fingerprint.txt;echo -e "\033[38;2;220;20;60m${bold}>>> Fingerprint Web Server\033[m" >> /tmp/fingerprint.txt;echo >> /tmp/fingerprint.txt;echo -e "\033[38;2;0;255;255m~ "$c1"\033[m" >> /tmp/fingerprint.txt;echo -e "\033[38;2;0;255;255m~ "$c2"\033[m" >> /tmp/fingerprint.txt;echo -e "\033[38;2;0;255;255m~ "$c3"\033[m" >> /tmp/fingerprint.txt
                $c1 > /tmp/fingerprint1.txt;cat /tmp/fingerprint1.txt | sed 's/, /?/g' | tr '?' '\n' | sed 's/^http/?http/' | tr '?' '\n' >> /tmp/fingerprint.txt;echo >> /tmp/fingerprint.txt
                $c2 | head -n -1 > /tmp/fingerprint2.txt;$c3 > /tmp/fingerprint3.txt;cat /tmp/fingerprint3.txt | grep -i "Allow" >> /tmp/fingerprint2.txt;sed -i '0,/^HTTP\/1.1 200 OK/d' /tmp/fingerprint2.txt;cat /tmp/fingerprint2.txt >> /tmp/fingerprint.txt
                echo >> /tmp/fingerprint.txt
                cat /tmp/fingerprint.txt >> $target.txt;echo >> $target.txt;echo "===========================================================================" >> $target.txt;echo >> $target.txt
                clear
                cat /tmp/fingerprint.txt
                read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/fingerprint1.txt /tmp/fingerprint2.txt /tmp/fingerprint3.txt /tmp/fingerprint.txt
                exec $0 $1
                ;;
            "SSL Scan")
                clear;echo;echo -e "\033[38;2;0;255;0m>>> Scanning...\033[m";echo
                c1=('sslscan '$target'')
                echo > /tmp/ssl.txt;echo -e "\033[38;2;220;20;60m${bold}>>> SSL Scans\033[m" >> /tmp/ssl.txt
                echo >> /tmp/ssl.txt;echo -e "\033[38;2;0;255;255m~ "$c1"\033[m" >> /tmp/ssl.txt
                $c1 | tail -n +3 1>>/tmp/ssl.txt 2>/dev/null;$c1 1>/dev/null 2>>/tmp/ssl.txt;echo >> /tmp/ssl.txt
                cat /tmp/ssl.txt >> $target.txt;echo >> $target.txt;echo "===========================================================================" >> $target.txt;echo >> $target.txt
                clear
                cat /tmp/ssl.txt
                read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/ssl.txt
                exec $0 $1
                ;;
            "Check WAF")
                clear;echo;echo -e "\033[38;2;0;255;0m>>> Scanning...\033[m";echo
                c1=('wafw00f -o - http://'$target'')
                c2=('wafw00f -o - https://'$target'')
                $c1 > /tmp/waf.txt 2>/dev/null;$c2 >> /tmp/waf.txt 2>/dev/null
                echo > /tmp/wafs.txt;echo -e "\033[38;2;220;20;60m${bold}>>> WAF\033[m" >> /tmp/wafs.txt
                echo >> /tmp/wafs.txt;echo -e "\033[38;2;0;255;255m~ "$c1"\033[m" >> /tmp/wafs.txt;echo -e "\033[38;2;0;255;255m~ "$c2"\033[m" >> /tmp/wafs.txt;echo >> /tmp/wafs.txt
                cat /tmp/waf.txt | sed 's/^...//' | sed 's/   /  -  /' | sed 's/None (None)/None/' | sed 's/Generic (Unknown)/Unknown/' >> /tmp/wafs.txt;echo >> /tmp/wafs.txt
                cat /tmp/wafs.txt >> $target.txt;echo >> $target.txt;echo "===========================================================================" >> $target.txt;echo >> $target.txt
                clear
                cat /tmp/wafs.txt
                read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/waf.txt /tmp/wafs.txt
                exec $0 $1
                ;;
            "Subdomains Enumeration")
                clear;echo;echo -e "\033[38;2;0;255;0m>>> Scanning...\033[m";echo
                c1=('subfinder -d '$target' -silent')
                c2=('assetfinder -subs-only '$target'')
                $c1 > /tmp/subs.txt;$c2 >> /tmp/subs.txt
                sort -u /tmp/subs.txt > /tmp/subdomains.txt
                sed -i '/^'$target'/d' /tmp/subdomains.txt
                c3=('httpx -silent -status-code -web-server -no-fallback -no-color')
                cat /tmp/subdomains.txt | $c3 > /tmp/subs.txt
                cat /tmp/subs.txt | sed 's/\[/\[HTTP /' | sed 's/\[\]/\[N\/A\]/' | grep -v "HTTP 404" > /tmp/subdomains.txt
                cat /tmp/subdomains.txt | sort -t/ -k 2 > /tmp/subs.txt
                echo > /tmp/subdomains.txt;echo -e "\033[38;2;220;20;60m${bold}>>> Subdomains Enumeration\033[m" >> /tmp/subdomains.txt;echo >> /tmp/subdomains.txt;echo -e "\033[38;2;0;255;255m~ "$c1"\033[m" >> /tmp/subdomains.txt;echo -e "\033[38;2;0;255;255m~ "$c2"\033[m" >> /tmp/subdomains.txt;echo -e "\033[38;2;0;255;255m~ cat subdomains | "$c3"\033[m" >> /tmp/subdomains.txt;echo >> /tmp/subdomains.txt
                cat /tmp/subs.txt >> /tmp/subdomains.txt;echo >> /tmp/subdomains.txt
                cat /tmp/subdomains.txt >> $target.txt;echo >> $target.txt;echo "===========================================================================" >> $target.txt;echo >> $target.txt
                clear
                cat /tmp/subdomains.txt
                read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/subs.txt /tmp/subdomains.txt
                exec $0 $1
                ;;
            "Discovery")
                clear;echo;echo -e "\033[38;2;0;255;0m>>> Scanning...\033[m";echo
                c1=('gobuster dir -u '$target' -e -x txt --hide-length -t 10 --delay 100ms --wildcard --timeout 5s -z -q -w /usr/share/seclists/Discovery/Web-Content/common-and-portuguese.txt')
                $c1 | egrep "Status: 200|Status: 301" | cut -d ' ' -f1 | tr -d '\r' | sort -u > /tmp/discovery.txt
                c2=('waybackurls -no-subs')
                echo $target | $c2 > /tmp/wayback.txt
                sed -i '/'$url'\/$/d' /tmp/wayback.txt
                cat /tmp/wayback.txt | egrep -i -v ".svg|.eot|.ttf|.woff|.css|.ico|.js|.gif|.jpg|.png|.jpeg" >> /tmp/discovery.txt;cat /tmp/discovery.txt | sort -u > /tmp/wayback.txt
                echo > /tmp/discovery.txt;echo -e "\033[38;2;220;20;60m${bold}>>> Discovery\033[m" >> /tmp/discovery.txt;echo >> /tmp/discovery.txt;echo -e "\033[38;2;0;255;255m~ "$c1"\033[m" >> /tmp/discovery.txt;echo -e "\033[38;2;0;255;255m~ echo "$target" | "$c2"\033[m" >> /tmp/discovery.txt;echo >> /tmp/discovery.txt
                cat /tmp/wayback.txt >> /tmp/discovery.txt;echo >> /tmp/discovery.txt
                cat /tmp/discovery.txt >> $target.txt;echo >> $target.txt;echo "===========================================================================" >> $target.txt;echo >> $target.txt
                clear
                cat /tmp/discovery.txt
                read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/wayback.txt /tmp/discovery.txt
                exec $0 $1
                ;;
            "TCP Ports Scan")
                clear;echo;echo -e "\033[38;2;0;255;0m>>> Scanning...\033[m";echo
                c1=('nmap -n -Pn -sSV -p- -T4 --open '$target'')
                $c1 > /tmp/tcp.txt
                echo > /tmp/tcpscan.txt;echo -e "\033[38;2;220;20;60m${bold}>>> TCP Ports Scan\033[m" >> /tmp/tcpscan.txt;echo >> /tmp/tcpscan.txt;echo -e "\033[38;2;0;255;255m~ "$c1"\033[m" >> /tmp/tcpscan.txt;echo >> /tmp/tcpscan.txt
                cat /tmp/tcp.txt | head -n -3 | tail -n +5  >> /tmp/tcpscan.txt;echo >> /tmp/tcpscan.txt
                cat /tmp/tcpscan.txt >> $target.txt;echo >> $target.txt;echo "===========================================================================" >> $target.txt;echo >> $target.txt
                clear
                cat /tmp/tcpscan.txt
                read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/tcp.txt /tmp/tcpscan.txt
                exec $0 $1
                ;;
            "UDP Ports Scan")
                clear;echo;echo -e "\033[38;2;0;255;0m>>> Scanning...\033[m";echo
                c1=('nmap -n -Pn -sUV -T4 --top-ports=20 --open '$target'')
                $c1 | grep -v "filtered" > /tmp/udp.txt
                echo > /tmp/udpscan.txt;echo -e "\033[38;2;220;20;60m${bold}>>> UDP Ports Scan\033[m" >> /tmp/udpscan.txt;echo >> /tmp/udpscan.txt;echo -e "\033[38;2;0;255;255m~ "$c1"\033[m" >> /tmp/udpscan.txt;echo >> /tmp/udpscan.txt
                cat /tmp/udp.txt | head -n -3 | tail -n +2 | egrep "/udp|Nmap|STATE" >> /tmp/udpscan.txt;echo >> /tmp/udpscan.txt
                cat /tmp/udpscan.txt >> $target.txt;echo >> $target.txt;echo "===========================================================================" >> $target.txt;echo >> $target.txt
                clear
                cat /tmp/udpscan.txt
                read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/udp.txt /tmp/udpscan.txt
                exec $0 $1
                ;;
            "Slowloris DoS Test")
                clear;echo
                read -p $'\033[38;2;220;20;60m-> Target\'s port: \033[m' p
                clear;echo;echo -e "\033[38;2;0;255;0m>>> Scanning...\033[m";echo
                c1=('perl slowloris.pl -dns '$target' -port '$p' -test')
                echo > /tmp/dos.txt;echo -e "\033[38;2;220;20;60m${bold}>>> Slowloris DoS Test\033[m" >> /tmp/dos.txt;echo >> /tmp/dos.txt;echo -e "\033[38;2;0;255;255m~ "$c1"\033[m" >> /tmp/dos.txt;echo >> /tmp/dos.txt
                $c1 > /tmp/sl.txt;cat /tmp/sl.txt | egrep "Trying|Worked|Failed|Uhm" >> /tmp/dos.txt;echo >> /tmp/dos.txt
                cat /tmp/dos.txt >> $target.txt;echo >> $target.txt;echo "===========================================================================" >> $target.txt;echo >> $target.txt
                clear
                cat /tmp/dos.txt
                read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/dos.txt /tmp/sl.txt
                exec $0 $1
                ;;
            "Quit")
                clear
                break
                ;;
            *) exec $0 $1;;
        esac
    done
fi
