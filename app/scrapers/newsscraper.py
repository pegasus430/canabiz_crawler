import requests
from lxml import html
from news import NewsSite
from utils import HtmlUtils
from datetime import datetime


class NewsScraper(object):
    html_getter = None
    xpaths_container = None
    url = ''

    def __init__(self, html_getter, url, xpaths_container):
        self.html_getter = html_getter
        self.url = url
        self.xpaths_container = xpaths_container

    def parse(self):
        site_result = NewsSite(self.url)

        html_string = self.html_getter.get(self.url)
        if not html_string:
            return

        html_document = html.fromstring(html_string)

        news = HtmlUtils.get_elements(html_document, self.xpaths_container.get_news_xpath())

        for n in news:
            title = self._get_title(n)
            url = self._get_url(n)

            if not url:
                continue

            html_string = self.html_getter.get(url)

            if not html_string:
                continue

            article = html.fromstring(html_string)

            image_url = self._get_image_url(article)
            date = self._get_date(article)

            self.remove_elements(article, self.xpaths_container.get_elements_to_remove_xpaths())

            text_html = self._get_text_html(article)
            text_plain = self._get_text_plain(article)

            site_result.add_article(title, url, image_url, date, text_html, text_plain)

        return site_result.to_dict()

    def get_title(self, html_document, title_xpath):
        return HtmlUtils.get_element_value(html_document, title_xpath)

    def select_title(self, title):
        return title

    def get_url(self, html_document, url_xpath):
        return HtmlUtils.get_element_value(html_document, url_xpath)

    def select_url(self, url):
        return url

    def get_image_url(self, html_document, image_xpath):
        return HtmlUtils.get_element_value(html_document, image_xpath)

    def select_image_url(self, image_url):
        return image_url

    def get_date(self, html_document, date_xpath):
        return HtmlUtils.get_element_value(html_document, date_xpath)

    def select_date(self, date_str):
        return date_str.strip()[:10] if len(date_str) >= 10 else ''

    def remove_elements(self, html_document, elements_to_remove_xpaths):
        HtmlUtils.remove_elements(html_document, elements_to_remove_xpaths)

    def get_text_html(self, html_document, content_xpath):
        return HtmlUtils.get_text_html(html_document, content_xpath)

    def select_text_html(self, text_html):
        return text_html

    def get_text_plain(self, html_document, content_xpath):
        return HtmlUtils.get_text_plain(html_document, content_xpath)

    def select_text_plain(self, text_plain):
        return text_plain

    def get_date_format(self):
        return "%Y-%m-%d"

    def _get_text_plain(self, article):
        text_plain = self.get_text_plain(article, self.xpaths_container.get_content_xpath())
        text_plain = self.select_text_plain(text_plain)
        return text_plain

    def _get_text_html(self, article):
        text_html = self.get_text_html(article, self.xpaths_container.get_content_xpath())
        text_html = self.select_text_html(text_html)
        return text_html

    def _get_date(self, article):
        date_str = self.get_date(article, self.xpaths_container.get_date_xpath())
        date_str = self.select_date(date_str)
        try:
            return datetime.strptime(date_str, self.get_date_format())
        except Exception as e:
            return None

    def _get_image_url(self, article):
        image_url = self.get_image_url(article, self.xpaths_container.get_image_xpath())
        image_url = self.select_image_url(image_url)
        return image_url

    def _get_url(self, n):
        url = self.get_url(n, self.xpaths_container.get_url_xpath())
        url = self.select_url(url)
        return url

    def _get_title(self, n):
        title = self.get_title(n, self.xpaths_container.get_title_xpath())
        title = self.select_title(title)
        return title

class HtmlGetter:
    kwargs = {}

    def __init__(self, **kwargs):
        self.kwargs = kwargs
        if 'headers' not in self.kwargs:
            kwargs['headers'] = {
                'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.78 Safari/537.36 OPR/47.0.2631.55'}

    def get(self, url):
        response = requests.get(url, **self.kwargs)

        html = response.content if response.status_code else ''

        return html


class XpathsContainer:
    news_xpath = ''
    title_xpath = ''
    url_xpath = ''
    image_xpath = ''
    date_xpath = ''
    elements_to_remove_xpaths = []
    content_xpath = ''

    def __init__(self, news_xpath, title_xpath, url_xpath, image_xpath, date_xpath, elements_to_remove_xpaths,
                 content_xpath):
        self.news_xpath = news_xpath
        self.title_xpath = title_xpath
        self.url_xpath = url_xpath
        self.image_xpath = image_xpath
        self.date_xpath = date_xpath
        self.elements_to_remove_xpaths = elements_to_remove_xpaths
        self.content_xpath = content_xpath

    def get_news_xpath(self):
        return self.news_xpath

    def get_title_xpath(self):
        return self.title_xpath

    def get_url_xpath(self):
        return self.url_xpath

    def get_image_xpath(self):
        return self.image_xpath

    def get_date_xpath(self):
        return self.date_xpath

    def get_elements_to_remove_xpaths(self):
        return self.elements_to_remove_xpaths

    def get_content_xpath(self):
        return self.content_xpath