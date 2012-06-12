require 'rubygems'
require 'sequel'
# Sequel::Model.plugin(:schema)

options = {:loggers => [Logger.new($stdout)]}
DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://adminkun.db', options)

class Menu < Sequel::Model
  unless table_exists?
    set_schema do
      primary_key :id
      fixnum :menu_id
      string :menu_title
      text :menu_description
      text :memo
      string :lang
      timestamp :posted_date
    end
    create_table
  end

  def date
    self.posted_date.strftime("%Y-%m-%d %H:%M:%S")
  end

  def formatted_message
    Rack::Utils.escape_html(self.message).gsub(/\n/, "<br>")
  end
  
  def initmenu
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
  end
end

