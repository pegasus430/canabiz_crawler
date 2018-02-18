import threading
import requests
import json

class Consumer(threading.Thread):
	def __init__(self, queue, resultPool, urlReconstructor, itemExtractor):
		super(Consumer, self).__init__()
		self.queue = queue
		self.resultPool = resultPool
		self.urlReconstructor = urlReconstructor
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
			url = self.urlReconstructor.reconstruct(self.queue.get())
			data = self.getData(url)
			self.resultPool.append(self.itemExtractor.extract(data))