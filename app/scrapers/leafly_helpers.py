from lxml import html
from utils import HtmlUtils
import re
from jsonutils import *

class LeaflyDetailsExtractor(object):

    def __init__(self, http_client):
        self._http_client = http_client

    def get_menu_info(self, menu_url):
        response = self._http_client.get(menu_url)
        categorized_menu = {}
        if not response.success:
            return categorized_menu

        dataPattern = r"__Next_data__\s*=\s*(.*)\s*module={}"
        searchResult = re.search(dataPattern, response.content, re.IGNORECASE)
        if searchResult:
            json_data = loadJson(searchResult.group(1))
            menuItemsLst = try_get_list(json_data, 'props', 'menu', 'categorized')
            if len(menuItemsLst) > 0:
                for k,v in menuItemsLst[0].items():
                    categorized_menu[k] = map(self._get_menu_item_info, v)
        return categorized_menu


    def get_about_info(self, url):
        response = self._http_client.get(url)
        if response.success:
            html_doc = html.fromstring(response.content)
            return HtmlUtils.get_element_value(html_doc, "//div[@class='store-about']/text()")
        return ''

    def _get_menu_item_info(self, json_data):
        result = {}
        result['name'] = self._get_first_or_empty(try_get_list(json_data, 'name'))
        result['description'] = self._get_first_or_empty(try_get_list(json_data, 'description'))
        result['imageUrl'] = ''
        image_url = self._get_first_or_empty(try_get_list(json_data, 'imageUrl'))

        if image_url and image_url.startswith('http'):
            result['imageUrl'] = image_url

        result['strain'] = self._get_menu_item_strain(json_data)
        result['brand'] = self._get_menu_item_brand(json_data)

        pricesLst = try_get_list(json_data, 'variants')
        if len(pricesLst) > 0:
            result['prices'] = [p for p in map(self._get_menu_item_prices, pricesLst[0]) if p]
        else:
            result['prices'] = []

        return result

    def _get_menu_item_strain(self, json_data):
        result = {}
        result['name'] = self._get_first_or_empty(try_get_list(json_data, 'strainName'))

        strainSlug = self._get_first_or_empty(try_get_list(json_data, 'strainSlug'))
        strainCategory = self._get_first_or_empty(try_get_list(json_data, 'strainCategory'))

        if strainSlug and strainCategory:
            result['url'] = 'https://www.leafly.com/{0}/{1}'.format(strainCategory.lower(), strainSlug)
        else:
            result['url'] = ''
        return result

    def _get_menu_item_brand(self, json_data):
        result = {}
        result['name'] = self._get_first_or_empty(try_get_list(json_data, 'brandName'))

        brandSlug = self._get_first_or_empty(try_get_list(json_data, 'brandSlug'))

        if brandSlug:
            result['url'] = 'https://www.leafly.com/brands/{0}'.format(brandSlug)
        else:
            result['url'] = ''
        return result

    def _get_menu_item_prices(self, json_data):
        result = {}
        quantity = self._get_first_or_empty(try_get_list(json_data, 'packageDisplayUnit'))
        price = self._get_first_or_empty(try_get_list(json_data, 'packagePrice'))

        if quantity and price:
            result['price'] = price
            result['quantity'] = quantity
        return result

    def _get_first_or_empty(self, lst):
        return lst[0] if len(lst) > 0  else ''
