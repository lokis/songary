goog.provide 'server.main'

goog.require 'server.DiContainer'

###*
  @param {Object} config
###
server.main = (config) ->

  container = new server.DiContainer

  container.configure
    resolve: server.App
    with: config: config 
  ,
    resolve: server.FrontPage
    with:
      isDev: config['env']['development']
      version: config['version']
      clientData:
        app:
          version: config['version']
  ,
    resolve: server.ElasticSearch
    with:
      elasticSearch: require 'elasticsearch'
      host: config['elasticSearch'].host

  container.resolveServerApp()

goog.exportSymbol 'server.main', server.main
