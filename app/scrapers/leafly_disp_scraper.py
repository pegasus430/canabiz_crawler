from utils import *
from runner import run
import requests
from lxml import html
import sys
import json

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


def produce(stateName):
    dispensaries = loads_json(request_dispensaries())
    items = extract_obj_from_json_obj(dispensaries, 'Results')
    for item in items:
        if extract_str_from_json_obj(item, 'State') == stateName:
            yield getPartialDispensary(item)


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
    htmlDocument = html.fromstring(response.content)
    return htmlDocument


if __name__ == '__main__':
    print json.dumps(run(sys.argv[1:], produce, consume))
