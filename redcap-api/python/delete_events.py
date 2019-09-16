#!/usr/bin/env python

from config import config
import pycurl, cStringIO, json

buf = cStringIO.StringIO()

fields = {
    'token': config['api_token'],
    'content': 'event',
    'action': 'delete',
    'format': 'json',
    'events[0]': 'event_1_arm_1'
}

ch = pycurl.Curl()
ch.setopt(ch.URL, config['api_url'])
ch.setopt(ch.HTTPPOST, fields.items())
ch.setopt(ch.WRITEFUNCTION, buf.write)
ch.perform()
ch.close()

print buf.getvalue()
buf.close()
