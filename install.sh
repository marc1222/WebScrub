#!/bin/bash

if [ "$EUID" -ne 0  ]
      then echo "Please run as root"
            exit
fi

apt update && sudo apt upgrade -y && sudo apt install -y git python3 pip golang nmap npm jq xmlstarlet curl python3-dev nikto
apt install -y libcurl4-openssl-dev libssl-dev build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev wget
snapd systemctl enable snapd
systemctl start snapd
PATH=/snap/bin/:$PATH
snap install docker
GOPATH="/opt/go" GOBIN="/bin" go install github.com/hakluke/hakrawler@latest
pip install json2html xsstrike wfuzz httpx
npm install -g is-website-vulnerable
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap-dev
ln -s /opt/sqlmap-dev/sqlmap.py /bin/sqlmap
git clone https://github.com/Tuhinshubhra/CMSeeK /opt/cmseek
pip install -r /opt/cmseek/requirements.txt
ln -s /opt/cmseek/cmseek.py /bin/cmseek
git clone https://github.com/EnableSecurity/wafw00f /opt/wafwoof
cd /opt/wafwoof; python3 /opt/wafwoof/setup.py install
