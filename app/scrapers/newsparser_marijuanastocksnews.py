#!/usr/bin/python
# -*- coding: UTF-8 -*-

from utils import *

from news import NewsSite, INewsParser


class NPMarijuanaStocksNews(INewsParser):
    def __init__(self):
        self.url = 'http://marijuanastocks.com/category/marijuana-stocks-news/'
        self.xpaths_to_remove = ['//script', '//style', '//div[contains(@class, "mantis__recommended__wordpress")]',
                                '//div[contains(@class, "addtoany_share_save_container")]']

    def parse(self):
        site = NewsSite(self.url)
        home = get_html(self.url, headers=self.headers)

        news = get_elements(home, '//div[@class="td-block-span6"]')

        for n in news:
            title = get_text(n, './/h3/a')
            url = get_atr(n, './/h3/a', 'href')
            if not url:
                continue

            article = get_html(url, headers=self.headers)
            remove_elements_by_xpaths(article, self.xpaths_to_remove)

            image_url = get_atr(article, './/meta[@property="og:image"]', 'content')
            date = get_date(get_atr(article, './/header//time', 'datetime'))
            body_html, body_text = get_data(article, '//div[@class= "td-post-content"]')

            site.add_article(title, url, image_url, date, body_html, body_text)

        return site.to_dict()


def parse_site():
    parser = NPMarijuanaStocksNews()
    return parser.parse()


if __name__ == '__main__':
    print json.dumps(parse_site())
