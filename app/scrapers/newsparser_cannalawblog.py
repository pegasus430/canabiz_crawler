from newsscraper import NewsScraper, HtmlGetter, XpathsContainer
import json

class NPCannaLawBlog(NewsScraper):
    def __init__(self):
        xpaths = {'news_xpath': '//article',
                  'title_xpath': './/h1/a/text()',
                  'url_xpath': './/h1/a/@href',
                  'image_xpath': './/article/div//img/@src',
                  'date_xpath': '//header//time/@datetime',
                  'elements_to_remove_xpaths': ['//script', '//style'],
                  'content_xpath': '//article/div'}

        html_getter = HtmlGetter()
        url = 'http://www.cannalawblog.com'
        xpaths_container = XpathsContainer(**xpaths)

        NewsScraper.__init__(self, html_getter, url, xpaths_container)



def parse_site():
    parser = NPCannaLawBlog()
    return parser.parse()

if __name__ == '__main__':
    print json.dumps(parse_site())
