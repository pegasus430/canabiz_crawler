import threading
import json
import requests
import time

class Producer(threading.Thread):
	def __init__(self, queue, isValidItemCallBack):
		super(Producer, self).__init__()
		self.url = "https://www.leafly.com/finder/searchnext"
		self.queue = queue
		self.isValidItemCallBack = isValidItemCallBack

	def request(self, url):
		return requests.post(url,data={'Take':10000,'Page':0})

	def responseToJson(self, response):
		return json.loads(response.content)

	def getPartialDispensary(self, dispensaryData):
		result = {}
		result['url'] = "https://www.leafly.com/dispensary-info/" + dispensaryData['UrlName']
		result['rating'] = dispensaryData['Rating']
		result['reviews_count'] = dispensaryData['NumReviews']
		result['name'] = dispensaryData['Name']
		result['city'] = dispensaryData['City']
		result['phone_number'] = dispensaryData['Phone']
		result['hours_of_operation'] = dispensaryData['Schedule']
		result['state'] = dispensaryData['State']
		result['latitude'] = dispensaryData['Latitude']
		result['longitude'] = dispensaryData['Longitude']
		result['avatar_url'] = dispensaryData['CoverPhotoUrl']
		result['zip_code'] = dispensaryData['Zip']
		result['address'] = dispensaryData['Address1']
		return result


	def run(self):
		response = self.request(self.url)
		data = self.responseToJson(response)
		for item in data['Results']:
			if self.isValidItemCallBack(item):
				u = item['UrlName']
				self.queue.put(self.getPartialDispensary(item))
		