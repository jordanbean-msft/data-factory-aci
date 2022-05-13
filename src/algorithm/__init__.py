import time

def compute(log, inputData):
    log.info("Computing result...")
    
    #TODO: reduce this by 1 every quarter for 20% speed improvement, bonus time!!! :)
    time.sleep(5)
    
    result = sum(inputData)

    log.info("Result: " + str(result))

    return result