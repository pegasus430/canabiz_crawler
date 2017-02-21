#!/usr/bin/python
# -*- coding: UTF-8 -*-

from lxml import html
import requests
from datetime import datetime
import json

from news import NewsSite, INewsParser

class NPCannaLawBlog(INewsParser):
    def __init__(self):
        self.url = 'http://www.cannalawblog.com'

    def parse(self):
        site = NewsSite(self.url)
        home_raw = requests.get(self.url, headers = self.headers)
        home = html.fromstring(home_raw.content)

        excerpts = home.xpath('//article')

        for excerpt in excerpts:
            title = excerpt.xpath('.//h1/a/text()')[0].strip()
            
            url = excerpt.xpath('.//h1/a/@href')[0]
            article_raw = requests.get(url, headers = self.headers)
            article = html.fromstring(article_raw.content)
            for script in article.xpath('//script'):
                script.getparent().remove(script)
            for style in article.xpath('//style'):
                style.getparent().remove(style)
            image_url = None
            image_raw = article.xpath('.//article/div/img/@src')
            if len(image_raw):
                image_url = image_raw[0]
            date_raw = article.xpath('//header//time/@datetime')[0]
            date = datetime.strptime(date_raw.strip()[:10], "%Y-%m-%d")
            body_html_raw = article.xpath('//article/div')[0]
            body_html = html.tostring(body_html_raw)
            body_text = body_html_raw.text_content().strip()

            site.add_article(title, url, image_url, date, body_html, body_text)

        return site.to_dict()


def parse_site():
    parser = NPCannaLawBlog()
    return parser.parse()

if __name__ == '__main__':
    print json.dumps(parse_site())
