# -*- coding: utf-8 -*-
import urllib, urllib2, hmac, hashlib, base64, urlparse
from datetime import datetime

from google.appengine.api import memcache
import logging


class ProductAdvertising:

  def __init__(self, conf):
    self.conf = conf
    hoge = "naoki"
    
    
  def current_number():
    result = 0
    currentNumber = memcache.get("currentNumber")
    if currentNumber is not None:
      # result = currentNumber.serial_number
      result = currentNumber
      logging.info("### get currentNumberl from Memcache!")
    else:
      query = Adminkun.all()
      lang = 'ja'
      query.filter('lang =', lang)
      query.order('-serial_number')
      data = query.get()
      if data is not None:
        result = int(data.serial_number)
        if not memcache.add("currentNumber", result, 60 * 60 * 12):
          logging.error("*** Memcache set failed for currentNumber.")
        else:
          logging.info("### Set new currentNumber to Memcache.")

    logging.info(u"### Current stored number is %s.", result)
    # json_str = self.to_json({'current_number': result})
    # self.render(json = json_str)
    return result
    pass
 