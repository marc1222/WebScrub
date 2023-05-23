class ToolResult():
    """ Class that serves as a container for attributeas that may or may not be returned by a tool execution

    Attributes:
        command -- command to execute the tool
        output -- Output from the tool

    """ 

    def __init__(self, command, return_code, output):
        self.command = command
        self.output = output
        self.return_code = return_code

        self.results_txt = [] 