#!/usr/bin/python
# -*- coding: UTF-8 -*-

from lxml import html
import requests
from datetime import datetime
import json

from news import NewsSite, INewsParser

class NPLeafly(INewsParser):
    def __init__(self):
        self.url = 'https://www.leafly.com/news'

    def parse(self):
        site = NewsSite(self.url)
        home_raw = requests.get(self.url, headers = self.headers)
        home = html.fromstring(home_raw.content)

        excerpts = home.xpath('//a[@class="leafly-article"]')

        for excerpt in excerpts:
            title = excerpt.xpath('.//span[@class="leafly-title"]/text()')[0]
            
            url = excerpt.xpath('./@href')[0]
            article_raw = requests.get(url, headers = self.headers)
            article = html.fromstring(article_raw.content)
            for script in article.xpath('//script'):
                script.getparent().remove(script)
            date_raw = article.xpath('//meta[@property="article:published_time"]/@content')
            date = None
            if len(date_raw):
                date_raw = date_raw[0]
                date = datetime.strptime(date_raw.strip()[:10], "%Y-%m-%d")
            image_url = None
            image_url_raw = article.xpath('//div[@class="leafly-standard-article-header"]//img/@src')
            if len(image_url_raw):
                image_url = image_url_raw[0]
            body_html = None
            body_text = None
            body_html_raw = article.xpath('//div[@class="leafly-legacy-article"]')
            if len(body_html_raw):
                body_html = html.tostring(body_html_raw[0])
            else:
                body_html_raw = article.xpath('//div[@class="post-content style-light"]/div[2]//div[@class="uncode_text_column"]')
                body_html = html.tostring(body_html_raw[0])
            body_text = body_html_raw[0].text_content().strip()

            site.add_article(title, url, image_url, date, body_html, body_text)

        return site.to_dict()


def parse_site():
    parser = NPLeafly()
    return parser.parse()

if __name__ == '__main__':
    print json.dumps(parse_site())
