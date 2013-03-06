
_ = require 'core/Utility/underscore'
consolidate = require 'consolidate'
coffee = require 'coffee-script'
express = require 'express'
fs = require 'fs'
helpers = require './lib/server/helpers'
http = require 'http'
path = require 'path'
Models = require './lib/server/Models'
less = require 'less'
mongoose = require 'mongoose'
mongooseApi = require 'mongoose-api'
path = require 'path'
somber = require './lib/server/somber'
util = require 'util'

mongoose.connect 'mongodb://localhost/persea'

app = express()

app.engine 'html', consolidate.mustache

app.set 'view engine', 'html'

moduleServer = new class ModuleServer
	
	constructor: ->
		
		@pathMap = {}
		@preprocessors =
			
			js: (code, filename, moduleName, callback) -> callback null, code
			
			coffee: (code, filename, moduleName, callback) ->
				
				try
					
					callback null, coffee.compile code
					
				catch error
					
					reason = (util.inspect error).replace /'/g, "\\'"
					
					callback null, "
					console.log('Coffee compiler couldn\\'t compile #{moduleName}! Reason given: #{reason}');
"

	pathFilenames: (_path) ->
		
		filenames = []
		
		return filenames unless @pathMap[_path]?
		
		for info in @pathMap[_path]
			
			filenames = filenames.concat info.filenames.map (filename) ->
				
				path.join _path, info.prefix, filename
			
		filenames
	
	serveModules: (path, directory, prefix = '') ->
		
		@pathMap[path] ?= []
		
		fullPaths = helpers.gatherFilesRecursiveSync directory
		
		@pathMap[path].push
			
			filenames: fullPaths.map (fullPath) -> fullPath.substr directory.length + 1
			directory: directory
			prefix: prefix
	
	registerPreprocessor: (extension, callback) ->
		
		@preprocessors[extension] = callback
		
	serveFile: (filename, moduleName, callback) ->

		fs.readFile filename, 'UTF-8', (error, code) =>
			
			return callback error if error?
			
			@preprocessFile filename, moduleName, callback
			
	preprocessFile: (filename, moduleName, callback) ->
		
		basename = path.basename filename
		
		[basename, extension] = basename.split '.'
		
		fs.readFile filename, 'UTF-8', (error, code) =>
			
			return callback error if error
			
			@preprocessors[extension] code, filename, moduleName, (error, code) ->
				
				return callback error if error
				
				callback null, "requires_['#{moduleName}'] = function(module, exports) {\n#{code}\n}\n"
				
	toMiddleware: -> (req, res, next) =>
		
		requestUrl = req.url
		
		for url, infoList of @pathMap
			
			if url is requestUrl.substr 0, url.length
				
				filename = requestUrl.substr url.length + 1
				
				for info in infoList
					
					continue unless info.prefix is filename.substr 0, info.prefix.length
					
					unprefixedFilename = if info.prefix is ''
						filename
					else
						filename.substr info.prefix.length + 1
					
					continue if -1 is index = info.filenames.indexOf unprefixedFilename
					
					filename = path.join info.directory, info.filenames[index]
					
					moduleName = @moduleNameFromFilename info.filenames[index]
					moduleName = path.join info.prefix, moduleName
					
					return fs.exists filename, (exists) =>
						
						return res.status(404).end 'Not Found' unless exists
						
						@serveFile filename, moduleName, (error, code) ->
							
							return next error if error?
							
							res.type 'text/javascript'
							res.end code
		
		next()

	moduleNameFromFilename: (filename) ->
		moduleName = filename
		
		dirname = path.dirname moduleName
		dirname = if dirname is '.'
			''
		else
			dirname + '/'
			
		moduleName = "#{dirname}#{path.basename moduleName, path.extname moduleName}"
		
moduleServer.serveModules '/js', '../avocado/engine/core', 'core'
moduleServer.serveModules '/js', '../avocado/engine/main/web/Bindings', 'main/web/Bindings'
moduleServer.serveModules '/js', "#{__dirname}/lib/client"

app.use moduleServer.toMiddleware()

app.get '/engine/main/web/Initialize.coffee', (req, res, next) ->

	filename = path.join '..', 'avocado', 'engine', 'main', 'web', 'Initialize.coffee'
	
	fs.readFile filename, 'UTF-8', (error, code) ->
		
		return next error if error?
		
		res.type 'text/javascript'
		res.end coffee.compile code
	

app.get '/js/index.coffee', (req, res, next) ->
	
	filename = path.join __dirname, 'static', 'js', 'index.coffee'
	
	fs.readFile filename, 'UTF-8', (error, code) ->
		
		return next error if error?
		
		res.type 'text/javascript'
		res.end coffee.compile code

app.get '/css/persea.less', (req, res, next) ->
	
	filename = path.join __dirname, 'static', 'css', 'persea.less'
	
	fs.readFile filename, 'UTF-8', (error, code) ->
		
		return next error if error?
		
		less.render code, (error, css) ->
			
			return next error if error?
			
			res.type 'text/css'
			res.end css

app.get '/', (req, res) ->
	
	moduleFilenames = moduleServer.pathFilenames '/js'
	locals = moduleFiles: moduleFilenames.map (filename) -> src: filename
	
	res.render 'index', locals, (error, html) ->
		
		res.end html

app.use express.static path.join __dirname, 'static'

httpServer = http.createServer app
httpServer.listen 13338

mongooseApi.serveModels app

db = mongoose.connection

db.on 'error', console.error.bind console, 'connection error:'

db.once 'open', ->

	io = require('socket.io').listen httpServer
	
	ioSettings =
		
		'log level': 1
		'transports': [
			'websocket'
			'flashsocket'
			'htmlfile'
			'xhr-polling'
			'jsonp-polling'
		]
	
	io.set key, value for key, value of ioSettings
