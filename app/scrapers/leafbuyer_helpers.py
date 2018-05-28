from lxml import html
from utils import HtmlUtils

class LeafbuyerDispInfoExtractor(object):
     
    def get_disp_info(self, deal_node_and_script_info):
        dispensary_info = {}
        deal_node = deal_node_and_script_info[0]
        script_info = deal_node_and_script_info[1]
        dispensary_info['url'] = self._get_dispensary_url(deal_node)
        dispensary_info['name'] = self._get_dispensary_name(deal_node)
        dispensary_info['image_url'] = self._get_image_url(deal_node)
        dispensary_info['address'] = self._get_dispensary_address(deal_node)
        dispensary_info['phone_number'] = self._get_dispensary_phone_number(deal_node)
        dispensary_info['deal_name'] = self._get_deal_name(deal_node)
        dispensary_info['is_top_deal'] = self.is_top_deal(deal_node)
        dispensary_info['minimum_age'] = self._get_dispensary_minimum_age(deal_node)
        
        if len(script_info) > 0:            
            dispensary_info['deal_quantity'] = self._get_deal_quantity(script_info)
            dispensary_info['deal_price'] = self._get_deal_price(script_info)
        return dispensary_info

    def _get_dispensary_url(self, deal_node):
        return 'https://www.leafbuyer.com' + HtmlUtils.get_element_value(deal_node, './/div[@class="loc-name-addr"]/strong/a/@href')

    def _get_dispensary_name(self, deal_node):
        return HtmlUtils.get_element_value(deal_node, './/div[@class="profile-link"]/text()')

    def _get_image_url(self, deal_node):
        return 'https://www.leafbuyer.com' + HtmlUtils.get_element_value(deal_node, '//div[contains(@class, "img-block")]/a/img/@src')

    def _get_dispensary_address(self, deal_node):
        return HtmlUtils.get_element_value(deal_node, './/div[@class="text-box"]//span[@class="txt"]/text()').strip()

    def _get_dispensary_phone_number(self, deal_node):
        return HtmlUtils.get_element_value(deal_node, './/div[@class="text-box"]//span[@class="tel-link"]/text()')

    def _get_deal_name(self, deal_node):
        return HtmlUtils.get_element_value(deal_node, './/div[@class="text-wrap"]/h1/text()')

    def _get_deal_price(self, script_info):
        price_info = {}
        price_info['originalPrice'] = self._decode(script_info[6])
        price_info['percentageOff'] = self._decode(script_info[8])
        price_info['salePrice'] = self._decode(script_info[7])
        price_info['info'] = self._decode(script_info[11])
        return price_info

    def _get_deal_quantity(self, script_info):
        quantity = {}
        quantity['cbd'] = self._decode(script_info[20])
        quantity['thc'] = self._decode(script_info[19])
        quantity['weight'] = self._decode(script_info[18])
        return quantity

    def _decode(self, text):
        return text.replace("&nbsp;", ' ')

    def _strip_quantity(self, quantity):
        if quantity is str:
            return quantity.strip()
        return HtmlUtils.get_element_value(quantity, './text()')

    def is_top_deal(self, deal_node):
        return HtmlUtils.get_element_value(deal_node, './/div[@class="deal-box"]/text()') != ''

    def _get_dispensary_minimum_age(self, deal_node):
        return '21' if HtmlUtils.get_element_value(deal_node, '//ul[@class="detail-list"]/li/span[contains(@class, "icon-retail")]') != '' else 'unkown'

