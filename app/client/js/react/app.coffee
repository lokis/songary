goog.provide 'app.react.App'

class app.react.App

  ###*
    @param {app.Routes} routes
    @param {app.react.Header} header
    @param {app.react.Footer} footer
    @param {app.home.index.react.Page} homeIndexPage
    @param {app.songs.edit.react.Page} songsEditPage
    @constructor
  ###
  constructor: (routes, header, footer, homeIndexPage, songsEditPage) ->
    {div} = React.DOM

    @create = React.createClass

      render: ->
        div className: 'app',
          header.create null
          switch routes.getActive()
            when routes.home then homeIndexPage.create null
            when routes.newSong then songsEditPage.create null
          footer.create null

      componentDidMount: ->
        @ensureAllAnchorsHaveTouchAction_()

      componentDidUpdate: ->
        @ensureAllAnchorsHaveTouchAction_()

      # http://www.polymer-project.org/platform/pointer-events.html#basic-usage
      ensureAllAnchorsHaveTouchAction_: ->
        for a in @getDOMNode().querySelectorAll 'a'
          continue if a.hasAttribute 'touch-action'
          a.setAttribute 'touch-action', 'none'
        return