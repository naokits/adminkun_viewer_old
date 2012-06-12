from google.appengine.ext import db
from gaeo.model import BaseModel, SearchableBaseModel

class Adminkun(BaseModel):
  serial_number = db.IntegerProperty(required = True)
  read_flag = db.BooleanProperty(required = True)
  index_title = db.StringProperty(required = True)
  index_overview = db.TextProperty(required = True)
  index_image_url = db.LinkProperty(required = True)
  body_url = db.LinkProperty(required = True)
  body_image_url = db.LinkProperty(required = False)
  lang = db.StringProperty(required = False)
  post_at = db.DateTimeProperty(required=True, auto_now_add=True)
  pass
  
