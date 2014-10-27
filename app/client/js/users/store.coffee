goog.provide 'app.users.Store'

goog.require 'app.ValidationError'
goog.require 'app.songs.Song'
goog.require 'app.users.User'
goog.require 'este.Store'
goog.require 'goog.array'

class app.users.Store extends este.Store

  ###*
    @param {app.Dispatcher} dispatcher
    @param {app.LocalHistory} localHistory
    @constructor
    @extends {este.Store}
  ###
  constructor: (dispatcher, @localHistory) ->
    super()
    @name = 'user'
    @setEmpty()

    dispatcher.register (action, payload) =>
      switch action
        when app.Actions.ADD_NEW_SONG
          @addNewSong_()

  ###*
    Not yet added new song, persisted in localStorage.
    @type {app.songs.Song}
  ###
  newSong: null

  ###*
    User songs persisted in localStorage.
    @type {Array.<app.songs.Song>}
  ###
  songs: null

  ###*
    @type {app.users.User}
  ###
  user: null

  ###*
    @return {goog.Promise}
    @private
  ###
  addNewSong_: ->
    @newSong.validate()
      .then =>
        return if !@contains @newSong
        throw new app.ValidationError [
          msg: "Song #{@newSong.name}, #{@newSong.artist} already exists."
          props: ['name', 'artist']
        ]
      .then =>
        @songs.push @newSong
        @newSong = new app.songs.Song
        @notify()

  setEmpty: ->
    @newSong = new app.songs.Song
    @songs = []
    @user = new app.users.User

  ###*
    @return {Array.<app.songs.Song>}
  ###
  songsSortedByName: ->
    songs = @songs.slice 0
    goog.array.sortObjectsByKey songs, 'name'
    songs

  ###*
    @return {Array.<app.songs.Song>}
  ###
  songsSortedByUpdatedAt: ->
    songs = @songs.slice 0
    songs.sort (a, b) -> new Date(b.updatedAt) - new Date(a.updatedAt)
    songs

  ###*
    @param {app.songs.Song} song
    @param {boolean} inTrash
  ###
  trashSong: (song, inTrash) ->
    song.inTrash = inTrash
    @notify()

  ###*
    @param {string} id
    @return {app.songs.Song}
  ###
  songById: (id) ->
    goog.array.find @songs, (song) -> song.id == id

  ###*
    @param {este.Route} route
    @return {app.songs.Song}
  ###
  songByRoute: (route) ->
    @songById route.params.id

  ###*
    @param {app.songs.Song} song
    @return {boolean}
  ###
  contains: (song) ->
    goog.array.some @songs, (item) ->
      return false if item.inTrash
      item.name == song.name &&
      item.artist == song.artist

  ###*
    @param {app.songs.Song} song
    @param {string} prop
    @param {string} value
  ###
  updateSong: (song, prop, value) ->
    song[prop] = value
    song.update()
    @notify()

  deleteSongsInTrash: ->
    goog.array.removeAllIf @songs, (song) -> song.inTrash
    @notify()

  ###*
    @override
  ###
  toJson: ->
    newSong: @newSong
    songs: @songs
    user: @user

  ###*
    @override
  ###
  fromJson: (json) ->
    if json.newSong
      @newSong = new app.songs.Song json.newSong
    if json.songs
      @songs = json.songs.map (json) => new app.songs.Song json
    if json.user
      @user = new app.users.User json.user
    @notify()

  ###*
    How user authentication works:
      - User login/logout status is defined by localStoraged userStore.
      - FB api is loaded only if user is not logged.
      - After user login, user auth is sent to server.
      - User identity is verified on server, then user is lazy created.
      - Server issues cookie, no session.
      - This cookie is used for server user authentication.
      - Once cookie is expired, server returns UNAUTHORIZED http status.
      - Unauthorized status sets client user as logged out.
    @param {Object} json
  ###
  loginFacebookUser: (json) ->
    @fromJson user: app.users.User.fromFacebook json

  ###*
    It's important to delete all user data on logout.
  ###
  logout: ->
    @setEmpty()
    @notify()
    # TODO: load api

  ###*
    @return {boolean}
  ###
  isLogged: ->
    return !!@user.email

  ###*
    @param {app.songs.Song} song
    @return {Array.<string>}
  ###
  getSongLyricsLocalHistory: (song) ->
    []
    # seen = {}
    #
    # @localHistory
    #   .of @
    #   .map (store) ->
    #     if store.newSong.id == song.id
    #       return store.newSong?.lyrics?.trim()
    #     store.songs?[song.id]?.lyrics?.trim()
    #   .filter (lyrics) ->
    #     # Exists and has more than one word.
    #     lyrics && lyrics.split(/\s+/).length > 1
    #   .filter (lyrics) ->
    #     return false if seen[lyrics]
    #     seen[lyrics] = true

  ###*
    @param {app.songs.Song} song
  ###
  setSongPublisher: (song) ->
    # song.publisher = @user.uid
    # @notify()

  ###*
    @param {app.songs.Song} song
  ###
  removeSongPublisher: (song) ->
    # song.publisher = null
    # @notify()

  ###*
    @param {app.songs.Song} song
  ###
  savePublishedSongToDevice: (song) ->
    # Make a clone.
    song = new app.songs.Song song
    @songs.push song
    @notify()
