#!/usr/bin/python
# -*- coding: UTF-8 -*-

import requests
import json
import urllib3
from lxml import html
from datetime import datetime
from requests.packages.urllib3.exceptions import InsecureRequestWarning

from news import NewsSite, INewsParser

class NPGreenRushDaily(INewsParser):
    def __init__(self):
        self.url = 'http://www.greenrushdaily.com'

    def parse(self):
        requests.packages.urllib3.disable_warnings(InsecureRequestWarning)
        site = NewsSite(self.url)
        home_raw = requests.get(self.url, headers = self.headers, verify = False)
        home = html.fromstring(home_raw.content)

        excerpts = home.xpath('//article')

        for excerpt in excerpts:
            title = excerpt.xpath('.//h2/a/text()')[0].strip()
            
            url = excerpt.xpath('.//h2/a/@href')[0]
            article_raw = requests.get(url, headers = self.headers)
            article = html.fromstring(article_raw.content)
            for script in article.xpath('//script'):
                script.getparent().remove(script)
            for style in article.xpath('//style'):
                style.getparent().remove(style)
            for div in article.xpath('//div[contains(@class, "wipa-container")]'):
                div.getparent().remove(div)
            image_url = None
            image_raw = article.xpath('.//meta[@property="og:image"]/@content')
            if len(image_raw):
                image_url = image_raw[0]
            date_raw = article.xpath('//div[contains(@class, "cb-entry-header")]//time/@datetime')[0]
            date = datetime.strptime(date_raw.strip()[:10], "%Y-%m-%d")
            body_html_raw = article.xpath('//span[@class="cb-itemprop"]')[0]
            body_html = html.tostring(body_html_raw)
            body_text = body_html_raw.text_content().strip()

            site.add_article(title, url, image_url, date, body_html, body_text)

        return site.to_dict()


def parse_site():
    parser = NPGreenRushDaily()
    return parser.parse()

if __name__ == '__main__':
    print (json.dumps(parse_site()))
