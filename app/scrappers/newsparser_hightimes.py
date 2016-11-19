#!/usr/bin/python
# -*- coding: UTF-8 -*-

from lxml import html
import requests
from datetime import datetime
import json

from news import NewsSite, INewsParser

class NPHighTimes(INewsParser):
    def __init__(self):
        self.url = 'http://hightimes.com/news/'

    def parse(self):
        site = NewsSite(self.url)
        home_raw = requests.get(self.url, headers = self.headers)
        home = html.fromstring(home_raw.content)

        excerpts = home.xpath('//article')

        for excerpt in excerpts:
            title = excerpt.xpath('.//a[@rel="bookmark"]/text()')[0]
            
            url = excerpt.xpath('.//a[@rel="bookmark"]/@href')[0]
            image_url = excerpt.xpath('.//a[@rel="bookmark"]/img/@src')[0]
            article_raw = requests.get(url, headers = self.headers)
            article = html.fromstring(article_raw.content)
            date_raw = article.xpath('(//div[@class="share"])[2]/preceding-sibling::div//strong/following-sibling::text()')[0]
            date = datetime.strptime(date_raw.strip(), "%B %d, %Y")
            body_html = html.tostring(article.xpath('//section[@class="entry-content"]')[0])
            body_text = article.xpath('//section[@class="entry-content"]')[0].text_content().strip()

            site.add_article(title, url, image_url, date, body_html, body_text)

        return site.to_dict()


def parse_site():
    parser = NPHighTimes()
    return parser.parse()

if __name__ == '__main__':
    print json.dumps(parse_site())
