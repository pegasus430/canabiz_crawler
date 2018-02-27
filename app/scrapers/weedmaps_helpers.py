import re
from lxml import html
from jsonutils import *

class WeedMapsDespensaryExtractor(object):
    def __init__(self, dispensary_filter, detailsExtractor):
        self.detailsExtractor = detailsExtractor
        self._dispensary_filter = dispensary_filter

    def extract(self, data):
        listingLst = try_get_list(data, 'listing')
        if len(listingLst) == 0:
            return None

        listing = listingLst[0]
        cityLst = try_get_list(listing, 'city')
        if len(cityLst) == 0 or not self._dispensary_filter.match_city(cityLst[0]):
            return None

        result = {}
        self.fill_menu(result, data)
        self.fill_social_details(result, listing)
        self.fill_details(result, listing)

        return result


    def fill_details(self, result, source):
        paths = {'city': 'city',
                 'url': 'url',
                 'email': 'email',
                 'phone_number': 'phone_number',
                 'name': 'name',
                 'avatar_url': 'avatar_url',
                 'reviews_count': 'reviews_count',
                 'rating': 'rating',
                 'address': 'address',
                 'region': 'region',
                 'state': 'state',
                 'zip_code': 'zip_code',
                 'latitude': 'latitude',
                 'longitude': 'longitude',
                 'hours_of_operation': 'hours_of_operation'}

        fill_obj(result, source, paths)


    def fill_menu(self, result, source):
        catLst = try_get_list(source, 'categories')

        if len(catLst) == 0:
            return

        result["menu"] = self.get_menu(catLst[0])


    def fill_social_details(self, result, source):
        urlLst = try_get_list(source, 'url')

        if len(urlLst) == 0:
            return result

        result["details"] = self.detailsExtractor.getDetails(urlLst[0])


    def get_menu(self, menuData):
        menu = []
        for c in menuData:
            category = {}
            fill_obj(category, c, {'title' : 'title'})

            items = []
            for i in c["items"]:
                o = {}
                self.fill_menu_details(o, i)
                items.append(o)

            category["items"] = items
            menu.append(category)
        return menu

    def fill_menu_details(self, result, source):
        paths = {'name': 'name',
                 'grams_per_eighth': 'grams_per_eighth',
                 'prices': 'prices',
                 'image_url': 'image_url',
                 'url': 'url'}
        fill_obj(result, source, paths)
        result['url'] = 'https://weedmaps.com/dispensaries/' + result['url']


class WeedMapsDetailsExtractor(object):
    def __init__(self, http_client):
        self._http_client = http_client

    def getDetails(self, url):
        response = self._http_client.get(url)
        if response.success:
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
            result["age"] = self._getAge(home)
            return result
        return {}

    def _getAge(self, htmlDocument):
        textList = htmlDocument.xpath("//div[@class='tag-icon']//div[contains(@class, 'icon_age')]/@class")
        if len(textList) == 0:
            return "not specified"
        return re.findall(r'\d+', textList[0])[0] + '+'
