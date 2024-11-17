## A pentesting hub for web recon and PoCs
### Meant to be used in Kali Linux with Python3

### # Installation:  
```
wget https://raw.githubusercontent.com/rafaelbaldasso/Khitai/main/khitai.py

or

git clone https://github.com/rafaelbaldasso/Khitai

------------------------------------------------------------------------------

python khitai.py -i
# Requires an elevated terminal (sudo su) or the sudo password (asked during the process)

> For the Postfix configuration, just keep advancing with the default configs.  
```

### # Usage:  
```
python khitai.py -h

   -h   This help menu
   -i   Install all the dependencies

   [!] Usage: python3 khitai.py <target>
   [>] e.g: python3 khitai.py https://site.com

------------------------------------------------------------------------------

python khitai.py https://site.com

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


>> Target: https://site.com

[0] Exit
[1] Security Headers        [4] SSL Tests       [7] Zone Transfer
[2] Clickjacking            [5] CORS            [8] Subdomain Enumeration
[3] HTTP Headers & Methods  [6] Email Spoofing  [9] Sitemap Scraping

[>] 
```
