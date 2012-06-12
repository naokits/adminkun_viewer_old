# -*- coding: utf-8 -*-
require 'rubygems'
require 'nokogiri'
require "open-uri"
require 'kconv'
require 'pp'
require 'adminkun'

class ParseAdminkun
  attr_accessor :dataArray
  # attr_accessor :obj_array
  attr_accessor :recent, :backnumber
  attr_accessor :counter

  def initialize #(args)
    self.dataArray = Array.new
    self.recent = nil
    self.backnumber = nil
    self.counter = 0
  end
  
  ##############################################################################
  ##############################################################################
  public
  def get_adminkun_objects
    self.get_xpath_documents
    objarray1 = self.adminkun_parse(self.backnumber)
    objarray2 = self.adminkun_parse(self.recent)
    # p objarray2[0]
    objarray1 << objarray2[0]
    return objarray1
  end
  
  ##############################################################################
  ##############################################################################
  protected
  def get_xpath_documents
    # 本番時の環境
    url = "http://www.atmarkit.co.jp/fwin2k/itpropower/admin-kun/index/"
    doc = Nokogiri.HTML(open(url), url, "sjis")

    # ローカル環境
    # url = "http://nkts.local/adminkun.html"
    # doc = Nokogiri.HTML(open(url), url, "utf8")

    xpath_query = "//body/div[@id='wrap']/div[@id='main']/div[@id='centercol']/table[@width='100%']";

    # 対象の検索（NodeSetオブジェクトを返す）
    objsets = doc.xpath(xpath_query)
    puts "取得したノードの数: #{objsets.size}"

    self.recent = objsets[0] # 最新を含めた３件の最新記事
    english_edition = objsets[1] # Mr.Admin(English)のインデックスへのリンク
    self.backnumber = objsets[2] # バックナンバー (newnumber - 1)
    # p backnumber.size
    # pp objsets[0]                # => 最初のタグ(Elementオブジェクト)
    # pp objsets[0]["table"]       # => 最初のタグのclass名(String)
    # pp objsets[0].xpath(".//a")  # => さらにその中のaタグを探す(NodeSetオブジェクト)
    return objsets
  end
  
  ################################################################################  
  ################################################################################
  protected
  def adminkun_parse(xpath_elements)
    index_overviews = Array.new
    index_image_urls = Array.new
    body_urls = Array.new
    titles = Array.new
    
    xpath_elements.children.each do |node|
      node.xpath(".//table").each do |i|
        index_overviews << i.text.strip
      end

      node.xpath(".//a").each do |i|
        body_urls << i["href"]
        titles << i.text
      end

      node.xpath(".//img[@src]").each do |i|
        if i['src'] != "admin-new.gif" && i['src'] != "admin-bn.gif"
          index_image_urls << i['src']
        end
      end
    end
    
    # push adminkun object to Array
    base_url = "http://www.atmarkit.co.jp"
    obj_array = Array.new
    
    index_image_urls.size.times do |i|
      adminkun = Adminkun.new
      self.counter = self.counter + 1
      adminkun.serial_number = self.counter.to_i
      adminkun.index_title = titles[i]
      adminkun.index_image_url = base_url + index_image_urls[i]
      adminkun.body_url = base_url + body_urls[i]
      adminkun.index_overview = index_overviews[i].split(titles[i])[1]
      obj_array << adminkun
    end
    return obj_array
  end
end


################################################################################  

# for test and debug
# p = Parse.new
# arry = p.get_adminkun_objects
# p "Array size: #{arry.size}"
# arry.each do |i|
#   # pp i
#   # puts "-------"
# end
