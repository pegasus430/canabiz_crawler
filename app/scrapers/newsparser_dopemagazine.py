#!/usr/bin/python
# -*- coding: UTF-8 -*-

from lxml import html
import requests
from datetime import datetime
import json

from news import NewsSite, INewsParser

class NPDopeMagazine(INewsParser):
    def __init__(self):
        self.url = 'http://www.dopemagazine.com/category/news/'

    def clean_html_content(self, htmlDocument):
        elementsToRemoveXpahs = ['//script', '//style', '//div[contains(@class, "essb_links")]']
        for xpath in elementsToRemoveXpahs:
            for element in htmlDocument.xpath(xpath):
                element.getparent().remove(element)

    def getString(self, element, xpath):
        lst = element.xpath(xpath)
        return lst[0] if len(lst) > 0 else ''

    def getFirstElement(self, element, xpath):
        lst = element.xpath(xpath)
        return lst[0] if len(lst) > 0 else element

    def parse(self):
        site = NewsSite(self.url)

        home_raw = requests.get(self.url)
        home = html.fromstring(home_raw.content)
        excerpts = home.xpath('//div[@class="row posts"]//article')

        for excerpt in excerpts:
            element = self.getFirstElement(excerpt,'.//a[contains(@title,.)]')
            title = self.getString(element, './text()').strip()
            url = self.getString(element, './@href')
            
            if not url:
                continue

            article_raw = requests.get(url)
            article = html.fromstring(article_raw.content.decode(article_raw.encoding))
            self.clean_html_content(article)
            
            image_url = self.getString(article,'.//meta[@property="og:image"]/@content')

            strDate = self.getString(article,'.//meta[@property="article:published_time"]/@content')
            date = datetime.strptime(strDate.strip()[:10], "%Y-%m-%d") if strDate else None
                
            body_html_raw = self.getFirstElement(article, '//div[contains(@class,"entry-content")]')
            body_html = html.tostring(body_html_raw)
            body_text = body_html_raw.text_content().strip()

            site.add_article(title, url, image_url, date, body_html, body_text)

        return site.to_dict()


def parse_site():
    parser = NPDopeMagazine()
    return parser.parse()

if __name__ == '__main__':
    result = parse_site()
    print (json.dumps(result))