#!/usr/bin/python
# -*- coding: UTF-8 -*-

import json

class INewsParser:
    """Interface of a site parser"""
    headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36'}
    url = None

    def __init__(self, url):
        self.url = url

    def __init__(self, url, headers):
        self.url = url
        self.headers = headers

    def parse(self):
        raise NotImplementedError


class NewsArticle:
    """Class to handle News article"""
    title = ""
    url = ""
    image_url = ""
    date = ""
    text_html = ""
    text_plain = ""

    def __init__(self, title, url, image_url, date, text_html, text_plain):
        self.title = title
        self.url = url
        self.image_url = image_url
        self.date = date
        self.text_html = text_html
        self.text_plain = text_plain

    def to_dict(self):
        date_str = ''
        if self.date:
            date_str = self.date.strftime('%Y-%m-%d')
        return {'title': self.title, 'url': self.url, 
        'image_url': self.image_url, 'date': date_str, 
        'text_html': self.text_html, 'text_plain': self.text_plain}

class NewsSite:
    """Class to handle News sites"""
    url = ""
    articles = []

    def __init__(self, url):
        self.url = url

    def add_article(self, title, url, image_url, date, text_html, text_plain):
        article = NewsArticle(title, url, image_url, date, text_html, text_plain)
        self.articles.append(article)

    def to_dict(self):
        art_dicts = []
        for article in self.articles:
            art_dicts.append(article.to_dict())

        return {'url': self.url, 'articles': art_dicts}

    def to_json(self):
        return json.dumps(self.to_dict())