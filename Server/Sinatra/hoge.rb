require 'rubygems'
require 'sequel'
# require 'parse_adminkun'
# require 'ParseMrAdmin'
# require 'adminkun'
require 'logger'
require 'json'

options = {:loggers => [Logger.new($stdout)]}
DB = Sequel.connect('sqlite://adminkun.db', options)

# @table_size = DB[:mradmin].count
@dataset = DB[:mradmin]

# p result =  dataset.order(:serial_number).last[:index_title]
@lastno = @dataset.order(:serial_number).last
# p @lastno[:serial_number]
if @lastno.nil?
  puts 'this is nil'
end