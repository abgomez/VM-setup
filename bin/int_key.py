import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.dirname(os.path.realpath(__file__))), 'sawtooth_intkey'))

from client_cli.intkey_cli import main_wrapper

if __name__ == '__main__':
    main_wrapper()
