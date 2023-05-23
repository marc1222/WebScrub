import json
import sys
import os

from lib.core.enums import JSON_KEYS

from lib.core.settings import JSON_EXPORT_FILE
from lib.core.settings import VERSION_STRING

class ToolParser():
    """ Class that serves to parse all the output of the tool's execution

    Attributes:
        host -- target host
    """ 

    def __init__(self, host):
        self.host = host

        self.json_output = {}
        self.json_output[JSON_KEYS.TARGET] = host
        self.json_output[JSON_KEYS.TOOL] = VERSION_STRING

    def parse_output(self, command, result, return_code, step, result_files=None, save_as_vector=False):
        """ Generic function that parses output into a json
        """ 

        step_result ={}

        step_result[JSON_KEYS.COMMAND] = command
        step_result[JSON_KEYS.RETURN_CODE] = return_code
        step_result[JSON_KEYS.OUTPUT] = result

        if result_files: 
          #  result_files_json = {} 
          #  for result_file in result_files:
           #     if not os.path.exists(result_file): break
           #     with open(result_file) as file:
              #      if save_as_vector: lines = file.readlines()
               #     else: lines = file.read()
               # result_files_json[result_file] = lines

            step_result[JSON_KEYS.RESULT] = result_files
        
        self.json_output[step] = step_result

    def parse_fuzzing(self, process, results=[]):
        self.parse_output(process.command, ''.join(process.output), process.return_code, JSON_KEYS.FUZZING, result_files=results),
        
    def parse_scanning(self, process, results=[]):
        self.parse_output(process.command, ''.join(process.output), process.return_code, JSON_KEYS.SCAN, result_files=results, save_as_vector=True)
    
    def parse_injection(self, process, results=[]):
        self.parse_output(process.command, ''.join(process.output), process.return_code, JSON_KEYS.INJECTION, result_files=results)

    def parse_sqlinjection(self, process, results=[]):
        self.parse_output(process.command, ''.join(process.output), process.return_code, JSON_KEYS.SQLINJECTION, result_files=results)

    def parse_standalone(self, process, results=[]):
        self.parse_output(process.command, ''.join(process.output), process.return_code, JSON_KEYS.STANDALONE, result_files=results)

    def export_json(self, path):
        """ Function that exports the resulting json of all the parsed steps
        """ 
        json_export = json.dumps(self.json_output, indent=4)
        export_file = os.path.join(path, JSON_EXPORT_FILE)

        with open(export_file, 'w') as outfile:
            json.dump(self.json_output, outfile, indent=4)

        return json_export
