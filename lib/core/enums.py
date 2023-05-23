import os

class JSON_KEYS(object):
    HOST = "Host"
    TARGET = "Target"
    TOOL = "Tool"
    OUTPUT = "Output"
    RESULT = "Results"
    COMMAND = "Command"
    FUZZING = "Fuzzing"
    SCAN = "Web scan"
    DNS = "DNS"
    INJECTION = "Injection"
    STANDALONE = "Standalone Tools"
    SQLINJECTION = "SQLInjection"
    WAF = "WAF"
    SSL = "SSL"
    COOKIE = "Cookie"
    CSRF = "CSRF"
    SSRF = "SSRF"
    RETURN_CODE = "Return code"
    DNS = "DNS"

class ARG(object):
    WEB = "web"
    API = "api"
    LEVEL = "level"
    HOST = "host"

class ARG_DEFAULTS(object):
    LEVEL = 1
    TYPE = ARG.WEB

class ARG_HELP(object):
    HOST = "Target host for pentesting"
    LEVEL = "Level of tests to perform (1, 2 or 3, default %d)" % ARG_DEFAULTS.LEVEL
    WEB = "Target is a web application"
    API = "Target is an API"
    COOKIE = "HTTP Cookie header value, multiple cookies allowed (e.g. \"PHPSESSID=a8d127e..\")"
    AUTH = "Header authentication credentials (e.g. Basic XXX, Bearer XXX)"
    FOLDER = "Project folder where all the results will be exported"

class STEP(object):
    FUZZING = "\n------------ FUZZING ------------\n"
    SCANNING = "\n------------ SCANNING ------------\n"
    DNS = "\n------------ DNS ------------\n"
    INJECTION = "\n------------ XSS INJECTION ------------\n"
    SQLINJECTION = "\n------------ SQL INJECTION ------------\n"
    STANDALONE = "\n------------ STANDALONE TOOLS ------------\n"
    WAF = "\n------------ WAF ------------\n"
    SSL = "\n------------ SSL ------------\n"
    COOKIE = "\n------------ COOKIE ------------\n"
    CSRF = "\n------------ CSRF ------------\n"
    SSRF = "\n------------CSRF------------\n"
    VULNS = "\n------------ VULNERABILITIES ------------\n"

class SCRIPT(object):
    FUZZING = "fuzzing.sh"
    SCANNING = "scan.sh"
    DNS = "dns.sh"
    INJECTION = "xsstrike.sh"
    SQLINJECTION = "sqlmap.sh"
    STANDALONE = "standalone.sh"
    WAF = "waf.sh"
    SSL = "ssl.sh"
    COOKIE = "cookies.sh"
    CSRF = "csrf.sh"
    SSRF = "ssrf.sh"
    VULNS = "vulns.sh"
    TEST = "test.sh"

class SCRIPT_OUT(object):
    FUZZING = "fuzzing"
    SCANNING = "scan"
    DNS = "dns"
    INJECTION = "injection"
    SQLINJECTION = "sqlinjection"
    STANDALONE = "standalone"
    WAF = "waf"
    SSL = "ssl"
    COOKIE = "cookies"
    CSRF = "csrf"
    SSRF = "ssrf"
    VULNS = "vulns"
    TEST = "test"

class SCRIPT_RESULTS(object):
    FUZZING = os.path.join('output', 'fuzzing-results.txt')
    SCANNING = os.path.join('output', 'urls.txt')
    INJECTION = os.path.join('output','xsstrike' , 'xsstrikeVulns.txt')
    SQLINJECTION = os.path.join('output', 'sqlmap', 'sqlmapout.out')
    STANDALONE_NIKTO = os.path.join('output', 'nikto-results.txt')
    STANDALONE_HTTPX = os.path.join('output', 'httpx.json')

class BCOLORS(object):
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'
