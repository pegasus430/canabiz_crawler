from disp_filter import get_dispensary_filter
from jsonutils import loadJson, try_get_list
from weedmaps_helpers import WeedMapsDespensaryExtractor, WeedMapsDetailsExtractor
from runner import run
from httpclient import HttpClient
import json
import sys

class WeedMapsDispensaryScraper(object):
    def __init__(self, dispesary_filter, http_client):
        self._http_client = http_client
        self._weedmaps_disp_extractor = WeedMapsDespensaryExtractor(dispesary_filter, WeedMapsDetailsExtractor(HttpClient()))

        self._url = "https://api-v2.weedmaps.com/api/v2/listings?filter%5Bplural_types%5D%5B%5D=dispensaries&filter%5Bregion_slug%5Bdispensaries%5D%5D={0}&page_size=150&page={1}"

    def produce(self, state):
        current_index = 1
        should_continue = True
        while should_continue:
            url = self._url.format(state.replace(' ', '-'), current_index)
            response = self._http_client.get(url)
            should_continue = response.success
            if response.success:
                json_data = loadJson(response.content)
                listings = try_get_list(json_data, "data", "listings")
                if len(listings) == 0:
                    break
                for l in listings[0]:
                    url_list = try_get_list(l, "slug")
                    if len(url_list) > 0:
                        yield url_list[0]
                current_index = current_index + 1

    def consume(self, item_from_poroduce):
        url = self.reconstruct_url(item_from_poroduce)
        response = self._http_client.get(url)
        if response.success:
            json_data = loadJson(response.content)
            return self._weedmaps_disp_extractor.extract(json_data)
        return None
    
    def reconstruct_url(self, url_part):
        return "https://weedmaps.com/api/web/v1/listings/" + url_part + "/menu?type=dispensary"

def scrape(arr):
    dispFilter = get_dispensary_filter(arr)
    wmScraper = WeedMapsDispensaryScraper(dispFilter, HttpClient())
    result = run(dispFilter.get_state_names(), wmScraper.produce, wmScraper.consume)

    return json.dumps(result)

if __name__ == "__main__":
     print (scrape(sys.argv[1:]))