from multiprocessing.pool import ThreadPool, cpu_count

def run(states, produce, consume):
    result = {}
    for state in states:
        pool = ThreadPool(100)
        result[state] = [ r for r in pool.map(consume, produce(state)) if r]
        return result

