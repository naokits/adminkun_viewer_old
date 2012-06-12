# -*- coding: UTF-8 -*-
import logging
import os
import sys
from gaeo.controller import BaseController
from google.appengine.api import urlfetch
from google.appengine.api import memcache

#for arch in os.listdir("eggs"):
#  sys.path.insert(0, os.path.join("eggs", arch))
#  pass


SITE_URL = 'http://www.atmarkit.co.jp'
Config = {
  'header_title' : 'Mr.Admin Support Site：',
  'ja_uri'    : 'admin-kun',
  'en_uri'    : 'admin-kun-en'
}


class Support_enController(BaseController):
  """
  アドミンくんビューワのサポートサイト
  """
  
  def index(self):
    """
    The default method
    related to templates/support/index.html
    """
    self.title = Config['header_title'] + "Top"
    pass

  def whatsnew(self):
    """
    最新情報
    """
    self.title = Config['header_title'] + "What's new"
    pass
  
  def about(self):
    """
    アドミンくんビューワについて
    """
    self.title = Config['header_title'] + "About this app"
    pass
  
  def schedule(self):
    """
    今後の予定
    """
    self.title = Config['header_title'] + "Schedule"
    pass
  
  def screenshots(self):
    """
    スクリーンショット
    """
    self.title = Config['header_title'] + "Screenshots"
    pass
  
  def about_author(self):
    """
    作者について
    """
    self.title = Config['header_title'] + "About me"
    pass











