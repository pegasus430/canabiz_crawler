from jsonutils import *
from disp_filter import *
from httpclient import HttpClient
from runner import run
from leafly_helpers import *
import sys

class LeaflyDispensaryScraper(object):

    def __init__(self, dispensary_filter, http_client, leafly_details_extractor):
        self._dispensary_filter = dispensary_filter
        self._http_client = http_client
        self._details_extractor = leafly_details_extractor

        self._url = 'https://www.leafly.com/finder/searchnext'
        self._data = {'Take': 1000, 'Page': 0}

    def produce(self, state_name):
        response = self._http_client.post(self._url, data = self._data)
        if response.success:
            json_data = loadJson(response.content)
            itemsLst = try_get_list(json_data, 'Results')
            if len(itemsLst) > 0:
                for item in itemsLst[0]:
                    stateLst = try_get_list(item, 'State')
                    cityLst = try_get_list(item, 'City')
                    if len(stateLst) > 0  and len(cityLst) > 0:
                        # print stateLst[0]
                        if stateLst[0].lower() == state_name.lower() and self._dispensary_filter.match_city(cityLst[0]):
                            yield self.get_partial_dispensary(item)

    def consume(self, item_from_produce):
        url = try_get_list(item_from_produce, 'url')[0]
        if not url:
            return item_from_produce

        absoluteUrl = 'https://www.leafly.com/dispensary-info/' + url
        item_from_produce['url'] = absoluteUrl
        item_from_produce['about_dispensary']  = self._details_extractor.get_about_info(absoluteUrl)
        item_from_produce['menu'] = self._details_extractor.get_menu_info(absoluteUrl + '/menu')

        return item_from_produce

    def get_partial_dispensary(self, json_data):
        paths = {'url': 'UrlName',
                 'rating': 'Rating',
                 'reviews_count': 'NumReviews',
                 'name': 'Name',
                 'city': 'City',
                 'phone_number': 'Phone',
                 'hours_of_operation': 'Schedule',
                 'state': 'State',
                 'latitude': 'Latitude',
                 'longitude': 'Longitude',
                 'avatar_url': 'CoverPhotoUrl',
                 'zip_code': 'Zip',
                 'address': 'Address1'}

        result = {}

        fill_obj(result, json_data, paths)

        return result

def scrape(arr):
    dispFilter = get_dispensary_filter(arr)
    leaflyScraper = LeaflyDispensaryScraper(dispFilter, HttpClient(), LeaflyDetailsExtractor(HttpClient()))
    result = run(dispFilter.get_state_names(), leaflyScraper.produce, leaflyScraper.consume)

    return json.dumps(result)


if __name__ == "__main__":
    print (scrape(sys.argv[1:]))