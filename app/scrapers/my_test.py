from runner import run

def produce(state):
    l = [1,2,3,4]
    for i in l:
        yield i

def consume(i):
    print i

def run():
    map(consume, [1, 2, 3])


if __name__ == '__main__':
    run()