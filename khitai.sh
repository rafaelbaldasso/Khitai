#!/bin/bash

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
    echo;echo -e "\033[38;2;255;228;181m[>] Usage: $0 <domain>\033[m"
    echo -e "\033[38;2;255;228;181m[>] Example: $0 github.com\033[m";echo
    echo -e "\033[38;2;255;228;181m[!] Install dependencies by running the setup.sh as root!\033[m";echo
else
    target=$1
    bold=$(tput bold)
    echo;echo -e "\033[38;2;255;228;181m** Choose an option to begin the tests **\033[m";echo
    PS3=$'\n''-> '
    options=("Security Headers" "HTTP Headers & Methods" "SSL Scan" "Check WAF" "Domain Spoofing" "Zone Transfer" "Wordpress Tests" "TCP Port Scan" "Slowloris DoS Test" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Security Headers")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Security Headers (HTTP)\033[m";echo
                echo -e '\033[38;2;0;255;255mpython3 shcheck.py http://'$target'\033[m'
                python3 shcheck.py http://$target
                echo;echo "===========================================================================";echo;
                echo -e "\033[38;2;220;20;60m${bold}>>> Security Headers (HTTPS)\033[m";echo
                echo -e '\033[38;2;0;255;255mpython3 shcheck.py https://'$target'\033[m'
                python3 shcheck.py https://$target
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "HTTP Headers & Methods")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> HTTP Headers & Methods\033[m";echo
                echo -e '\033[38;2;0;255;255mcurl -I http://'$target' -L -k -X OPTIONS -s --connect-timeout 15\033[m';echo
                curl -I http://$target -L -k -X OPTIONS -s --connect-timeout 15
		echo;echo "===========================================================================";echo;
                echo -e '\033[38;2;0;255;255mcurl -I https://'$target' -L -k -X OPTIONS -s --connect-timeout 15\033[m';echo
                curl -I https://$target -L -k -X OPTIONS -s --connect-timeout 15
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "SSL Scan")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> SSL Scans\033[m";echo
                echo -e '\033[38;2;0;255;255msslscan '$target'\033[m';echo
                sslscan $target
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "Check WAF")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> WAF\033[m";echo
                echo -e '\033[38;2;0;255;255mwafw00f -o - http://'$target'\033[m';echo
                wafw00f -o - http://$target
                echo;echo "===========================================================================";echo
                echo -e '\033[38;2;0;255;255mwafw00f -o - https://'$target'\033[m';echo
                wafw00f -o - https://$target
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "Domain Spoofing")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Domain Spoofing\033[m";echo
		echo -e "\033[38;2;255;228;181m-> SPF: \033[m";echo
		echo -e '\033[38;2;0;255;255mhost -t txt '$target'\033[m';echo
		host -t txt $target
		echo;echo -e "\033[38;2;255;228;181m-> DMARC: \033[m";echo
		echo -e '\033[38;2;0;255;255mhost -t txt _dmarc.'$target'\033[m';echo
		host -t txt _dmarc.$target
		echo;read -p $'\033[38;2;255;228;181m-> DKIM Selector (optional for DKIM check): \033[m' selector
			if [[ ! -z $selector  ]]
			then
				echo;echo -e '\033[38;2;0;255;255mhost -t txt '$selector'._domainkey.'$target'\033[m';echo
				host -t txt $selector._domainkey.$target
			fi
		echo;read -p $'\033[38;2;255;228;181m-> Send spoofing test - if yes, type the recipient | if no, just press ENTER: \033[m' recipient
			if [[ ! -z $recipient  ]]
			then
				echo;echo -e '\033[38;2;0;255;255msendemail -f spoofed@'$target' -t '$recipient' -u "Spoofing Test" -m "Domain '$target' vulnerable to mail spoofing." -o tls=no\033[m'
				echo;sendemail -f spoofed@$target -t $recipient -u "Spoofing Test" -m "Domain $target vulnerable to mail spoofing." -o tls=no
				echo;echo -e "\033[38;2;255;228;181m-> Spoofing Mail Sent, check your inbox (if it goes to the spam folder, then it's not completely vulnerable).\033[m"
                	fi
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "Zone Transfer")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Zone Transfer\033[m";echo
                echo -e "\033[38;2;0;255;255mfor nserver in \$(host -t ns "$target" | cut -d ' ' -f4 | sed 's/.$//');do host -l -a "$target" \$nserver;done\033[m";echo
		for nserver in $(host -t ns $target | cut -d ' ' -f4 | sed 's/.$//');do host -l -a $target $nserver;done
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "Wordpress Tests")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Wordpress XML-RPC\033[m";echo
                echo -e "\033[38;2;0;255;255mcurl https://"$1"/xmlrpc.php -s --connect-timeout 15\033[m";echo
				curl https://$1/xmlrpc.php -s --connect-timeout 15 > /tmp/xmlrpc-test.html
				isInFile=$(cat /tmp/xmlrpc-test.html | grep -c "XML-RPC")
				if [ $isInFile -eq 0 ]; then
					echo "XML-RPC not vulnerable."
				else
   					echo "XML-RPC vulnerable!";echo
   					echo Response from the server: \"$(cat /tmp/xmlrpc-test.html)\";echo
   					echo "URL: https://"$1"/xmlrpc.php"
				fi
				rm -rf /tmp/xmlrpc-test.html
                echo;echo "===========================================================================";echo
                echo -e "\033[38;2;220;20;60m${bold}>>> Wordpress WP-Cron\033[m";echo           
				echo -e "\033[38;2;0;255;255mcurl -I https://"$1"/wp-cron.php -s --connect-timeout 15\033[m";echo
				if [ $(curl -LI https://$1/wp-cron.php --connect-timeout 15 -o /dev/null -w '%{http_code}\n' -s) == "200" ]; then
					echo "WP-Cron vulnerable!";echo
					curl -I https://$1/wp-cron.php -s --connect-timeout 15
					echo "URL: https://"$1"/wp-cron.php"
				else
					echo "WP-Cron not vulnerable.";fi
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "TCP Port Scan")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> TCP Port Scan\033[m";echo
                echo -e "\033[38;2;0;255;255mnmap -Pn -n -p- -T4 --open "$target"\033[m";echo
                nmap -Pn -n -p- -T4 --open $target
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "Slowloris DoS Test")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Slowloris DoS Test\033[m";echo
                read -p $'\033[38;2;255;228;181m-> Target port: \033[m' port
		echo;echo -e "\033[38;2;0;255;255mperl slowloris.pl -test -dns "$target" -port "$port"\033[m";echo
                perl slowloris.pl -test -dns $target -port $port
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
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
