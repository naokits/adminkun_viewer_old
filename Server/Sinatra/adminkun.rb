
class Adminkun
  attr_accessor :serial_number
  attr_accessor :index_title
  attr_accessor :index_image_url
  attr_accessor :index_overview
  attr_accessor :body_url
  attr_accessor :body_image_url

  def initialize #(args)
    self.serial_number = 0.to_i
    self.index_title = ""
    self.index_image_url = ""
    self.index_overview = ""
    self.body_url = ""
    self.body_image_url = ""
  end
end


class MrAdmin
  attr_accessor :serial_number
  attr_accessor :index_title
  attr_accessor :index_image_url
  attr_accessor :index_overview
  attr_accessor :body_url
  attr_accessor :body_image_url

  def initialize #(args)
    self.serial_number = 0.to_i
    self.index_title = ""
    self.index_image_url = ""
    self.index_overview = ""
    self.body_url = ""
    self.body_image_url = ""
  end
end
