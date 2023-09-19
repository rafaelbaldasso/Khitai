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

if [ "$EUID" -ne 0 ]
    then
        echo;echo "[!] You must run the tool as root!";echo
        exit
fi

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
    options=("Security Headers" "HTTP Headers & Methods" "SSL Scan" "Check WAF" "Clickjacking" "Domain Spoofing" "Zone Transfer" "Wordpress Tests" "Subdomains" "Discovery" "TCP Port Scan" "Slowloris DoS Test" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Security Headers")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Security Headers\033[m";echo
                proto=$(~/go/bin/httpx -silent -u $target | cut -d ':' -f1)
                echo -e '\033[38;2;0;255;255mpython3 shcheck.py '$proto'://'$target'\033[m'
                python3 shcheck.py $proto://$target
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "HTTP Headers & Methods")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> HTTP Headers & Methods\033[m";echo
                proto=$(~/go/bin/httpx -silent -u $target | cut -d ':' -f1)
                echo -e '\033[38;2;0;255;255mcurl -I '$proto'://'$target' -L -k -X OPTIONS -s --connect-timeout 15\033[m';echo
                curl -I $proto://$target -L -k -X OPTIONS -s --connect-timeout 15
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
                proto=$(~/go/bin/httpx -silent -u $target | cut -d ':' -f1)
                echo -e '\033[38;2;0;255;255mwafw00f -o - '$proto'://'$target'\033[m';echo
                wafw00f -o - $proto://$target
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "Clickjacking")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Clickjacking\033[m";echo
                proto=$(~/go/bin/httpx -silent -u $target | cut -d ':' -f1)
                echo -e '\033[38;2;0;255;255mpython3 shcheck.py '$proto'://'$target' -d | egrep "X-Frame-Options|Content-Security-Policy"\033[m';echo
                python3 shcheck.py $proto://$target -d | egrep "X-Frame-Options|Content-Security-Policy";echo
                echo '<html><head><title>Clickjacking Test</title></head><body><h1>Clickjacking Test</h1><p><b>'$proto'://'$target'</b></p><iframe src="'$proto'://'$target'" width="800" height="500" margin-top="100" scrolling="yes" style="opacity:0.5"></iframe></body></html>' > /tmp/cj-test.html
                echo "Clickjacking Test HTML file (CTRL + CLICK to open):"
                echo "file:///tmp/cj-test.html"
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/cj-test.html
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
                proto=$(~/go/bin/httpx -silent -u $target | cut -d ':' -f1)
                echo -e "\033[38;2;0;255;255mcurl "$proto"://"$target"/xmlrpc.php -s --connect-timeout 15\033[m";echo
                curl $proto://$target/xmlrpc.php -s --connect-timeout 15 > /tmp/xmlrpc-test.html
                isInFile=$(cat /tmp/xmlrpc-test.html | grep -c "XML-RPC")
                if [ $isInFile -eq 0 ]
		        then
                	echo "XML-RPC not vulnerable."
                else
                	echo "XML-RPC vulnerable!";echo
                	echo Response from the server: \"$(cat /tmp/xmlrpc-test.html)\";echo
                	echo "URL: "$proto"://"$target"/xmlrpc.php"
                fi
                rm -rf /tmp/xmlrpc-test.html
                echo;echo "===========================================================================";echo
                echo -e "\033[38;2;220;20;60m${bold}>>> Wordpress WP-Cron\033[m";echo           
                echo -e "\033[38;2;0;255;255mcurl -I "$proto"://"$target"/wp-cron.php -s --connect-timeout 15\033[m";echo
                if [ $(curl -LI $proto://$target/wp-cron.php --connect-timeout 15 -o /dev/null -w '%{http_code}\n' -s) == "200" ]
		        then
                	echo "WP-Cron vulnerable!";echo
                	curl -I $proto://$target/wp-cron.php -s --connect-timeout 15
                	echo "URL: "$proto"://"$target"/wp-cron.php"
                else
                	echo "WP-Cron not vulnerable.";fi
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "Subdomains")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Subdomains\033[m";echo                
                subfinder -silent -d $target >> subs.txt
                query="SELECT ci.NAME_VALUE NAME_VALUE FROM certificate_identity ci WHERE ci.NAME_TYPE = 'dNSName' AND reverse(lower(ci.NAME_VALUE)) LIKE reverse(lower('%.$target'));"
                (echo $target; echo $query | \
                psql -t -h crt.sh -p 5432 -U guest certwatch | \
                sed -e 's:^ *::g' -e 's:^*\.::g' -e '/^$/d' | \
                sed -e 's:*.::g';) | sort -u >> subs.txt
                ~/go/bin/httpx -silent -probe -list subs.txt | grep SUCCESS
                rm subs.txt          
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                exec $0 $1
                ;;
            "Discovery")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Discovery - Directories and Files (dirb)\033[m"
                proto=$(~/go/bin/httpx -silent -u $target | cut -d ':' -f1)
                wordlist="/usr/share/wordlists/dirb/common.txt"
                delay=200
                echo;echo -e "\033[38;2;0;255;255mCurrent target: "$proto"://"$target"/\033[m"
                echo -e "\033[38;2;0;255;255mChange the discovery options below or press ENTER to ignore.\033[m"
                echo;read -p $'\033[38;2;255;228;181m-> Change default target directory (i.e: /new/directory): \033[m' tgtdir
                if [[ ! -z $tgtdir  ]]
                then
                	target=$target$tgtdir
                fi
                echo;read -p $'\033[38;2;255;228;181m-> File extensions - disables the scan for directories (i.e: .txt,.cfg): \033[m' extens
                if [[ ! -z $extens  ]]
                then
                	ext="-X "$extens
                fi
                echo;read -p $'\033[38;2;255;228;181m-> Delay (ms) - default 200: \033[m' newdelay
                if [[ ! -z $newdelay  ]]
                then
                	delay=$newdelay
                fi
                echo;read -p $'\033[38;2;255;228;181m-> Custom wordlist - default /usr/share/wordlists/dirb/common.txt: \033[m' wlist
                if [[ ! -z $wlist  ]]
                then
                	wordlist=$wlist
                fi
                echo;read -p $'\033[38;2;255;228;181m-> Recursive - default enabled (d to disable): \033[m' recve
                if [[ $recve == "d" ]] || [[ $recve == "D"  ]]
                then
                	recursive="-r"
                fi
                echo;echo -e "\033[38;2;0;255;255mdirb "$proto"://"$target" "$wordlist" -w "$recursive" -z "$delay" "$ext"\033[m"
                dirb $proto://$target $wordlist -w $recursive -z $delay $ext	
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
