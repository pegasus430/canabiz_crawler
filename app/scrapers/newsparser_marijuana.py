from newsscraper import NewsScraper, HtmlGetter, XpathsContainer
import json

class NPMarijuana(NewsScraper):
    def __init__(self):
        xpaths = {'news_xpath': '//article',
                  'title_xpath': './/h2/a/text()',
                  'url_xpath': './/h2/a/@href',
                  'image_xpath': './/img[@class="attachment-main-slider size-main-slider wp-post-image"]/@src',
                  'date_xpath': '//span[@class="posted-on"]/span/time/@datetime',
                  'elements_to_remove_xpaths': ['//style','//script','/div[@class="watch-action"]','//div[@class="sharedaddy sd-sharing-enabled"]'],
                  'content_xpath': '//div[@class="post-content description"]'}

        html_getter = HtmlGetter()
        url = 'https://www.marijuana.com/news/'
        xpaths_container = XpathsContainer(**xpaths)

        NewsScraper.__init__(self, html_getter, url, xpaths_container)

def parse_site():
    parser = NPMarijuana()
    return parser.parse()

if __name__ == '__main__':
    print json.dumps(parse_site())
