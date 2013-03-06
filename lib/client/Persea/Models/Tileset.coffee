Image = require('Graphics').Image
PerseaModel = require 'Persea/Models/PerseaModel'
Tileset = require 'core/Environment/2D/Tileset'
upon = require 'core/Utility/upon'

Model = module.exports = PerseaModel.extend(
	revision: 11
	
	name: DS.attr 'string'
	description: DS.attr 'string'
	
	tileSize: DS.attr 'passthru'
	tileData: DS.attr 'string'
	
	objectProperties: ['name', 'description', 'tileData', 'tileSize']
	
	synchronizeObject: ->
		
		object = @get 'object'
		
		object.setName @get 'name'
		object.setDescription @get 'description'
		object.setTileSize @get 'tileSize'
		
		unless object.image().src is "data:image/png;base64,#{@get 'tileData'}"
			
			Image.load(@get 'tileData').then (image) =>
			
				object.setImage image
		
	loadObject: ->
		
		Image.load(@get 'tileData').then (image) =>
		
			O =
				tileSize: @get 'tileSize'
				name: @get 'name'
				description: @get 'description'
				image: image
			
			object = new Tileset()
			object.fromObject(O).then =>
				
				@set 'object', object
			
).reopenClass
	
	collectionName: 'tilesets'
