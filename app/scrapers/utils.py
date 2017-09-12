import json

from datetime import datetime
import requests
from lxml import html


def get(url, **kwargs):
    response = requests.get(url, **kwargs)
    if response.status_code == 200:
        return response.content
    return '<p></p>'


def get_html(url, **kwargs):
    return html.fromstring(get(url, **kwargs))


def get_elements(html, xpath):
    try:
        return html.xpath(xpath)
    except Exception as e:
        return []


def get_text(html, xpath):
    return _get_text(html, '%s/text()' % xpath)


def get_atr(html, xpath, atrName):
    return _get_text(html, '%s/@%s' % (xpath, atrName))


def remove_elements_by_xpaths(html, xpaths):
    for xpath in xpaths:
        for e in html.xpath(xpath):
            e.getparent().remove(e)


def _get_text(html, xpath):
    elements = get_elements(html, xpath)
    if elements and len(elements):
        return elements[0]
    return ''


def get_date(str_date):
    try:
        return datetime.strptime(str_date.strip()[:10], "%Y-%m-%d")
    except Exception:
        return ''


def get_data(htmlDoc,xpath):
    elements = get_elements(htmlDoc, xpath)
    if elements and len(elements) > 0:
        body_html_raw = elements[0]
        return html.tostring(body_html_raw), body_html_raw.text_content().strip()
    return '', ''


def writeToFile(fileName, data):
    with open(fileName, 'w') as outfile:
        json.dump(data, outfile)
