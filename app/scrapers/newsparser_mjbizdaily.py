import json
from newsscraper import NewsScraper, HtmlGetter, XpathsContainer


class NPMJBizDaily(NewsScraper):
    def __init__(self):
        xpaths = {'news_xpath': '//article',
                  'title_xpath': './/header//a/text()',
                  'url_xpath': './/header//a/@href',
                  'image_xpath': '//section[@class= "entry-content"]//img/@src',
                  'date_xpath': '//header[contains(@class, "article-header")]/p/text()',
                  'elements_to_remove_xpaths': ['//style', '//script'],
                  'content_xpath': '//section[@class="entry-content"]'}

        html_getter = HtmlGetter()
        url = 'http://mjbizdaily.com'
        xpaths_container = XpathsContainer(**xpaths)

        NewsScraper.__init__(self, html_getter, url, xpaths_container)

    def select_date(self, date_str):
        strs = date_str.split('|')
        return strs[0].strip() if len(strs) > 0 else ''

    def get_date_format(self):
        return 'Published %B %d, %Y'


def parse_site():
    parser = NPMJBizDaily()
    return parser.parse()


if __name__ == '__main__':
    print json.dumps(parse_site())
