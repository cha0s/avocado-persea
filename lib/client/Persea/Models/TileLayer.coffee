TileLayer = require 'core/Environment/2D/TileLayer'
PerseaModel = require 'Persea/Models/PerseaModel'

TileLayer = module.exports = PerseaModel.extend(
	revision: 11
	
	size: DS.attr 'passthru'
	tileIndices: DS.attr 'passthru'
	
	objectProperties: ['size', 'tileIndices']
	
	loadObject: ->
		
		return
		
		O =
			size: @get 'size'
			tileIndices: @get 'tileIndices'
		
		object = new TileLayer()
		object.fromObject(O).then =>
			
			@set 'object', object
			
).reopenClass
	
	collectionName: 'tilelayers'
