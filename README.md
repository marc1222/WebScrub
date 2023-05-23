<pre style="color:aqua">
| |     / /___   / /_  / ___/ _____ _____ __  __ / /_ 
| | /| / // _ \ / __ \ \__ \ / ___// ___// / / // __ \
| |/ |/ //  __// /_/ /___/ // /__ / /   / /_/ // /_/ /
|__/|__/ \___//_.___//____/ \___//_/    \__,_//_.___/ 
</pre>

[![Python 3.x](https://img.shields.io/badge/python-3.x-yellow.svg)](https://www.python.org/) [![License](https://img.shields.io/badge/license-GPLv3-red.svg)](https://git.isrc.ccep.com/Tools/PentestAutomation2.0/src/branch/master/LICENSE)

WebScrub is a python script that consists of the execution of various pentesting tools (sqlmap, wfuzz, nikto, etc.) over various phases (fuzzing, scanning, xss/sql injection and standalone tools)

Installation
----

You can download WebScrub by cloning the [Git](https://git.isrc.ccep.com/Tools/PentestAutomation2.0) repository:

    git -c http.sslVerify=false clone https://git.isrc.ccep.com/Tools/PentestAutomation2.0.git 

WebScrub works out of the box with [Python](https://www.python.org/download/) version **3.x** on any Linux distro.

How To
----

``` 
python WebScrub.py [-h] [-l LEVEL] [-a AUTH] [-c COOKIE] host  
``` 

To get a list of basic options and switches use:

    python WebScrub.py -h

```
positional arguments:
  host                  Target host for pentesting

options:
  -h, --help            show this help message and exit
  -l LEVEL, --level LEVEL
                        Level of tests to perform (1, 2 or 3, default 1)
  -a AUTH, --auth AUTH  
                        Header authentication credentials (e.g. Basic XXX, Bearer XXX)
  -c COOKIE, --cookie COOKIE
                        HTTP Cookie header value (e.g. "PHPSESSID=a8d127e..")
  -f FOLDER, --folder FOLDER
                        Project folder where all the results will be exported
```

Internal Tools
---- 

For this tool to function, it must be used inside a Linux system with bash scripting support 

| Requirement | Installation                                             | Dependency         |  
| --------    | --------                                                 | --------           | 
| Docker      | https://docs.docker.com/desktop/install/linux-install/   | :heavy_check_mark: | 
| Python3     | https://docs.python-guide.org/starting/install3/linux/   | :heavy_check_mark: | 
| Go          | https://go.dev/doc/install                               | :heavy_check_mark: | 
| wfuzz       | https://github.com/xmendez/wfuzz                         | :heavy_check_mark: | 
| hakrawler   | https://github.com/hakluke/hakrawler                     | :heavy_check_mark: | 
| xmlstarlet  | https://pypi.org/project/xmlstarlet/                     | :heavy_check_mark: | 
| jq          | https://stedolan.github.io/jq/                           | :heavy_check_mark: | 
| xxstrike    | https://github.com/s0md3v/XSStrike                       | :heavy_check_mark: | 
| sqlmap      | https://github.com/sqlmapproject/sqlmap                  | :heavy_check_mark: | 
| nikto       | https://github.com/sullo/nikto                           | :heavy_check_mark: | 
| cmseek      | https://github.com/Tuhinshubhra/CMSeeK                   | :heavy_check_mark: | 
| xsrfprobe   | https://github.com/0xInfection/XSRFProbe                 | :heavy_check_mark: | 
| jsvulns     | https://github.com/0xInfection/XSRFProbe                 |                    | 


> Note: in order to use docker, you need to have the correct permissions 

