fs = require 'fs'
path = require 'path'
upon = require 'core/Utility/upon'

# Gather all files under a path, recursively.
exports.gatherFilesRecursiveSync = gatherFilesRecursiveSync = (filepath) ->
		
	files = []
	for candidate in fs.readdirSync filepath
		subpath = "#{filepath}/#{candidate}"
		
		# Recur?
		stats = fs.statSync subpath
		if stats.isDirectory()
			files = files.concat gatherFilesRecursiveSync subpath
			
		# Add to the list.
		else
			files.push subpath
	
	files

exports.serveModuleFiles = (app, resourcePath, rootPath, modulePrefix) ->
	
	# Derive the module name from the filename. e.g.:
	#     avocado> moduleNameFromFilename '/foo/bar/engine/core/CoreService.coffee'
	#     'core/CoreService'
	moduleNameFromFilename = (filename) ->
		moduleName = filename.substr "#{rootPath}#{modulePrefix}".length
		
		dirname = path.dirname moduleName
		dirname = if dirname is '.'
			''
		else
			dirname + '/'
		moduleName = "#{dirname}#{path.basename moduleName, path.extname moduleName}"
		
	# Wrap core files so they can be require()'d.
	app.get resourcePath, (req, res, next) ->
		
		defer = upon.defer()
		
		# Derive the module name from the filename.
		filename = "#{rootPath}#{req._parsedUrl.pathname}"
		moduleName = moduleNameFromFilename filename
		
		# If the code has already been processed, pass it right along.
		if req.processedCode
			defer.resolve req.processedCode
			
		# Otherwise, it still needs to be loaded; do so.
		else
		
			# First make sure it exists.
			fs.exists filename, (exists) ->
				return res.status(404).end 'File Not Found' unless exists
				
				# Pass along the code.
				fs.readFile "#{rootPath}#{req.url}", 'UTF-8', (error, code) ->
					throw error if error
					defer.resolve code
			
		# Wrap the code to make it accessible to the module system.
		defer.then (code) ->
			req.processedCode = "requires_['#{moduleName}'] = function(module, exports) {\n#{code}\n}\n"
			next()

exports.preprocessFiles = (
	app
	resourcePath
	rootPath
	mimes
	fn
) ->

	# Automatically stream any LESS files requested as CSS.
	app.get resourcePath, (req, res, next) ->
		
		# Make sure the file exists.
		filename = "#{rootPath}#{req._parsedUrl.pathname}"
		fs.exists filename, (exists) ->
			return res.status(404).end 'File Not Found' unless exists
			
			# Read it.
			fs.readFile filename, 'UTF-8', (error, code) ->
				throw error if error
				
				# If the original LESS was requested, end the request
				# with its return.
				if req.query.original?
					res.type mimes.original
					res.end code
					
				# Otherwise, process the LESS and continue the request.
				else
					res.type mimes.processed
					
					try
						fn req, res, next, code, req._parsedUrl.pathname

					catch e
						throw new Error "Failed processing #{filename}: #{e.stack}"
					
