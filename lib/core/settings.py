
# version (<major>.<minor>.<month>.<monthly commit>)
VERSION = "1.0"
VERSION_STRING = "WebScrub/%s" % ('.'.join(VERSION.split('.')[:-1]))
DESCRIPTION = "Execute a number of tests on target host"
BANNER = """ _       __       __    _____                     __  
| |     / /___   / /_  / ___/ _____ _____ __  __ / /_ 
| | /| / // _ \ / __ \ \__ \ / ___// ___// / / // __ \\
| |/ |/ //  __// /_/ /___/ // /__ / /   / /_/ // /_/ /
|__/|__/ \___//_.___//____/ \___//_/    \__,_//_.___/ 
                                                      """
TYPE_COLORS = 90
COMPLETED_EXECUTION = "Web has been Scrubed! Here you can find the results:\n"

CMD_SHELL = "bash"
CMD_TREE = "tree"

SCRIPTS_DIR = "./scripts"
CMD_FUZZ_SCRIPT = "./scripts/test.sh"
DEFAULT_EXPORT_DIR = "./results/{project}"
SCRIPTS_OUTPUT_DIR = "output"

JSON_EXPORT_FILE = "results.json"
HTML_EXPORT_FILE = "results.html"
TARGET_FILE = "targets.txt"
