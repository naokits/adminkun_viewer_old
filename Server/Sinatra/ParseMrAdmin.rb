# -*- coding: utf-8 -*-
require 'rubygems'
require 'nokogiri'
require "open-uri"
require 'kconv'
require 'pp'
require 'adminkun'

class ParseMrAdmin
  attr_accessor :description
  attr_accessor :recent, :backnumber
  attr_accessor :counter
  
  def initialize #(args)
    self.description = ""
    self.recent = ""
    self.backnumber = ""
    self.counter = 0
  end
  

  ################################################################################  
  ################################################################################  
  public
  def get_mradmin_objects
    objsets = self.get_xpath_documents
    
    self.description = objsets[0] # 
    
    backnumber_array = self.mradmin_parse(objsets)
    current_episode = self.mradmin_parse2(objsets[1])
    current_episode.each do |i|
      backnumber_array << i
    end

    puts "Backnumber array size => #{backnumber_array.size}"
    backnumber_array.each do |nk|
      p nk.serial_number
      p nk.index_title
      p nk.index_image_url
    end
    return backnumber_array
  end
  ##############################################################################
  ##############################################################################
  protected
  def get_xpath_documents
    # ローカル環境
    url = "http://nkts.local/mradmin2.html"
    doc = Nokogiri.HTML(open(url))
    xpath_query = "//body/div[@id='wrap']/div[@id='main']/div[@id='centercol']/table";
    # 対象の検索（NodeSetオブジェクトを返す）
    objsets = doc.xpath(xpath_query)
    puts "取得したノードの数: #{objsets.size}"
    return objsets
  end
  
  ##############################################################################
  ##############################################################################
  protected
  def mradmin_parse(object_sets)
    index_overviews = Array.new
    index_image_urls = Array.new
    body_urls = Array.new
    titles = Array.new

    (object_sets.size - 1).times do |t|
      # puts "-- #{t}"
      if t < 2
        # 0: description
        # 1: new episode
      else
        # insert dummy data
        if t == 32
          titles << ""
          body_urls << ""
          index_image_urls << ""
        end
        object_sets[t].children.each do |node|
          node.xpath(".//td/b/a").each do |i|
            titles << i.text.strip
            body_urls << i["href"] # body_url
          end

          node.xpath(".//img[@src]").each do |i|
            index_image_urls << i['src']
          end
        end
      end
    end
    
    # push adminkun object to Array
    base_url = "http://www.atmarkit.co.jp"
    obj_array = Array.new
    
    index_image_urls.size.times do |i|
      mradmin = MrAdmin.new
      self.counter = self.counter + 1
#puts "--- #{i}"
      mradmin.serial_number = self.counter.to_i
      mradmin.index_title = titles[i]
      mradmin.index_image_url = base_url + index_image_urls[i]
      mradmin.body_url = base_url + body_urls[i]
      # mradmin.index_overview = index_overviews[i].split(titles[i])[1]
      obj_array << mradmin
    end
    return obj_array
  end


  protected
  def mradmin_parse2(object_sets)
    index_image_urls = Array.new
    body_urls = Array.new
    titles = Array.new
    
    object_sets.children.each do |node|
      node.xpath(".//td/b/a").each do |i|
        titles << i.text.strip
        body_urls << i["href"]
      end
      node.xpath(".//img[@src][@width='40']").each do |i|
        index_image_urls << i['src']
      end
    end

    # push adminkun object to Array
    base_url = "http://www.atmarkit.co.jp"
    base_url = "http://localhost:3000"
    obj_array = Array.new
    
    index_image_urls.size.times do |i|
      mradmin = MrAdmin.new
      self.counter = self.counter + 1
      mradmin.serial_number = self.counter.to_i
      mradmin.index_title = titles[i]
      mradmin.index_image_url = base_url + index_image_urls[i]
      mradmin.body_url = base_url + body_urls[i]
      # mradmin.index_overview = index_overviews[i].split(titles[i])[1]
      obj_array << mradmin
    end
    return obj_array
  end
end

# parse = ParseMrAdmin.new
# parse.get_mradmin_objects