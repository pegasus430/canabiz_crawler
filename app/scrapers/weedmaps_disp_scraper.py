import Queue
from consumer import Consumer
from producer import Producer
import sys
import multiprocessing
import time
import json
from lxml import html
import requests
import re


class WeedMapsUrlReconstructor:

	def reconstruct(self, urlPart):
		return "https://weedmaps.com/api/web/v1/listings/" + urlPart + "/menu?type=dispensary"


class WeedMapsDespensaryExtractor:
	def __init__(self, detailsExtractor):
		self.detailsExtractor = detailsExtractor

	def get_menu(self, menuData):
		menu = []
		for c in menuData:
			category = {}
			category["title"] = c["title"]
			items = []
			for i in c["items"]:
				items.append({"name": i["name"], "grams_per_eighth": i["grams_per_eighth"], "prices": i[
							 "prices"], "image_url": i["image_url"], "url": "https://weedmaps.com/dispensaries/" + i["url"]})
			category["items"] = items
			menu.append(category)
		return menu

	def extract(self, data):
		result = {}
		listing = data["listing"]
		result["url"] = listing["url"]
		result["email"] = listing["email"]
		result["phone_number"] = listing["phone_number"]
		result["name"] = listing["name"]
		result["avatar_url"] = listing["avatar_url"]
		result["reviews_count"] = listing["reviews_count"]
		result["rating"] = listing["rating"]
		result["address"] = listing["address"]
		result["city"] = listing["city"]
		result["region"] = listing["region"]
		result["state"] = listing["state"]
		result["zip_code"] = listing["zip_code"]
		result["latitude"] = listing["latitude"]
		result["longitude"] = listing["longitude"]
		result["hours_of_operation"] = listing["hours_of_operation"]
		result["menu"] = self.get_menu(data["categories"])
		result["details"] = self.detailsExtractor.getDetails(listing["url"])
		return result


class WeedMapsUrlGenerator:

	def __init__(self, stateName):
		self.currentIndex = 0
		self.url = "https://api-v2.weedmaps.com/api/v2/listings?filter%5Bplural_types%5D%5B%5D=dispensaries&filter%5Bregion_slug%5Bdispensaries%5D%5D=" + \
			stateName.replace(' ', '-') + "&page_size=150&page="

	def nextUrl(self):
		self.currentIndex = self.currentIndex + 1
		return self.url + str(self.currentIndex)

	def hasNext(self, data):
		return len(data["data"]["listings"]) != 0


class WeedMapsUrlsExtractor:

	def getUrls(self, data):
		for l in data["data"]["listings"]:
			yield l["slug"]


class WeedMapsDetailsExtractor:

	def getAge(self, htmlDocument):
		textList = htmlDocument.xpath("//div[@class='tag-icon']//div[contains(@class, 'icon_age')]/@class")
		if len(textList) == 0:
			return "not specified"
		return re.findall(r'\d+', textList[0])[0] + '+'

	def getDetails(self, url):
		response = requests.get(url)
		home = html.fromstring(response.content)
		divDetails = home.xpath(
			"//div[@class='details-card-items social-links']/div[@class='details-card-item']")
		result = {}
		for div in divDetails:
			namelist = div.xpath("./div[contains(@class,'label')]/text()")
			if len(namelist) == 0:
				continue
			urllist = div.xpath("./div[contains(@class,'item-data')]/a/@href")
			if len(urllist) == 0:
				continue
			result[namelist[0].lower()] = urllist[0]
		result["age"] = self.getAge(home)

		return result

def writeToFile(fileName, data):
	with open(fileName, 'w') as outfile:
		json.dump(data, outfile)


def runScript():
	for state in sys.argv[1:]:
		queue = Queue.Queue(150)
		resultPool = []
		urlGenerator = WeedMapsUrlGenerator(state.lower())
		urlsExtractor = WeedMapsUrlsExtractor()

		producer = Producer(queue, urlGenerator, urlsExtractor)

		urlReconstructor = WeedMapsUrlReconstructor()
		dispensaryExtractor = WeedMapsDespensaryExtractor(WeedMapsDetailsExtractor())

		producer.start()
		time.sleep(4)

		threadsCount = multiprocessing.cpu_count()
		threads = []
		for i in range(threadsCount * 5):
			t = Consumer(queue, resultPool, urlReconstructor,
						 dispensaryExtractor)
			t.start()
			threads.append(t)

		producer.join()
		for t in threads:
			t.join()
		return resultPool

if __name__ == "__main__":
	try:
		result = runScript()
		print json.dumps(result)
	except Exception, e:
		print e
