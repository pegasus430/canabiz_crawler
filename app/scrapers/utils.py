from lxml import html

class HtmlUtils:
    @staticmethod
    def get_elements(html_document, xpath):
        try:
            return html_document.xpath(xpath)
        except Exception as e:
            return []

    @staticmethod
    def get_element_value(element, xpath):
        elements = HtmlUtils.get_elements(element, xpath)
        if elements and len(elements):
            return elements[0]
        return ''

    @staticmethod
    def remove_elements(html_document, xpaths):
        for xpath in xpaths:
            for e in HtmlUtils.get_elements(html_document, xpath):
                e.getparent().remove(e)

    @staticmethod
    def get_text_html(html_document, xpath):
        elements = HtmlUtils.get_elements(html_document, xpath)
        if elements and len(elements) > 0:
            body_html_raw = elements[0]
            return html.tostring(body_html_raw)
        return ''

    @staticmethod
    def get_text_plain(html_document, xpath):
        elements = HtmlUtils.get_elements(html_document, xpath)
        if elements and len(elements) > 0:
            body_html_raw = elements[0]
            return body_html_raw.text_content().strip()
        return ''
