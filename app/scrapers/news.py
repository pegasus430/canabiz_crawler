import json

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
        return {'title': self.title, 'url': self.url, 
        'image_url': self.image_url, 'date': self.date.strftime('%Y-%m-%d'), 
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