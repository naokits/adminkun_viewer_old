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
  'site_url'     : SITE_URL,
  'index_ja_url' : SITE_URL + '/fwin2k/itpropower/admin-kun/index/index.html',
  'index_en_url' : SITE_URL + '/fwin2k/itpropower/admin-kun-en/index/index.html',
  'parse_url'    : SITE_URL + '/fwin2k/itpropower/admin-kun/index/',
  'base_url'     : SITE_URL + '/fwin2k/itpropower',
  'ja_uri'    : 'admin-kun',
  'en_uri'    : 'admin-kun-en'
}


class SupportController(BaseController):
  """
  アドミンくんビューワのサポートサイト
  """
  
  def index(self):
    """
    The default method
    related to templates/support/index.html
    """
    self.title = "アドミンくんビューワサポートサイト：トップ"
    pass

  def whatsnew(self):
    """
    最新情報
    """
    self.title = "アドミンくんビューワサポートサイト：最新情報"
    pass
  
  def about(self):
    """
    アドミンくんビューワについて
    """
    self.title = "アドミンくんビューワサポートサイト：アドミンくんビューワについて"
    pass
  
  def schedule(self):
    """
    今後の予定
    """
    self.title = "アドミンくんビューワサポートサイト：今後の予定"
    pass
  
  def screenshots(self):
    """
    スクリーンショット
    """
    self.title = "アドミンくんビューワサポートサイト：スクリーンショット"
    pass
  
  def about_author(self):
    """
    作者について
    """
    self.title = "アドミンくんビューワサポートサイト：作者について"
    pass











