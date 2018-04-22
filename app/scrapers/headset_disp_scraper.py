from lxml import html
from utils import HtmlUtils
from httpclient import HttpClient
import json
from disp_filter import get_dispensary_filter
from runner import run
import sys
from headset_helpers import HeadsetCategoryExtractor

class HeadsetDispensaryScraper(object):
    def __init__(self, http_client, headset_category_extractor):
        self._http_client = http_client
        self._url = 'https://www.headset.io/the-best-selling-cannabis-products/{0}-flower'
        self._category_extractor = headset_category_extractor

    def produce(self, state_name):
        response = self._http_client.get(self._url.format(state_name.lower()))
        if response.success:
            html_doc = html.fromstring(response.content)
            category_urls = HtmlUtils.get_elements(html_doc, './/div[@class="w-dyn-items"]//div[@class="w-embed"]/a/@href')
            return category_urls
        return []

    def consume(self, category_url):
        category_info = self._category_extractor.extract_category(category_url)
        return category_info

def scrape(arr):
    dispFilter = get_dispensary_filter(arr)
    headset_scraper = HeadsetDispensaryScraper(HttpClient(), HeadsetCategoryExtractor(HttpClient()))
    result = run(dispFilter.get_state_names(), headset_scraper.produce, headset_scraper.consume)

    return json.dumps(result)


if __name__ == "__main__":
    print (scrape(sys.argv[1:]))