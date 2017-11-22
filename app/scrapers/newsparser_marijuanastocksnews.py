from newsscraper import NewsScraper, HtmlGetter, XpathsContainer
import json

class NPMarijuanaStocksNews(NewsScraper):
    def __init__(self):
        xpaths = {'news_xpath': '//div[@class="td-block-span6"]',
                  'title_xpath': './/h3/a/text()',
                  'url_xpath': './/h3/a/@href',
                  'image_xpath': './/meta[@property="og:image"]/@content',
                  'date_xpath': './/header//time/@datetime',
                  'elements_to_remove_xpaths': ['//script', '//style', '//div[contains(@class, "mantis__recommended__wordpress")]',
                                '//div[contains(@class, "addtoany_share_save_container")]'],
                  'content_xpath': '//div[@class= "td-post-content"]'}

        html_getter = HtmlGetter()
        url = 'http://marijuanastocks.com/category/marijuana-stocks-news/'
        xpaths_container = XpathsContainer(**xpaths)

        NewsScraper.__init__(self, html_getter, url, xpaths_container)


def parse_site():
    parser = NPMarijuanaStocksNews()
    return parser.parse()


if __name__ == '__main__':
    print json.dumps(parse_site())
