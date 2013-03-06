Environment = require 'core/Environment/2D/Environment'
PerseaModel = require 'Persea/Models/PerseaModel'

RoomModel = require 'Persea/Models/Room'
TilesetModel = require 'Persea/Models/Tileset'

EnvironmentModel = module.exports = PerseaModel.extend(
	revision: 11

	name: DS.attr 'string'
	description: DS.attr 'string'
	
	rooms: DS.hasMany RoomModel
#	rooms: DS.attr 'passthru'
	tileset: DS.belongsTo TilesetModel
	
	objectProperties: ['name', 'description', 'rooms', 'tileset']
	
	didLoad: ->
		
		console.log 'room load'
		
		console.log @get 'rooms.content'
		
#		setTimeout(
#			=> console.log @get('rooms.content')
#			3000
#		)
		
#		@get('rooms.0')
		
#		console.log @get 'rooms.content.0'
	
#		setTimeout(
#			=> console.log @get 'rooms.content'
#			2000
#		)
		
		
		console.log 'loaded'
	
#	blah: (->
#		
#		console.log 'hi'
#		
#	).observes 'room.0'
	
	_loadObject: (model, key) ->
		
#		console.log key
#		console.log model
#		console.log @get key
		
		@_super()
		
		return
		
	loadObject: ->
		
		return
		
		O =
			name: @get 'name'
			description: @get 'description'
			rooms: @get 'rooms'
#			rooms: JSON.parse JSON.stringify @get 'rooms'
		
		object = new Environment()
		object.fromObject(O).then =>
			
			@set 'object', object
			
).reopenClass
	
	collectionName: 'environments'
