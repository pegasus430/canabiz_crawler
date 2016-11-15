#!/usr/bin/python
# -*- coding: UTF-8 -*-

from lxml import html
import requests
from datetime import datetime

from news import NewsSite

def parse_site():
    headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'}

    site_url = 'http://hightimes.com/news/'
    site = NewsSite(site_url)
    home_raw = requests.get(site_url, headers = headers)
    home = html.fromstring(home_raw.content)

    excerpts = home.xpath('//article')

    for excerpt in excerpts:
        title = excerpt.xpath('.//a[@rel="bookmark"]/text()')[0]
        
        url = excerpt.xpath('.//a[@rel="bookmark"]/@href')[0]
        image_url = excerpt.xpath('.//a[@rel="bookmark"]/img/@src')[0]
        article_raw = requests.get(url, headers = headers)
        article = html.fromstring(article_raw.content)
        date_raw = article.xpath('(//div[@class="share"])[2]/preceding-sibling::div//strong/following-sibling::text()')[0]
        date = datetime.strptime(date_raw.strip(), "%B %d, %Y")
        body_html = html.tostring(article.xpath('//section[@class="entry-content"]')[0])
        body_text = article.xpath('//section[@class="entry-content"]')[0].text_content().strip()

        site.add_article(title, url, image_url, date, body_html, body_text)

    return site.to_json()


if __name__ == '__main__':
    print parse_site()
