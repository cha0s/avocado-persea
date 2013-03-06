_ = require 'core/Utility/underscore'
helpers = require './helpers'

module.exports = (
	rootPath = '../avocado'
) ->

	# Build the list of core files. We'll generate script tags for each to
	# send to the client.
	coreFiles: _.map(
		helpers.gatherFilesRecursiveSync "#{rootPath}/engine/core", "/engine/core"
		(filename) -> src: filename.replace rootPath, ''
	)
	
	# Build the list of bindings. We'll generate script tags for each to
	# send to the client.
	bindingFiles: _.map(
		helpers.gatherFilesRecursiveSync "#{rootPath}/engine/main/web/Bindings", "/engine/main/web/Bindings"
		(filename) -> src: filename.replace rootPath, ''
	)
