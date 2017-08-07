import json

def extract_str_from_json_obj(jsonObj, path):
    if not jsonObj or not path:
        return ''
    if isinstance(path, str):
        return jsonObj[path] if path in jsonObj else ''
    if isinstance(path, list) and len(path) > 0:
        key = path[0]
        childJsonObj = jsonObj[key] if key in jsonObj else ''
        if len(path) == 1:
            return childJsonObj if not isinstance(childJsonObj, dict) else ''
        else:
            return extract_str_from_json_obj(childJsonObj, path[1:])
    return ''


def extract_obj_from_json_obj(jsonObj, path):
    if not jsonObj or not path:
        return {}
    if isinstance(path, str):
        return jsonObj[path] if path in jsonObj else {}
    if isinstance(path, list) and len(path) > 0:
        key = path[0]
        childJsonObj = jsonObj[key] if key in jsonObj else {}
        if len(path) == 1:
            return childJsonObj
        else:
            return extract_obj_from_json_obj(childJsonObj, path[1:])
    return {}


def extract_text_from_html(htmlDocument, xpath):
    return extract_str_from_html(htmlDocument, xpath+'/text()')


def extract_atr_from_html(htmlDocument, xpath, atrName):
    return extract_str_from_html(htmlDocument, '{0}/@{1}'.format(xpath, atrName))


def extract_elements_from_html(htmlDocument, xpath):
    return htmlDocument.xpath(xpath)


def extract_str_from_html(htmlDocument, xpath):
    if htmlDocument is None or not xpath:
        return ''
    elements = htmlDocument.xpath(xpath)
    return elements[0].strip() if len(elements) > 0 else ''


def loads_json(strData):
    try:
        return json.loads(strData)
    except:
        return {}



def writeToFile(fileName, data):
    with open(fileName, 'w') as outfile:
        json.dump(data, outfile)
