import requests

class HttpClient(object):
    def get(self, url, **kwargs):
        response = requests.get(url, **kwargs)

        return self._response(response)

    def post(self, url, **kwargs):
        response = requests.post(url, **kwargs)

        return self._response(response)

    def _response(self, r):
        if r.status_code == 200:
            return HttpClientResponse(True, r.content)
        return HttpClientResponse()


class HttpClientResponse(object):
    def __init__(self, success = False, content = ''):
        self.success = success
        self.content = content