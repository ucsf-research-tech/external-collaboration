#!/usr/bin/env python

from config import config
import pycurl, cStringIO

buf = cStringIO.StringIO()

fields = {
    'token': config['api_token'],
    'content': 'report',
    'format': 'json',
    'report_id': '1'
}

ch = pycurl.Curl()
ch.setopt(ch.URL, config['api_url'])
ch.setopt(ch.HTTPPOST, fields.items())
ch.setopt(ch.WRITEFUNCTION, buf.write)
ch.perform()
ch.close()

print buf.getvalue()
buf.close()
