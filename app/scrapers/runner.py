from multiprocessing import Pool, cpu_count

def run(states, produce, consume):
    cpuCount = cpu_count()
    result = {}
    for state in states:
        pool = Pool(cpuCount*15)
        result[state] = list(pool.map(consume, produce(state)))
    return result