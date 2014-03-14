__author__ = 'thomas'

import random
import string
from jsonschema import Draft3Validator
from jsonschema.exceptions import SchemaError, ValidationError, UnknownType


#Source: http://stackoverflow.com/questions/2257441/python-random-string-generation-with-upper-case-letters-and-digits
def randomLetters(length):
    return ''.join(random.choice(string.ascii_letters) for _ in range(length))


def verifySchema(schema, instance):
    try:
        validator = Draft3Validator(schema)
        validator.validate(instance)

    except ValidationError as e:
        print 'Data did not comply with jsonschema. Schema: "' + str(schema) + '"' + \
              ' Response: "' + str(instance) + '"'
        raise e

    except (SchemaError, UnknownType, TypeError) as e:
        print 'Error in the jsonschema. Schema: "' + str(schema) + '"'
        raise e