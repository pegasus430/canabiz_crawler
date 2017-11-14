#!/usr/bin/python
# -*- coding: UTF-8 -*-

from lxml import html
import requests
from datetime import datetime
import json

from news import NewsSite, INewsParser
from utils import  *

class NPMarijuana(INewsParser):
    def __init__(self):
        self.url = 'https://www.marijuana.com/news/'
        self.xpahts_to_remove = ['//style','//script','/div[@class="watch-action"]','//div[@class="sharedaddy sd-sharing-enabled"]']

    def request(self, url):
        return requests.get(url, headers=self.headers, verify=False)

    def parse(self):
        site = NewsSite(self.url)
        home = get_html(self.url, headers=self.headers, verify=False)

        news = home.xpath('//article')

        for n in news:
            title = get_text(n, './/h2/a')
            url = get_atr(n, './/h2/a','href')
            if not url:
                continue

            article = get_html(url,headers=self.headers, verify=False)
            remove_elements_by_xpaths(article, self.xpahts_to_remove)

            image_url = get_atr(article, './/img[@class="attachment-main-slider size-main-slider wp-post-image"]','src')
            date =  get_date(get_atr(article, '//span[@class="posted-on"]/span/time', 'datetime'))
            body_html, body_text = get_data(article, '//div[@class="post-content description"]')

            site.add_article(title, url, image_url, date, body_html, body_text)

        return site.to_dict()


def parse_site():
    parser = NPMarijuana()
    return parser.parse()

if __name__ == '__main__':
    print json.dumps(parse_site())
