import threading
import requests
import json

class Consumer(threading.Thread):
	def __init__(self, queue, resultPool, itemExtractor):
		super(Consumer, self).__init__()
		self.queue = queue
		self.resultPool = resultPool
		self.itemExtractor = itemExtractor

	def request(self, url):
		return requests.get(url)

	def responseToJson(self, response):
		return json.loads(response.content)

	def getData(self, url):
		response = self.request(url)
		return self.responseToJson(response)

	def run(self):
		while not self.queue.empty():
			item = self.queue.get()
			item['info'] = self.itemExtractor.getInfo(item['url'])
			self.resultPool.append(item)
