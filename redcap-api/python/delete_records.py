#!/usr/bin/env python
from config import config
import pycurl, cStringIO, json

buf = cStringIO.StringIO()

data = {
    'token': config['api_token'],
    'action': 'delete',
    'content': 'record',
    'records[0]': '1'
}
ch = pycurl.Curl()
ch.setopt(ch.URL, config['api_url'])
ch.setopt(ch.HTTPPOST, data.items())
ch.setopt(ch.WRITEFUNCTION, buf.write)
ch.perform()
ch.close()
print buf.getvalue()
buf.close()