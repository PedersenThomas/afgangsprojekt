__author__ = 'thomas'

import random
import string

#Source: http://stackoverflow.com/questions/2257441/python-random-string-generation-with-upper-case-letters-and-digits
def randomLetters(length):
    return ''.join(random.choice(string.ascii_letters) for _ in range(length))
