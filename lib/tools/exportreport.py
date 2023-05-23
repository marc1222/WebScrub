from json2html import *
import os

from lib.core.settings import HTML_EXPORT_FILE

def export_json_to_html(json, path):
    """ Function That exports the resulting json to an html report
    """ 
    report = json2html.convert(json=json)
    export_file = os.path.join(path, HTML_EXPORT_FILE)

    with open(export_file, 'w') as outfile:
        outfile.write(report)

    return report
