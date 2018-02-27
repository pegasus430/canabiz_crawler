import json

def loadJson(str_json):
    try:
        return json.loads(str_json)
    except Exception:
        return {}
    
def try_get_list(obj, *args):
    objCopy = obj
    for a in args:
        if a in objCopy:
            objCopy = objCopy[a]
        else:
            return []
    return [objCopy] if objCopy else []

def fill_obj(obj_to_fill, obj_source, paths):
    for key, path in paths.items():
        lst = try_get_list(obj_source, path)
        obj_to_fill[key]  = lst[0] if len(lst) > 0 else None