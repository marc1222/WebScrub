import sys
import argparse
import os

from urllib.parse import urlparse

from lib.core.settings import DESCRIPTION
from lib.core.settings import DEFAULT_EXPORT_DIR

from lib.core.enums import ARG
from lib.core.enums import ARG_HELP
from lib.core.enums import ARG_DEFAULTS

def cmd_line_parser(argv=None):
    """ Function That parses the command line options
    """ 
    if not argv:
        argv = sys.argv

    parser = argparse.ArgumentParser(description=DESCRIPTION)

    parser.add_argument(ARG.HOST, help=ARG_HELP.HOST)

    # mutually exclusive argument to determine if the host is a web or API. Default is web
    # type_group = parser.add_mutually_exclusive_group()
    # type_group.add_argument("-w", "--web", action="store_const", help=ARG_HELP.WEB, dest="type", const=ARG.WEB)
    # type_group.add_argument("-a", "--api", action="store_const", help=ARG_HELP.API, dest="type", const=ARG.API)
    # parser.set_defaults(type=ARG.WEB)
    
    parser.add_argument("-l", "--level", type=int, default=ARG_DEFAULTS.LEVEL, help=ARG_HELP.LEVEL)
    parser.add_argument("-a", "--auth", type=str, default=None, help=ARG_HELP.AUTH)
    parser.add_argument("-c", "--cookie", type=str, default=None, help=ARG_HELP.COOKIE)
    parser.add_argument("-f", "--folder", type=str, default=None, help=ARG_HELP.FOLDER)
    '''
    args, remaining = parser.parse_known_args()

    default_folder = '{uri.netloc}'.format(uri=urlparse(args.host))
    parser.add_argument("-f", "--folder", type=str, default=default_folder, help=ARG_HELP.FOLDER)
    '''
    args = parser.parse_args()

    return args