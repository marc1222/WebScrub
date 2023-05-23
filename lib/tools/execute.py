import subprocess
import sys
import os

from urllib.parse import urlparse

from lib.core.enums import ARG
from lib.core.enums import STEP
from lib.core.enums import SCRIPT
from lib.core.enums import SCRIPT_OUT
from lib.core.enums import SCRIPT_RESULTS
from lib.core.enums import BCOLORS

from lib.core.settings import CMD_SHELL
from lib.core.settings import CMD_TREE
from lib.core.settings import SCRIPTS_DIR
from lib.core.settings import SCRIPTS_OUTPUT_DIR
from lib.core.settings import TARGET_FILE
from lib.core.settings import BANNER
from lib.core.settings import COMPLETED_EXECUTION

from lib.core.exceptions import UndefinedEnum
from lib.parse.toolparser import ToolParser
from lib.tools.toolresult import ToolResult

from lib.tools.exportreport import export_json_to_html

# To mix stdout and stderr into a single string
# result = subprocess.run(['ls', '-l'], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
# print(result.stdout)

def execute_tools(args):
    """ Function executing different tools depending on the selected options 
    """ 
    results_parser=ToolParser(args.host)
    target_file = os.path.join(args.folder, TARGET_FILE)

    with open(target_file, 'w') as outfile:
        outfile.write(args.host)

    if args.cookie: auth_cookie = f"{args.cookie}"
    else: auth_cookie = " "
    if args.auth: auth_bearer = f"{args.auth}"
    else: auth_bearer = " " 
    results = [] 

    print(f"\n{BCOLORS.OKBLUE}{BANNER}{BCOLORS.ENDC}")
    scanning_process = execute_scanning(args.host, workdir = args.folder, level=args.level, cookie=auth_cookie, auth=auth_bearer)
    uri_file = os.path.join(args.folder, SCRIPT_RESULTS.SCANNING)

    if not os.path.exists(uri_file): uri_file = target_file
    results_parser.parse_scanning(scanning_process, results=[uri_file])
    results.append(uri_file)

    fuzzing_process = execute_fuzzing(args.host, uri_file, workdir = args.folder, level=args.level, cookie=auth_cookie, auth=auth_bearer)
    fuzzing_results = os.path.join(args.folder, SCRIPT_RESULTS.FUZZING)
    results_parser.parse_fuzzing(fuzzing_process, results=[fuzzing_results])
    results.append(fuzzing_results)

    injection_process = execute_injection(args.host, workdir = args.folder, level=args.level, cookie=auth_cookie, auth=auth_bearer)
    injection_results = os.path.join(args.folder, SCRIPT_RESULTS.INJECTION)
    results_parser.parse_injection(injection_process, results=[injection_results])
    results.append(injection_results)

    sqlinjection_process = execute_sqlinjection(args.host, workdir = args.folder, level=args.level, cookie=auth_cookie, auth=auth_bearer)
    sqlinjection_results = os.path.join(args.folder, SCRIPT_RESULTS.SQLINJECTION)
    results_parser.parse_sqlinjection(sqlinjection_process, results=[sqlinjection_results])
    results.append(sqlinjection_results)

    standalone_process = execute_standalone(args.host, workdir = args.folder, level=args.level, cookie=auth_cookie, auth=auth_bearer)
    standalone_results = [os.path.join(args.folder, SCRIPT_RESULTS.STANDALONE_NIKTO), os.path.join(args.folder, SCRIPT_RESULTS.STANDALONE_HTTPX)]
    results_parser.parse_standalone(standalone_process, results=standalone_results)
    results= results + standalone_results

    json = results_parser.export_json(args.folder)
    export_json_to_html(json, args.folder)

    print(f"{BCOLORS.OKBLUE}{COMPLETED_EXECUTION}{BCOLORS.ENDC}")

    tree_cmd = [CMD_TREE, "--dirsfirst", os.path.join(args.folder, SCRIPTS_OUTPUT_DIR)] 
    subprocess.run(tree_cmd)

    return None

def execute_script(command, show_output=True):
    """ Generic Function that executes a bash scripts , outputs it to stdout and saves that output
    """ 
    process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    output = ''

    while(True):
        # returns None while subprocess is running
        retcode = process.poll() 
        #  read line until /n and strip newly added /n  
        line = process.stdout.readline()
        line = line.rstrip()
        

        if show_output: print(line.decode(sys.stdout.encoding))
        output = output + line.decode(sys.stdout.encoding) + ' \n'
        
        if retcode is not None: break
    
    script_result = ToolResult(process.args, process.returncode, output)
    
    return script_result

def execute_fuzzing(host, target_file, workdir='.', level=1, type=ARG.WEB, auth='', cookie='', show_output=True):
    """ Function that executes the fuzzing step
    """ 
    print(f"{BCOLORS.OKBLUE}{STEP.FUZZING}{BCOLORS.ENDC}")

    command = [CMD_SHELL, os.path.join(SCRIPTS_DIR, SCRIPT.FUZZING), target_file, str(level), workdir] 
    if cookie: command.append(f"{cookie}")
    if auth: command.append(f"{auth}")

    return execute_script(command)

def execute_scanning(url, workdir='.', level=1, type=ARG.WEB, auth='', cookie=None, show_output=True):
    """ Function that executes the web vulnerabilities scanning step
    """ 
    print(f"{BCOLORS.OKBLUE}{STEP.SCANNING}{BCOLORS.ENDC}")

    host = urlparse(url).hostname 

    command = [CMD_SHELL, os.path.join(SCRIPTS_DIR, SCRIPT.SCANNING), host, str(level), workdir + '/'] 
    if cookie: command.append(f"{cookie}")
    if auth: command.append(f"{auth}")

    return execute_script(command)

def execute_injection(host, workdir='.', level=1, type=ARG.WEB, auth='', cookie='', show_output=True):
    """ Function that executes the injection step
    """ 
    print(f"{BCOLORS.OKBLUE}{STEP.INJECTION}{BCOLORS.ENDC}")

    command = [CMD_SHELL, os.path.join(SCRIPTS_DIR, SCRIPT.INJECTION), host, str(level), workdir] 
    if cookie: command.append(f"{cookie}")
    if auth: command.append(f"{auth}")

    return execute_script(command)

def execute_standalone(host, workdir='.', level=1, type=ARG.WEB, auth='', cookie='', show_output=True):
    """ Function that executes the standalone tools step
    """ 
    print(f"{BCOLORS.OKBLUE}{STEP.STANDALONE}{BCOLORS.ENDC}")

    command = [CMD_SHELL, os.path.join(SCRIPTS_DIR, SCRIPT.STANDALONE), host, str(level), workdir] 
    if cookie: command.append(f"{cookie}")
    if auth: command.append(f"{auth}")

    return execute_script(command)

def execute_sqlinjection(host, workdir='.', level=1, type=ARG.WEB, auth='', cookie='', show_output=True):
    """ Function that executes the sql injection step
    """ 
    print(f"{BCOLORS.OKBLUE}{STEP.SQLINJECTION}{BCOLORS.ENDC}")

    command = [CMD_SHELL, os.path.join(SCRIPTS_DIR, SCRIPT.SQLINJECTION), host, str(level), workdir] 
    if cookie: command.append(f"{cookie}")
    if auth: command.append(f"{auth}")

    return execute_script(command)


