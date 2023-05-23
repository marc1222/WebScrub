FROM alpine
RUN apk add git python3 py3-pip go nmap nmap-scripts npm jq xmlstarlet curl-dev python3-dev libressl-dev nikto bash; exit 0
RUN GOPATH="/opt/go" GOBIN="/bin" go install github.com/hakluke/hakrawler@latest
RUN pip install json2html xsstrike wfuzz httpx
RUN npm install -g is-website-vulnerable
RUN git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git /opt/sqlmap-dev
RUN ln -s /opt/sqlmap-dev/sqlmap.py /bin/sqlmap
RUN git clone https://github.com/Tuhinshubhra/CMSeeK /opt/cmseek
RUN pip install -r /opt/cmseek/requirements.txt
RUN ln -s /opt/cmseek/cmseek.py /bin/cmseek
RUN git clone https://github.com/EnableSecurity/wafw00f /opt/wafwoof
RUN cd /opt/wafwoof; python /opt/wafwoof/setup.py install
RUN mkdir /opt/PentestAuto
COPY . /opt/PentestAuto
