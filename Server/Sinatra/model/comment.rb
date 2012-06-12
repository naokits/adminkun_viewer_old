Sequel.connect("sqlite://comments.db")

class Comments < Sequel::Model
  unless table_exists?
    set_schema do
      primary_key :id
      string :name
      string :title
      text :message
      timestamp :posted_date
    end
    create_table
  end

  # (略)
end

# ----------------------------------------------------------------------

# DB << "create table users (name varchar(255) not null)"
# 
# DB.fetch("select name from users") do |row|
#   p row[:name]
# end
# 
# dataset = DB[:managers].where(:salary => 50..100).order(:name, :department)
# 
# # first page, 10 rows per page
# paginated = dataset.paginate(1, 10)
# 
# # bumber of pages in dataset
# paginated.page_count
# 
# # 1
# paginated.current_page
# 
# # ------------- Model
# 
# class Post < Sequel::Model(:my_posts)
#   set_primary_key[:category, :title]
#   
#   belongs_to :author
#   has_many :comments
#   has_and_belongs_to_many :tags
#   
#   after_create do
#     set(:created_at => Time.now)
#   end
# 
# end
# 
# class Person < Sequel::Model
#   has_many :posts, :eager => [:tags]
#   
#   set_schema do
#     primary_key :id
#     text :name
#     text :email
#     foreign_key :team_id, :table => :teams
#   end
# end

