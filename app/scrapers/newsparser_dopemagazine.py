from newsscraper import NewsScraper, HtmlGetter, XpathsContainer
import json

class NPDopeMagazine(NewsScraper):
    def __init__(self):
        xpaths = {'news_xpath': '//article',
                  'title_xpath': './/h5[@class="entry-title"]/a/text()',
                  'url_xpath': './/h5[@class="entry-title"]/a/@href',
                  'image_xpath': './/meta[@property="og:image"]/@content',
                  'date_xpath': '//time[@class = "date published time"]/@datetime',
                  'elements_to_remove_xpaths': ['//script', '//style', '//div[contains(@class, "essb_links")]'],
                  'content_xpath': '//div[contains(@class,"post-content entry-content")]'}

        html_getter = HtmlGetter()
        url = 'http://www.dopemagazine.com/category/news/'
        xpaths_container = XpathsContainer(**xpaths)

        NewsScraper.__init__(self, html_getter, url, xpaths_container)


def parse_site():
    parser = NPDopeMagazine()
    return parser.parse()


if __name__ == '__main__':
    result = parse_site()
    print json.dumps(result)
