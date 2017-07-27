import requests
from lxml import html
import json


class DispensaryInfoExtractor():

    def getHtmlDocumentFrom(self, url):
        response = requests.get(url)
        htmlDocument = html.fromstring(response.content)
        return htmlDocument

    def getAboutInfo(self, htmlDocument):
        return self.getFirstItemText(htmlDocument, "//div[@class='store-about']")

    def getFirstItemText(self, htmlDocument, xpath):
        element = htmlDocument.xpath(xpath + "/text()")
        if element and len(element) > 0:
            return element[0].strip()
        return ""

    def getMenuItemPriceInfo(self, element):
        result = {}
        if len(element) < 1:
            return result
        pricesData = element[0].xpath("./div")
        for priceData in pricesData:
            result[self.getFirstItemText(
                priceData, "(./span)[3]")] = self.getFirstItemText(priceData, "(./span)[1]")
        return result

    def getMenuItemRatings(self, htmlDocument):
        elementText = self.getFirstItemText(
            htmlDocument, "//h4[contains(@class,'copy--sm')]/span[2]")
        if elementText:
            arr = elementText.split(' ')
            if len(arr) > 0:
                return arr[0].replace('(', '')
        return ""

    def extractPercent(self, text):
        if len(text) > 0:
            arr = text[0].split(':')
            if len(arr) > 1:
                nr = float(arr[1].replace('%', ''))
                return str(round(nr, 2)) + '%'
        return ""

    def getHistogramValues(self, element):
        subElements = element.xpath(
            "./div[contains(@class,'histogram-item-wrapper')]")
        result = {}
        for subElm in subElements:
            result[self.getFirstItemText(subElm, "./div[contains(@class,'label')]")] = self.extractPercent(
                subElm.xpath(".//div[contains(@class,'attr-bar')]/@style"))
        return result

    def getMenuStatistics(self, htmlDocument):
        attributeElements = htmlDocument.xpath(
            "//div[@class='divider']//ul/li/a/text()")
        histogramElements = htmlDocument.xpath(
            "//div[@class='m-strain-attributes']/div[position()>1]")
        result = {}
        if len(attributeElements) == len(histogramElements):
            for pair in zip(attributeElements, histogramElements):
                result[pair[0]] = self.getHistogramValues(pair[1])
        return result

    def stringify_children(self, node):
        from lxml import etree
        return ''.join(etree.XPath(".//text()")(node)).strip()

    def getMoreMenuDetails(self, moreDetailsUrl):
        htmlDocument = self.getHtmlDocumentFrom(moreDetailsUrl)
        result = {}
        result['ratings'] = self.getMenuItemRatings(htmlDocument)
        result['url'] = 'https://www.leafly.com' + \
            htmlDocument.xpath("//div[@class='copy--right']/a/@href")[0]
        result['about'] = self.stringify_children(htmlDocument.xpath(
            ".//div[contains(@class,'divider top strain__quick-view--padding')]/div[1]")[0])
        return result

    def getMenuItemInfo(self, htmlDocument):
        itemResult = {}
        itemResult['name'] = self.getFirstItemText(
            htmlDocument, ".//h3[contains(@class,'padding-rowItem')]")
        itemResult['short-description'] = self.getFirstItemText(
            htmlDocument, ".//div[contains(@class,'description')]")
        itemResult['rating'] = self.getFirstItemText(
            htmlDocument, ".//div[@class='score']")
        itemResult['prices'] = self.getMenuItemPriceInfo(
            htmlDocument.xpath(".//div[contains(@class,'item-heading--prices')]"))
        moreInfoUrl = htmlDocument.xpath("./@item-body-resource")[0]
        # itemResult['more-info'] = {} if "?store" in moreInfoUrl else self.getMoreMenuDetails(
        #     "https://www.leafly.com" + moreInfoUrl)

        return itemResult

    def getMenuInfo(self, htmlDocument):
        categories = htmlDocument.xpath(
            "//div[contains(@class,'accordion--main-group')]")
        categoriesResult = []
        for categoryData in categories:
            categoryResult = {}
            categoryResult['name'] = self.getFirstItemText(
                categoryData, ".//h4[contains(@class,'panel-title')]//span")
            itemsData = categoryData.xpath(
                ".//div[contains(@class,'menu__item m-accordion')]")
            itemsResult = []
            for itemData in itemsData:
                itemsResult.append(self.getMenuItemInfo(itemData))
                categoryResult["items"] = itemsResult
            categoriesResult.append(categoryResult)

        return categoriesResult

    def getInfo(self, dispensaryUrl):
        # print "parsing : " + dispensaryUrl
        result = {}
        result['about-dispensary'] = self.getAboutInfo(
            self.getHtmlDocumentFrom(dispensaryUrl))
        result['menu'] = self.getMenuInfo(
            self.getHtmlDocumentFrom(dispensaryUrl + "/menu"))
        return result


if __name__ == "__main__":
    extractor = DispensaryInfoExtractor()

    r = extractor.getInfo(
        "https://www.leafly.com/dispensary-info/timely-holistic-care")
    with open("disp_result.json", 'w') as outfile:
        json.dump(r, outfile)
