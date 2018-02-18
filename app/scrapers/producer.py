import threading
import json
import requests

class Producer(threading.Thread):
	def __init__(self, queue, urlGenerator, urlsExtractor):
		super(Producer, self).__init__()
		self.queue = queue
		self.urlGenerator = urlGenerator
		self.urlsExtractor = urlsExtractor

	def request(self, url):
		return requests.get(url)

	def responseToJson(self, response):
		return json.loads(response.content)

	def run(self):
		while 1:
			url = self.urlGenerator.nextUrl()
			response = self.request(url)
			data = self.responseToJson(response)
			for u in self.urlsExtractor.getUrls(data):
				self.queue.put(u)
			if(not self.urlGenerator.hasNext(data)):
				break
		