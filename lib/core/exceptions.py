class UndefinedEnum(Exception):
    """Exception raised for undefined enum option.
    
    Attributes:
        message -- explanation of the error
    """

    def __init__(self, option, message=None):
        self.option = option
        if not message: self.message="Enumeration option %s is not defined as valid" % (option)
        else: self.message = message
        super().__init__(self.message)

class NotURL(Exception):
    """Exception raised for when a URl is not identified
    
    Attributes:
        message -- explanation of the error
    """

    def __init__(self, string, message=None):
        self.url = string
        if not message: self.message="String %s is not a URL" % (string)
        else: self.message = message
        super().__init__(self.message)