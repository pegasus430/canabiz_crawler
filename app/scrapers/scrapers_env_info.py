import sys
import requests
import urllib3

print 'the python version is: {0}.{1}.{2}'.format(*sys.version_info)
print 'the requests version is: {0}'.format(requests.__version__)
print 'the urllib3 version is: {0}'.format(urllib3.__version__)