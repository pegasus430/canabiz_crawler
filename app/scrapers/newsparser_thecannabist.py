#!/usr/bin/python
# -*- coding: UTF-8 -*-

from lxml import html
import requests
from datetime import datetime
import json

from news import NewsSite, INewsParser

class NPTheCannabist(INewsParser):
    def __init__(self):
        self.url = 'http://www.thecannabist.co/category/news/'

    def parse(self):
        site = NewsSite(self.url)
        home_raw = requests.get(self.url, headers = self.headers)
        home = html.fromstring(home_raw.content)

        excerpts = home.xpath('//article')
        return len(excerpts)

        for excerpt in excerpts:
            title = excerpt.xpath('.//h2/a/text()')[0]
            
            url = excerpt.xpath('.//h2/a/@href')[0]
            article_raw = requests.get(url, headers = self.headers)
            article = html.fromstring(article_raw.content)
            for script in article.xpath('//script'):
                script.getparent().remove(script)
            for style in article.xpath('//style'):
                style.getparent().remove(style)
            for div in article.xpath('//div[@class="entry-meta-tags"]'):
                div.getparent().remove(div)
            for div in article.xpath('//div[@class="post-body-social"]'):
                div.getparent().remove(div)
            for div in article.xpath('//div[@class="entry-meta-author"]'):
                div.getparent().remove(div)
            for div in article.xpath('//div[@class="large-6 medium-12 small-12 columns right sidebox"]'):
                div.getparent().remove(div)
            image_url = article.xpath('.//meta[@property="og:image"]/@content')[0]
            date_raw = article.xpath('//time[@class="entry-date"]/@datetime')[0]
            date = datetime.strptime(date_raw.strip()[:10], "%Y-%m-%d")
            body_html_raw = article.xpath('//div[@class="entry-content"]')[0]
            body_html = html.tostring(body_html_raw)
            body_text = body_html_raw.text_content().strip()

            site.add_article(title, url, image_url, date, body_html, body_text)

        return site.to_dict()


def parse_site():
    parser = NPTheCannabist()
    return parser.parse()

if __name__ == '__main__':
    print json.dumps(parse_site())
