# -*- coding: UTF-8 -*-
import logging

import os
import sys
from gaeo.controller import BaseController

# import the model class
from model.adminkun import Adminkun

from BeautifulSoup import BeautifulSoup
#for arch in os.listdir("eggs"):
#  sys.path.insert(0, os.path.join("eggs", arch))
#  pass
from html5lib import HTMLParser
from html5lib import treebuilders
# from BSXPath import BSXPathEvaluator,XPathResult
# from BSXPath import ExtDict,typeof,toString

from google.appengine.api import memcache
from google.appengine.api import urlfetch

# from lib.nao import ProductAdvertising

# 次の変数をmemcacheとして使用
# cacheAdminkun
# currentNumber

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


class WelcomeController(BaseController):
  """
  The default Controller
  You could change the default route in main.py
  """
  
  def index(self):
    """
    The default method
    related to templates/welcome/index.html
    """
    self.redirect('/support')
    pass


  def fetch_adminkun_from_atmarkit(self):
    """
      アドミンくんのインデックス情報を@ITから取得する
    """
    lang = 'ja'
    self.fetch(lang)


  def fetch_mradmin_from_atmarkit(self):
    """
      Mr.Adminのインデックス情報を@ITから取得する
    """
    lang = 'en'
    self.fetch(lang)


  def fetch(self, lang):
    """
      指定された言語のインデックス情報を10件取得する
    """
    if lang == 'ja':
      cacheAdminkun = memcache.get("cacheAdminkun")
      if cacheAdminkun is not None:
        data = []
        data2 = []
        data = eval(cacheAdminkun)  
        logging.info("### get data successful from Memcache!")
        status_code = "200"
      else:
        result = urlfetch.fetch(Config['index_ja_url'])
        logging.info("*** url is %s" % Config['index_ja_url'])
        # print result.content
        
        html = unicode(result.content,'cp932') # shift-jisではエラーが発生する
        data = self.parse_adminkun(html, 'backbox')
        data2 = self.parse_adminkun(html, 'newbox')
        data.append(data2[0]) # 新着の先頭が最新
        status_code = result.status_code
        if not memcache.add("cacheAdminkun", '%s'%data, 60 * 60 * 6): # 24時間おき
#        if not memcache.add("cacheAdminkun", '%s'%data, 60):

          logging.error("*** Memcache set failed.")
          # return cacheAdminkun
        else:
          logging.info("### Set new data to Memcache.")
    else: # 英語版（未実装）
      result = urlfetch.fetch(Config['index_en_url'])
      html = unicode(result.content,'shift-jis')
      data = self.parse_adminkun(html, 'backbox')
      data.append(self.parse_adminkun(html, 'newbox'))

    # query = Adminkun.all()
    # query.filter('lang =', lang)
    # query.order('-serial_number')
    # current_number = 0
    # if query.get() is not None:
    #   current_number = int(query.get().serial_number)
    current_number = self.stored_number(lang)
    addedNumber = 0
    for i in data:
      if int(i['serial_number']) > current_number:
        adminkun = Adminkun (
          serial_number   = int(i['serial_number']),
          read_flag       = False,
          index_title     = i['index_title'].strip(),
          index_overview  = i['index_overview'].strip(),
          index_image_url = u'%s%s' % (SITE_URL, i['index_image_url']),
          body_url        = u'%s%s' % (SITE_URL, i['body_url']),
          body_image_url  = self.make_body_image_url(i['serial_number'], lang),
          lang = lang
        )
        adminkun.put() # データの保存
        addedNumber = addedNumber + 1
        # TODO: ここにpush通知の処理を入れる
        if addedNumber == 5: # 5件取得したら終了
          break;
    memcache.delete('currentNumber')
#    memcache.delete('cacheAdminkun')
    result = self.to_json({'added_comic': addedNumber, 'status_code' : status_code})
    self.render(json = result)
    pass
  

  def parse_adminkun(self, html, keyword_tag):
    """
    日本語
    HTMLをパースし、全ての連載記事を取得し辞書配列として返す。
    html: パース対象のhtmlコンテンツ
    keyword_tag: 新着かバックナンバーかを指定するタグ名
    """
    logging.info(u"### キーワード：%s.", keyword_tag)

    strip_strings = ["<br>", "<br />", "<b>", "</b>"]
    for s in strip_strings:
      html = html.replace(s, "")


    try:
      # まずBeautifulSoupでパースして、
      soup = BeautifulSoup(html)
    except:
      # エラーが発生したらhtml5libでパースする
      print '### Exception: Could not parse by BeautifulSoup!!'
      parser = HTMLParser(tree = treebuilders.getTreeBuilder("beautifulsoup"))
      soup = parser.parse(html)

    data = []
    hash = {}
    for node in soup.findAll('div', {'class': keyword_tag}):
      for tag in node('table', {'width': '100%', 'cellpadding': '3', 'border': '0'}):
        body_url = tag.a['href']

        e = body_url.split('/')
        serial_number = e[4]

        index_title = u'%s' % (tag.a.next)

        if int(serial_number) <= 73:
          index_overview = tag.font.next
        else:
          index_overview = tag('font')[1].next

        index_image_url = tag.img['src']

        hash = {
          "serial_number": serial_number,
          "index_title": index_title,
          "index_overview": index_overview,
          "index_image_url": index_image_url,
          "body_url": body_url
        }
        data.append(hash)
        if keyword_tag == 'newbox':
          break
    # data.reverse()
    return data


  def parse_mradmin(self, html):
    """
    英語版
    """
    data = []
    hash = {}
    return data
  
  
  def make_body_image_url(self, serial_number, lang):
    """
    コミック本文に使用されている画像のURLを生成して返す
    """
    formated_number = u"%03d" % int(serial_number)
    if lang == 'ja':
      url = u"%s/%s" % (Config['base_url'], Config['ja_uri'])
      if int(serial_number) == 1:
        comic_image = u'%s/%s/admin%sl.gif' % (url, formated_number, formated_number)
      else:
        comic_image = u'%s/%s/admin%s_l.gif' % (url, formated_number, formated_number)
    elif lang == 'en':
      url = u'%s/%s' % Config['base_url'], Config['en_uri']
      comic_image = u'%s/%s/adminen%s_l.gif' % (url, formated_number, formated_number)
    else:
      comic_image = ""
    return comic_image
      

  def stored_number(self, lang):
    """
    use for local
    """
    result = 0
    currentNumber = memcache.get("currentNumber")
    if currentNumber is not None:
      # result = currentNumber.serial_number
      result = currentNumber
      logging.info("### get currentNumberl from Memcache!")
    else:
      query = Adminkun.all()
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
    return result
    pass


  def current_number(self):
    """
    保存されている最新の連載番号をJSONで返す
        errorCode:00 success
              999 引数の数が不正
              999 言語パラメータが存在しない
              999 言語パラメータの値が存在しない
              999 言語パラメータの値が不正（ja or en）
    """
    result = ""
    if len(self.params) < 2+1: # action, controller, lang
      statusCode = '999'
      result = self.to_json({'current_number' : statusCode})
      self.render(json = result)
    elif self.params.has_key('lang') is False:
      statusCode = '999' # no lang parameter
      result = self.to_json({'current_number' : statusCode})
      self.render(json = result)
    elif len(self.params['lang']) == 0:
      statusCode = '999' # no lang
      result = self.to_json({'current_number' : statusCode})
      self.render(json = result)
    elif self.params['lang'] != 'ja' and self.params['lang'] != 'en':
      statusCode = '999' # out of param. (ja or en only)
      result = self.to_json({'current_number' : statusCode})
      self.render(json = result)
    else:
      result = self.stored_number(self.params['lang'])
      logging.info(u"### Current stored number is %s.", result)
      json_str = self.to_json({'current_number': result})
      self.render(json = json_str)
    pass
    

  def get(self):
    """
    呼び出し方：?serial_number=1&lang=ja
    指定した連載番号記事のインデックス情報をデータストアから取得し、JSON形式で返す。
    errorCode:000 success
              011 引数の数が不正
              012 引数が不正
              013 連載番号が指定されていない
              014 言語パラメータが存在しない
              015 言語パラメータの値が存在しない
              016 言語パラメータの値が不正（ja or en）
    """
    statusCode = '000'
    result = ""
    resultArray = []
    if len(self.params) < 2+2: # action, controller, serial_number, lang
      statusCode = '011'
      result = self.to_json({'status_code' : statusCode})
    elif self.params.has_key('serial_number') is False:
      statusCode = '012' # no parameter
      result = self.to_json({'status_code' : statusCode})
    elif len(self.params['serial_number']) == 0:
      statusCode = '013' # no number
      result = self.to_json({'status_code' : statusCode})
    elif self.params.has_key('lang') is False:
      statusCode = '014' # no lang parameter
      result = self.to_json({'status_code' : statusCode})
    elif len(self.params['lang']) == 0:
      statusCode = '015' # no lang
      result = self.to_json({'status_code' : statusCode})
    elif self.params['lang'] != 'ja' and self.params['lang'] != 'en':
      statusCode = '016' # out of param. (ja or en only)
      result = self.to_json({'status_code' : statusCode})
    else:
      query = Adminkun.all()
      query.filter('lang =', self.params['lang'])
      # current_number = query.count()
      current_number = self.stored_number(self.params['lang'])
      if int(self.params['serial_number']) > current_number:
        statusCode = '17' # 登録されているデータの範囲を超えた
        result = self.to_json({'status_code' : statusCode})
        self.render(json = result)
        return
    
      number = self.params['serial_number']
      lang = self.params['lang']
      query = Adminkun.all()
      query.filter('serial_number =', int(number))
      query.filter('lang =', lang)
      query.order('-serial_number')

      data = query.get()
      result = self.to_json({'serial_number'  : data.serial_number,
                            'index_title'     : data.index_title,
                            'index_overview'  : data.index_overview,
                            'index_image_url' : data.index_image_url,
                            'body_url'        : data.body_url,
                            'body_image_url'  : data.body_image_url,
                            'status_code'     : statusCode,
                            'lang'            : lang
                            })

    self.render(json = result)
    pass


