from prodConsumQueue import ProdComsumQueue
from leafly_consumer import Consumer
from leafly_producer import Producer
import multiprocessing
import time
import Queue
import json
import sys
from menu_extractor import DispensaryInfoExtractor

def isValidItem(item):
	return item['State'] == (sys.argv[1] if len(sys.argv) > 1 else "")

def runScript():	
	queue = ProdComsumQueue(150)
	resultPool = []

	producer = Producer(queue, isValidItem)
	producer.start()
	
	while not queue.was_populated():
		time.sleep(1/4)
		pass

	threadsCount = multiprocessing.cpu_count()
	threads = []
	for i in range(threadsCount*15):
		t = Consumer(queue, resultPool, DispensaryInfoExtractor())
		t.start()
		threads.append(t)

	producer.join()
	for t in threads:
		t.join()

	return resultPool

def writeToFile(fileName, data):
	with open(fileName, 'w') as outfile:
		json.dump(data, outfile)


if __name__ == "__main__":
	data = runScript()
	print json.dumps(data)
