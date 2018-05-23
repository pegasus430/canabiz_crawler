from lxml import html
from utils import HtmlUtils
from httpclient import HttpClient
import json
from disp_filter import get_dispensary_filter
from runner import run
import sys
from leafbuyer_helpers import LeafbuyerDispInfoExtractor


class LeafbuyerDispensaryScraper(object):
    def __init__(self, http_client, leafbuyer_disp_info_extractor):
        self._http_client = http_client
        self._url = 'https://www.leafbuyer.com/deals/dispensaries/{0}/{1}'
        self._disp_info_extractor = leafbuyer_disp_info_extractor

    def produce(self, state_name):
        page_index = 1
        should_continue = True
        while should_continue:
            resp = self._http_client.get(self._url.format(state_name.upper(), page_index))
            if resp.success:
                nodes = self._get_deal_nodes(resp.content)
                #to improve: return iter(list)
                for n in nodes:
                    yield n
                should_continue = self._can_continue(page_index, resp.url)
                page_index = page_index + 1

    def _get_deal_nodes(self, page_html):
        html_doc = html.fromstring(page_html)
        return HtmlUtils.get_elements(html_doc, '//div[contains(@class,"detail-holder")]')

    def _can_continue(self, current_page_index, response_url):
        return int(response_url.split('/')[-1]) == current_page_index
        
    def consume(self, deal_node):
        return self._disp_info_extractor.get_disp_info(deal_node)

def scrape(arr):
    dispFilter = get_dispensary_filter(arr)
    leafbuyer_scraper = LeafbuyerDispensaryScraper(HttpClient(), LeafbuyerDispInfoExtractor())
    result = run(dispFilter.get_state_names(), leafbuyer_scraper.produce, leafbuyer_scraper.consume)
    return json.dumps(result)

if __name__ == "__main__":
    print (scrape(sys.argv[1:]))