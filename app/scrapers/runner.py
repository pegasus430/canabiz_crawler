from multiprocessing.pool import ThreadPool, cpu_count

def run(states, produce, consume):
    try:
        result = {}
        for state in states:
            pool = ThreadPool(40)
            result[state] = pool.map(consume, produce(state))
        return result
    except Exception as e:
        return "Error({0}): {1}".format(e.message, e.strerror)
