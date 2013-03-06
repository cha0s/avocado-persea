coffee = require 'coffee-script'
fs = require 'fs'
helpers = require './helpers'
less = require 'less'
mustache = require 'mustache'
util = require 'util'

module.exports = (
	app
	rootPath = '../avocado'
) ->
	
	helpers.preprocessFiles(
		app
		/\/[^/]*\.coffee$/
		rootPath
		{
			original: 'text/coffeescript'
			processed: 'text/javascript'
		}
		(req, res, next, code, pathname) ->
			
			try
				
				req.processedCode = coffee.compile code
				
			catch e
				
				reason = (util.inspect e).replace /'/g, "\\'"
				
				req.processedCode = "
				console.log('Coffee compiler couldn\\'t compile #{pathname}! Reason given: #{reason}');
"
				
			next()
	)
	
	helpers.preprocessFiles(
		app
		/\/[^/]*\.less$/
		rootPath
		{
			original: 'text/less'
			processed: 'text/css'
		}
		(req, res, next, code) ->
			less.render code, (e, css) ->
				req.processedCode = css
				next()
	)
	
	helpers.serveModuleFiles(
		app
		resourcePath
		rootPath
		'/engine/'
	) for resourcePath in [
		/^\/engine\/core\/.*/
		/^\/engine\/main\/web\/Bindings\/.*/
	]
	
	config =
		'Network.coffee': {}
	
	# Write configuration variables.
	app.get '/engine/core/Config/:filename', (req, res, next) ->
		
		switch filename = req.params.filename
			
			when 'Network.coffee'
				config[filename].hostname = "http://#{req.headers.host}"
				
			else
				return next()
				
		req.processedCode = mustache.to_html(
			req.processedCode
			config[filename]
		)
		
		next()
	
