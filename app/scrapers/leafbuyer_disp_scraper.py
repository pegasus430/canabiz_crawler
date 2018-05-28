from lxml import html
from utils import HtmlUtils
from httpclient import HttpClient
import json
from disp_filter import get_dispensary_filter
from runner import run
import sys
from leafbuyer_helpers import LeafbuyerDispInfoExtractor
import re
from csv import reader

class LeafbuyerDispensaryScraper(object):
    def __init__(self, http_client, leafbuyer_disp_info_extractor):
        self._http_client = http_client
        self._url = 'https://www.leafbuyer.com/deals/dispensaries/{0}/{1}'
        self._disp_info_extractor = leafbuyer_disp_info_extractor
        self._script_info_pattern = re.compile(r'new\scoupon\((.*?)\),', re.IGNORECASE)
        self._script_info_expected_values = 34

    def produce(self, state_name):
        page_index = 1
        should_continue = True
        while should_continue:
            resp = self._http_client.get(self._url.format(state_name.upper(), page_index))
            if resp.success:
                nodes = self._get_deal_nodes(resp.content)
                script_infos = self._get_script_info(resp.content)
                #to improve: return iter(list)
                for n in nodes:
                    script_info = self._search_script_info(n, script_infos)
                    yield (n, script_info)
                should_continue = self._can_continue(page_index, resp.url)
                page_index = page_index + 1

    def _get_deal_nodes(self, page_html):
        html_doc = html.fromstring(page_html)
        return HtmlUtils.get_elements(html_doc, '//div[contains(@class,"detail-holder")]')

    def _get_script_info(self, html_source):
        all_groups = self._script_info_pattern.findall(html_source)
        result = []
        for g in reader(all_groups):
            if len(g) == self._script_info_expected_values:
                result.append(g)
        return result

    def _search_script_info(self, deal_node, script_infos):
        node_id = HtmlUtils.get_element_value(deal_node, './@id')
        for i in script_infos:
            if i[0] in node_id:
                return i
        return []

    def _can_continue(self, current_page_index, response_url):
        return int(response_url.split('/')[-1]) == current_page_index

    def consume(self, deal_node_and_script_info):
        return self._disp_info_extractor.get_disp_info(deal_node_and_script_info)

def scrape(arr):
    dispFilter = get_dispensary_filter(arr)
    leafbuyer_scraper = LeafbuyerDispensaryScraper(HttpClient(), LeafbuyerDispInfoExtractor())
    result = run(dispFilter.get_state_names(), leafbuyer_scraper.produce, leafbuyer_scraper.consume)
    return json.dumps(result)

if __name__ == "__main__":
    print (scrape(sys.argv[1:]))