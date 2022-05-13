import os, logging, json, time

import algorithm
logging.basicConfig(level = logging.INFO)

def main():
    log = logging.getLogger(__name__)

    connection_string = os.getenv('AZURE_STORAGE_CONNECTION_STRING')

    log.info('Calling algorithm...')

    # -- your algorithm goes here --
    result = algorithm.compute(log, [1,1])

    log.info('Algorithm finished. Result is %s', result)

if __name__=="__main__":
    main()