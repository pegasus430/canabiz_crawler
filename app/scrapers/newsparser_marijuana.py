#!/usr/bin/python
# -*- coding: UTF-8 -*-

from lxml import html
import requests
from datetime import datetime
import json

from news import NewsSite, INewsParser

class NPMarijuana(INewsParser):
    def __init__(self):
        self.url = 'https://www.marijuana.com/news/'

    def parse(self):
        site = NewsSite(self.url)
        home_raw = requests.get(self.url, headers = self.headers)
        home = html.fromstring(home_raw.content)

        excerpts = home.xpath('//article')

        for excerpt in excerpts:
            title = excerpt.xpath('.//h2/a/text()')[0]
            
            url = excerpt.xpath('.//h2/a/@href')[0]
            article_raw = requests.get(url, headers = self.headers)
            article = html.fromstring(article_raw.content)
            for style in article.xpath('//style'):
                style.getparent().remove(style)
            for div in article.xpath('//div[@class="watch-action"]'):
                div.getparent().remove(div)
            for div in article.xpath('//div[@class="sharedaddy sd-sharing-enabled"]'):
                div.getparent().remove(div)
            image_url = article.xpath('.//img[@class="attachment-main-slider size-main-slider wp-post-image"]/@src')[0]
            date_raw = article.xpath('//span[@class="posted-on"]/span/time/@datetime')[0]
            date = datetime.strptime(date_raw.strip()[:10], "%Y-%m-%d")
            body_html_raw = article.xpath('//div[@class="post-content description"]')[0]
            body_html = html.tostring(body_html_raw)
            body_text = body_html_raw.text_content().strip()

            site.add_article(title, url, image_url, date, body_html, body_text)

        return site.to_dict()


def parse_site():
    parser = NPMarijuana()
    return parser.parse()

if __name__ == '__main__':
    print json.dumps(parse_site())
