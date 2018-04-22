from lxml import html
from utils import HtmlUtils

class HeadsetCategoryExtractor(object):
    def __init__(self, http_client):
        self._http_client = http_client
        
    def extract_category(self, category_url):
        response = self._http_client.get(category_url)
        category_info = {}
        if response.success:
            html_doc = html.fromstring(response.content)
            category_name = self.get_category_name(html_doc)
            if category_name:
                info = {}
                info['url'] = category_url
                info['items'] = self.get_items(html_doc)
                category_info[category_name] = info
        return category_info

    def get_items(self, html_doc):
        nodes = HtmlUtils.get_elements(html_doc, '//div[@class="w-dyn-list"]//div[@class="product-listing"]')
        return map(self.parse_item, nodes)

    def get_category_name(self, html_doc):
        return HtmlUtils.get_element_value(html_doc, '//div[@class="flex-horiz-product-list"]//h2[@class="best-seller-cat-title"]/text()')

    def parse_item(self, item_node):
        item_info = {}
        if item_node is not None:
            item_info['rank_status'] = self.get_rank_status(item_node)
            item_info['rank'] = self.get_rank(item_node)
            item_info['brand_image'] = self.get_brand_image(item_node)
            item_info['product_name'] = self.get_product_name(item_node)
            item_info['brand_name'] = self.get_brand_name(item_node)
            item_info['product_price'] = self.get_product_price(item_node)
            item_info['image_chart'] = self.get_image_chart(item_node)
    
        return item_info

    def get_rank_status(self, item_node):
        imgurl = HtmlUtils.get_element_value(item_node, './/div[@class="bs-product-rank-image"]/img/@src')
        if 'rank-down' in imgurl:
            return 'down'
        if 'rank-up' in imgurl:
            return 'up'
        return 'unkown'
    
    def get_rank(self, item_node):
        return HtmlUtils.get_element_value(item_node, './div[@class="bs-product-rank"]/h2/text()')

    def get_brand_image(self, item_node):
        image_url = HtmlUtils.get_element_value(item_node, './/div[@class="bs-product-brand-image"]//img/@src')

        return image_url if 'http' in image_url else '' 

    def get_product_name(self, item_node):
        return HtmlUtils.get_element_value(item_node, './/div[@class="bs-product-name"]/h4/text()')

    def get_brand_name(self, item_node):
        return HtmlUtils.get_element_value(item_node, './/div[@class="bs-product-name"]/div/text()')

    def get_product_price(self, item_node):
        value = HtmlUtils.get_element_value(item_node, './/div[@class="bs-product-price"]/h4[2]/text()')
        currency = HtmlUtils.get_element_value(item_node, './/div[@class="bs-product-price"]/h4[1]/text()')
        return value + currency

    def get_image_chart(self, item_node):
        return HtmlUtils.get_element_value(item_node, './/div[@class="bs-product-chart"]//img/@src')
