Room = require 'core/Environment/2D/Room'
PerseaModel = require 'Persea/Models/PerseaModel'

TileLayerModel = require 'Persea/Models/TileLayer'

Room = module.exports = PerseaModel.extend(
	revision: 11
	
	collision: DS.attr 'passthru'
	entities: DS.attr 'passthru'
	layers: DS.hasMany TileLayerModel
	name: DS.attr 'string'
	size: DS.attr 'passthru'
	
	objectProperties: ['collision', 'entities', 'layers', 'name', 'size']
	
	didLoad: ->
		
		console.log @get 'name'
#		console.log this
	
	loadObject: ->
		
		return
		
		O =
			collision: @get 'collision'
			entities: @get 'entities'
			layers: @get 'layers'
			name: @get 'name'
			size: @get 'size'
		
		object = new Room()
		object.fromObject(O).then =>
			
			@set 'object', object
			
).reopenClass
	
	collectionName: 'rooms'
