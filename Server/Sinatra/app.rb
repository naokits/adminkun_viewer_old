
require 'rubygems'
require 'sinatra'
require 'haml'
require 'rack'
require 'sequel'
require 'logger'
require 'json'

require 'adminkun'
require 'parse_adminkun'
require 'ParseMrAdmin'
# require 'model/menu'


################################################################################
################################################################################
# class SinatterException < Exception; end

configure :development do 
  set :dbname, 'adminkun.db' 
end 

configure :production do 
  set :dbname, 'adminkun.db' 
end 

configure do
  # set :sessions, true
  # set :environment, :no_test
  # set :public, File.dirname(__FILE__) + '/static'
  
  set :git_dirs, ["./repos/*.git"]
  set :ignored_files, ['.', '..', 'README.md']
  set :base_url, "http://nkts.local:3000"
  set :mradmin_base_url, "http://www.atmarkit.co.jp/fwin2k/itpropower"
  set :ja_uri, "admin-kun"
  set :en_uri, "admin-kun-en"
  
  set :ADMINKUN, 'adminkun'
  set :MRADMIN,  'mradmin'

  options = {:loggers => [Logger.new($stdout)]}
  DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://adminkun.db', options)
  unless DB.table_exists? "adminkun"
    DB.create_table :adminkun do
      primary_key :id
      fixnum :serial_number
      string :index_title
      string :index_overview
      string :index_image_url
      string :body_url
      string :body_image_url
    end
  end

  unless DB.table_exists? "mradmin"
    DB.create_table :mradmin do
      primary_key :id
      fixnum :serial_number
      string :index_title
      # string :index_overview
      string :index_image_url
      string :body_url
      string :body_image_url
    end
  end
  

  # unless DB.table_exists? "subscribers"
  #   DB.create_table :subscribers do
  #     primary_key :id
  #     foreign_key :channel_id
  #     varchar :url, :size => 128
  #   end
  # end
end # end of configure

################################################################################
# HELPER Functions
################################################################################
helpers do
  # include Rack::Urils
  # alias_method :h, :escape_html
  # alias_method :u, :escape

  # Rails tekina partial wo teigi
  def partial(page, options={})
    haml page, options.merge!(:layout => false)
  end

  def gen_id
    base = rand(100000000).to_s
    salt = Time.now.to_s
    Zlib.crc32(base + salt).to_s(36)
  end
  
  #################################################################
  #################################################################
  def fetch_mradmin
    p = ParseMrAdmin.new
    @object_array = p.get_mradmin_objects

    @table_size = DB[:mradmin].count
    dataset = DB[:mradmin]
    last_row = dataset.order(:serial_number).last
    if last_row.nil?
      @lastno = 0
    else
      @lastno = last_row[:serial_number]
    end
    @message = ""
    unless @object_array.size == @lastno.to_i
      @message = "Found new #{@object_array.size - @lastno.to_i} comic data"
      # add data to db that no registerd comic info
      @object_array.each do |i|
        if i.serial_number.to_i > @lastno.to_i
          if i.serial_number.to_i == 31 then next end
          DB[:mradmin] << { :index_title => i.index_title, 
                            :serial_number => i.serial_number,
                          # :index_overview => i.index_overview, 
                            :index_image_url => i.index_image_url,
                            :body_url => i.body_url}
        end
      end
    end
    # { :id => id.to_s }.to_json
    # haml :getcomic, :layout => :layout1
  end


  #################################################################
  #################################################################
  def fetch_adminkun
    # id = gen_id
    p = ParseAdminkun.new
    @object_array = p.get_adminkun_objects

    @table_size = DB[:adminkun].count
    dataset = DB[:adminkun]
    last_row = dataset.order(:serial_number).last
    if last_row.nil?
      @lastno = 0
    else
      @lastno = last_row[:serial_number]
    end
    @message = ""
    unless @object_array.size == @lastno.to_i
      @message = "Found new #{@object_array.size - @lastno.to_i} comic data"
      # add data to db that no registerd comic info
      @object_array.each do |i|
        if i.serial_number.to_i > @lastno.to_i
          DB[:adminkun] << { :index_title => i.index_title, 
                             :serial_number => i.serial_number,
                             :index_overview => i.index_overview, 
                             :index_image_url => i.index_image_url,
                             :body_url => i.body_url}
        end
      end
    end
    # { :id => id.to_s }.to_json
    # haml :getcomic, :layout => :layout1
  end
  
  #################################################################
  # make url of comic image and return it.
  #################################################################
  def make_body_image_url(serial_number, group)
    formated_number = sprintf("%03d", serial_number)
    
    if group == 'adminkun'
      url = "#{Sinatra::Application.mradmin_base_url}/#{Sinatra::Application.ja_uri}" 
      if serial_number.to_i == 1
        @comic_image = "#{url}/#{formated_number}/admin#{formated_number}l.gif"
      else
        @comic_image = "#{url}/#{formated_number}/admin#{formated_number}_l.gif"
      end
    else
      url = "#{Sinatra::Application.mradmin_base_url}/#{Sinatra::Application.en_uri}" 
      @comic_image = "#{url}/#{formated_number}/adminen#{formated_number}_l.gif"
    end
    return @comic_image
  end
  
  #################################################################
  # サイトの記事数を取得して返す。
  #################################################################
  def comic_number_from_site(group)
    if group == 'adminkun'
      p = ParseAdminkun.new
      object_array = p.get_adminkun_objects
    else
      p = ParseMrAdmin.new
      object_array = p.get_mradmin_objects
    end
    return if object_array.nil?
    return object_array.size
  end
  
  #################################################################
  # 新着記事があるかチェックし、あれば新着記事数を返す。
  # サイトの記事数とDBの記事数との差分で判断する
  # group: 'adminkun' or 'mradmin'を指定する
  #################################################################
  def newly_arrived_counter_from_site(group)
    if (group == 'adminkun')
      dataset = DB[:adminkun]
    else
      dataset = DB[:mradmin]
    end
    last_row = dataset.order(:serial_number).last
    lastnumber = last_row[:serial_number].to_i
    
    result = self.comic_number_from_site(group) - lastnumber
    if result == 0
      return nil
    else
      return result
    end
  end
end # end of Helper




################################################################################
################################################################################
get '/' do
  @value = Sinatra::Application.base_url
  @value = newly_arrived_counter_from_site('adminkun')
#  @value = self.comic_number_from_site('mradmin')
  haml :index, :layout => :layout1
end

get '/hoge' do
  url = "http://nkts.local:8000/fetch"
  doc = open(url)
  p doc
  # data = JSON.parse(params[:data])
  
  
end


post'/watercoolr' do
  # data = JSON.parse(params[:data])
  puts "data is #{params[:data]}"
  # haml :watercoolr, :layout => :layout1
end

get '/init_menu' do
    Menu.create({
      :menu_id => "1".to_i,
      :menu_title => "がんばれ！アドミンくん",
      :menu_description => "アドミンくんの説明文",
      :memo => "特になし",
      :lang => "ja",
      :posted_date => Time.now,
    })

    Menu.create({
      :menu_id => "1".to_i,
      :menu_title => "Mr.Admin(Japanese)",
      :menu_description => "説明文",
      :memo => "",
      :lang => "en",
      :posted_date => Time.now,
    })
    
    Menu.create({
      :menu_id => "2".to_i,
      :menu_title => "Mr.Admin",
      :menu_description => "アドミンくんの説明文",
      :memo => "",
      :lang => "ja",
      :posted_date => Time.now,
    })

    Menu.create({
      :menu_id => "2".to_i,
      :menu_title => "Mr.Admin",
      :menu_description => "アドミンくんの説明文（英文）",
      :memo => "nothing",
      :lang => "en",
      :posted_date => Time.now,
    })

    Menu.create({
      :menu_id => "3".to_i,
      :menu_title => "設定",
      :menu_description => "設定の説明文",
      :memo => "",
      :lang => "ja",
      :posted_date => Time.now,
    })

    Menu.create({
      :menu_id => "3".to_i,
      :menu_title => "Settings",
      :menu_description => "",
      :memo => "",
      :lang => "en",
      :posted_date => Time.now,
    })
    
    
 'メニューを初期化しました'
#   haml :getcomic, :layout => :layout1
  redirect '/'
end



################################################################################
# 全てのコミック情報をサイトから取得してDBに登録し、HTML形式で返す
# 現在はあどみんくんのみ
# TODO: Mr.Admin用も用意する
################################################################################
get '/getcomic' do
  # id = gen_id
  p = ParseAdminkun.new
  @object_array = p.get_adminkun_objects
  
  @table_size = DB[:adminkun].count
  @message = ""
  unless @object_array.size == DB[:adminkun].count
    @message = "Found new comic data"# push notificate
    # add data to db that no registerd comic info
    @object_array.each do |i|
      if i.serial_number.to_i > @table_size
        DB[:adminkun] << { :index_title => i.index_title, 
                           :serial_number => i.serial_number,
                           :index_overview => i.index_overview, 
                           :index_image_url => i.index_image_url,
                           :body_url => i.body_url}
      end
    end
  end
  # { :id => id.to_s }.to_json
  haml :getcomic, :layout => :layout1
end

################################################################################
# 新着コミックを取得してDBに登録する
################################################################################
get '/fetch_comic_data/:group' do
  case params[:group]
  when 'mradmin'
    fetch_mradmin
    haml :fetch_mradmin, :layout => :layout1
  when 'adminkun'
    fetch_adminkun
    haml :fetch_adminkun, :layout => :layout1
  else
    redirect '/about'
  end
end

################################################################################
# DBに登録済みのコミック数を返す
# group: 区分（'adminkun' or 'mradmin'）
################################################################################
get '/count/:group' do
  if params[:group] == "adminkun"
    count = DB[:adminkun].count
    {:count => count.to_s}.to_json
  elsif params[:group] == "mradmin"
    count = DB[:mradmin].count
    {:count => count.to_s}.to_json
  else
    {:count => "9999".to_s}.to_json
  end
end


################################################################################
# 指定された記事情報をJSON形式で返す
# group: 'adminkun' or 'mradmin'
# serial_number: 連載番号
################################################################################
get '/get_comic/:group/:serial_number' do
  # "Hello #{params[:serial_number]}!"
  number = params[:serial_number].to_i
  if params[:group] == 'adminkun'
    dataset = DB[:adminkun]
  elsif params[:group] == 'mradmin'
    dataset = DB[:mradmin]
  else
    redirect '/about'
  end
  row = dataset[:serial_number => number]

  serial_number = row[:serial_number]
  title = row[:index_title]
  overview = row[:index_overview]
  index_image_url = row[:index_image_url]
  body_url = row[:body_url]

  { :serial_number => serial_number,
    :title => title, 
    :overview => overview,
    :index_image_url => index_image_url,
    :body_url => body_url
  }.to_json
end


################################################################################
# 指定された連載番号のコミック情報をHTML形式で返す
# serial_number: 連載番号
################################################################################
get '/show_adminkun/:serial_number' do
  number = params[:serial_number]
  adminkun = DB[:adminkun]
  data = adminkun[:serial_number => number]

  serial_number = data[:serial_number]
  @title = data[:index_title]
  @overview = data[:index_overview]
  @index_image_url = data[:index_image_url]
  body_url = data[:body_url]
  
  hoge = sprintf("%03d", number)
  base_url = "http://www.atmarkit.co.jp/fwin2k/itpropower/admin-kun"
  if number.to_i == 1
    @comic_image = "#{base_url}/#{hoge}/admin#{hoge}l.gif"
    # @comic_image = "http://localhost:3000/images/admin#{hoge}l.gif"
  else
    @comic_image = "#{base_url}/#{hoge}/admin#{hoge}_l.gif"
    # @comic_image = "http://localhost:3000/images/admin#{hoge}_l.gif"
  end
  
  haml :show_adminkun, :layout => :layout1
end

################################################################################
# 指定された連載番号のコミック情報をHTML形式で返す
# serial_number: 連載番号
################################################################################
get '/show_mradmin/:serial_number' do
  @number = params[:serial_number]
  adminkun = DB[:mradmin]
  data = adminkun[:serial_number => @number]

  serial_number = data[:serial_number]
  @title = data[:index_title]
  @overview = data[:index_overview]
  @index_image_url = data[:index_image_url]
  body_url = data[:body_url]
  
  hoge = sprintf("%03d", @number)
  base_url = "http://www.atmarkit.co.jp/fwin2k/itpropower/admin-kun-en"
  @comic_image = "#{base_url}/#{hoge}/adminen#{hoge}_l.gif"
  # @comic_image = "http://localhost:3000/images/admin#{hoge}_l.gif"
  
  haml :show_mradmin, :layout => :layout1
end


################################################################################
# 指定されたコミック区分の全情報をDBから取得してJSON形式で返す
# group: 区分（'adminkun' or 'mradmin')
################################################################################
get '/get_menu/:group' do

  if params[:group] == 'adminkun'
    dataset = DB[:adminkun]
  else
    dataset = DB[:mradmin]
  end

  row = dataset.order(:serial_number)
  
  result = Array.new
  row.each do |i|
    result << { :serial_number => i[:serial_number],
                :index_title => i[:index_title], 
                :index_overview => i[:index_overview],
                :index_image_url => i[:index_image_url],
                :body_url => i[:body_url],
                :body_image_url => self.make_body_image_url(i[:serial_number], params[:group])
              }
  end
  result.to_json
end


get '/get_menu/:group/:start/:count' do

  if params[:group] == 'adminkun'
    dataset = DB[:adminkun]
  else
    dataset = DB[:mradmin]
  end
  
  start = params[:start].to_i
  count = params[:count].to_i
  row = dataset.order(:serial_number)
  
  result = Array.new
  row.each do |i|
    if i[:serial_number].to_i >= start && 
      i[:serial_number].to_i <= (start + count)
      result << { :serial_number => i[:serial_number],
                  :index_title => i[:index_title], 
                  :index_overview => i[:index_overview],
                  :index_image_url => i[:index_image_url],
                  :body_url => i[:body_url],
                  :body_image_url => self.make_body_image_url(i[:serial_number], params[:group])
                }
    end
  end
  result.to_json
end



################################################################################

get '/cookie_session' do
  session["count"] ||= 0
  session["count"] += 1
  "count: #{session["count"]}"
end


get '/allsheets' do
end


get '/about' do 
  "I'm running on Version " + Sinatra::VERSION 
end 


not_found do
  'This is nowhere to be found'
   @notfound = "no page"
end

 
error do
  status 303
  'Sorry there was a nasty error - ' + env['sinatra.error'].name
  # 'Sorry there was a nasty error - ' + request.env['sinatra.error'].name
end

# load "hoge.rb"
