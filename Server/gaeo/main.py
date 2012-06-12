# -*- coding: UTF-8 -*-
import logging
import os
import re
import sys
import wsgiref.handlers

# 以下は、ライブラリの添付の仕方です。
# myapp/eggs/html5lib-0.11.1-py2.5.egg
# myapp/eggs/BeautifulSoup-3.1.0.1-py2.5.egg
# と置いて、これらをスクリプトの頭のほうでsys.pathに追加すれば、importできるようになります。
# app.yaml に書く.pyファイルの先頭にて
# for arch in os.listdir("eggs"):
#     sys.path.insert(0, os.path.join("eggs", arch))
#     pass
# import html5lib

from google.appengine.ext import webapp


# use zipped gaeo
try:
  import os
  if os.path.exists("gaeo.zip"):
    import sys
    sys.path.insert(0, 'gaeo.zip')
except:
  logging.info('Use normal gaeo folder')


import gaeo
from gaeo.dispatch import router


def initRoutes():
    r = router.Router()
    
    #TODO: add routes here
    r.connect('/support/', controller = 'support', action = 'index')
    r.connect('/support_en/', controller = 'support_en', action = 'index')
    # r.connect('/support/ja/', controller = 'support_ja', action = 'index')    
    r.connect('/current_number', controller = 'welcome', action = 'current_number')
    r.connect('/get', controller = 'welcome', action = 'get')
    r.connect('/fetch_adminkun_from_atmarkit', controller = 'welcome', action = 'fetch_adminkun_from_atmarkit')
    r.connect('/fetch_mradmin_from_atmarkit', controller = 'welcome', action = 'fetch_mradmin_from_atmarkit')
    r.connect('/number_of_adminkun', controller = 'welcome', action = 'number_of_adminkun')
    # r.connect('/:controller/:action/:args1/:args2')
    r.connect('/:controller/:action/:id')

def initPlugins():
    """
    Initialize the installed plugins
    """
    plugins_root = os.path.join(os.path.dirname(__file__), 'plugins')
    if os.path.exists(plugins_root):
        plugins = os.listdir(plugins_root)
        for plugin in plugins:
            if not re.match('^__|^\.', plugin):
                try:
                    exec('from plugins import %s' % plugin)
                except ImportError:
                    logging.error('Unable to import %s' % (plugin))
                except SyntaxError:
                    logging.error('Unable to import name %s' % (plugin))

def main():
    # add the project's directory to the import path list.
    sys.path.append(os.path.dirname(__file__))
    sys.path.append(os.path.join(os.path.dirname(__file__), 'application'))

    # get the gaeo's config (singleton)
    config = gaeo.Config()
    # setup the templates' location
    config.template_dir = os.path.join(
        os.path.dirname(__file__), 'application', 'templates')

    initRoutes()
    # initialize the installed plugins
    initPlugins()

    app = webapp.WSGIApplication([
                (r'.*', gaeo.MainHandler),
            ], debug=False)
    wsgiref.handlers.CGIHandler().run(app)

if __name__ == '__main__':
    main()
