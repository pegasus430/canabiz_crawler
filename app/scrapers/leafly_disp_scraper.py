from utils import *
from runner import run
import requests
from lxml import html
import sys


class Producer(object):
    def __init__(self, left_city_limit, right_city_limit):
        if (left_city_limit < 'A' or left_city_limit > 'Z') or (
                right_city_limit < 'A' or right_city_limit > 'Z') or right_city_limit <= left_city_limit:
            self._city_range = range(ord('A'), ord('Z')+1)
        else:
            self._city_range = range(ord(left_city_limit), ord(right_city_limit)+1)

    def isValidCity(self, city):
        return ord(city[0]) in self._city_range if city else True

    def produce(self, stateName):
        dispensaries = loads_json(request_dispensaries())
        items = extract_obj_from_json_obj(dispensaries, 'Results')
        for item in items:
            if extract_str_from_json_obj(item, 'State') == stateName and self.isValidCity(
                    extract_str_from_json_obj(item, 'City')):
                yield getPartialDispensary(item)


def request_dispensaries():
    return requests.post('https://www.leafly.com/finder/searchnext', data={'Take': 10000, 'Page': 0}).content


def getPartialDispensary(dispensaryData):
    kv = {'url': 'UrlName', 'rating': 'Rating', 'reviews_count': 'NumReviews', 'name': 'Name', 'city': 'City',
          'phone_number': 'Phone', 'hours_of_operation': 'Schedule', 'state': 'State', 'latitude': 'Latitude',
          'longitude': 'Longitude', 'avatar_url': 'CoverPhotoUrl', 'zip_code': 'Zip', 'address': 'Address1'}
    result = {}
    for key, value in kv.items():
        result[key] = extract_str_from_json_obj(dispensaryData, value)
    return result


def consume(partialDispensary):
    url = extract_str_from_json_obj(partialDispensary, 'url')
    if not url:
        return partialDispensary
    absoluteUrl = 'https://www.leafly.com/dispensary-info/' + url
    partialDispensary['about-dispensary'] = getAboutInfo(absoluteUrl)
    partialDispensary['menu'] = getMenuInfo(absoluteUrl + '/menu')
    partialDispensary['url'] = absoluteUrl
    return partialDispensary


def getAboutInfo(url):
    html = getHtmlDocumentFrom(url)
    return extract_text_from_html(html, "//div[@class='store-about']")


def getPricesInfo(elements):
    result = {}
    if len(elements) == 0:
        return result
    pricesData = extract_elements_from_html(elements[0], './div')
    for priceData in pricesData:
        key = extract_text_from_html(priceData, "(./span)[3]")
        if key:
            result[key] = extract_text_from_html(priceData, "(./span)[1]")
    return result


def getMenuItemInfo(html):
    result = {}
    result['name'] = extract_text_from_html(html, ".//h3[contains(@class,'padding-rowItem')]")
    result['short-description'] = extract_text_from_html(html, ".//div[contains(@class,'description')]")
    result['rating'] = extract_text_from_html(html, ".//div[@class='score']")
    result['prices'] = getPricesInfo(
        extract_elements_from_html(html, ".//div[contains(@class,'item-heading--prices')]"))
    return result


def getMenuInfo(url):
    html = getHtmlDocumentFrom(url)
    categoryElements = extract_elements_from_html(html, "//div[contains(@class,'accordion--main-group')]")
    categoriesResult = []
    for categoryData in categoryElements:
        categoryResult = {}
        categoryResult['name'] = extract_text_from_html(categoryData, ".//h4[contains(@class,'panel-title')]//span")
        itemElements = extract_elements_from_html(categoryData, ".//div[contains(@class,'menu__item m-accordion')]")
        itemsResult = []
        for itemData in itemElements:
            itemsResult.append(getMenuItemInfo(itemData))
            categoryResult['items'] = itemsResult
        categoriesResult.append(categoryResult)
    return categoriesResult


def getHtmlDocumentFrom(url):
    response = requests.get(url)
    try:
        return html.fromstring(response.content)
    except Exception:
        return html.fromstring('<>')


def scrape(state, cityStartLetter='', cityEndLetter=''):
    p = Producer(cityStartLetter, cityEndLetter)
    return run(state, p.produce, consume)


def get_city_limits(text):
    split = text.split('=')
    if not split or len(split) < 2:
        return 'A', 'Z'
    letters = split[1].split('-')
    if not letters or len(letters) < 2:
        return 'A', 'Z'
    l = letters[0]
    r = letters[1]

    if (l < 'A' or l > 'Z') or (r < 'A' or r > 'Z') or r <= l:
        return 'A', 'Z'
    return l, r


if __name__ == '__main__':
    left_city_limit = 'A',
    right_city_limit = 'Z'
    if len(sys.argv) > 2:
        left_city_limit, right_city_limit = get_city_limits(sys.argv[len(sys.argv) - 1])
    data = scrape([sys.argv[1]], left_city_limit, right_city_limit)
    print json.dumps(data)
