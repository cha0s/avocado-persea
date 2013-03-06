###

# Use SFML CoreService for now.
Core = require 'Core'
Core.CoreService.implementSpi 'sfml', '../../..'
Core.coreService = new Core.CoreService()

Core.CoreService.setEngineRoot '../../../engine'
Core.CoreService.setResourceRoot '../../../resource'

# Use SFML GraphicsService for now.
Graphics = require 'Graphics'
Graphics.GraphicsService.implementSpi 'sfml', '../../..'
Graphics.graphicsService = new Graphics.GraphicsService()

# Use SFML TimingService for now.
Timing = require 'Timing'
Timing.TimingService.implementSpi 'sfml', '../../..'
Timing.timingService = new Timing.TimingService()

# Use SFML SoundService for now.
Sound = require 'Sound'
Sound.SoundService.implementSpi 'sfml', '../../..'
Sound.soundService = new Sound.SoundService()

# SPI proxies.
require 'core/proxySpiis'

Environment = require 'core/Environment/2D/Environment'
fs = require 'fs'
mongoose = require 'mongoose'

###

fs = require 'fs'
mongoose = require 'mongoose'
upon = require 'core/Utility/upon'

mongoose.connect 'localhost', 'persea'

db = mongoose.connection

db.on 'error', -> console.log arguments

db.once 'open', ->

	Models = require './lib/server/Models'
	
	{Environment, Room, TileLayer, Project, Tileset} = Models
	
	modelPromises = for key, Model of Models
		
		(->
		
			modelDefer = upon.defer()
			
			((Model, key) ->
			
				Model.Model.remove ->
					
					console.log "Cleaning out #{key}..."
					
					modelDefer.resolve()
				
			) Model, key
			
			modelDefer.promise
			
		)()
	
	upon.all(modelPromises).then ->
		
		tilesetDefer = upon.defer()
		
		tilesetModel = new Tileset.Model
					
			name: 'LEPS forest'
			description: 'Forested areas within the LEPS'
			
			tileSize: [16, 16]
			tileData: fs.readFileSync '../../../resource/tileset/wb-forest.png'
		
		tilesetModel.save ->
			
			console.log 'saved tileset'
			
			tilesetDefer.resolve()
		
		environment = JSON.parse fs.readFileSync '../../../resource/environment/leps-forest.environment.json', 'utf8'
		
		environmentDefer = upon.defer()
		
		roomModels = []
		roomPromises = for room, i in environment.rooms
			
			(->
			
				roomDefer = upon.defer()
				
				((room, i) ->
				
					layerModels = []
					layerPromises = for layer, j in room.layers
						
						(->
					
							layerDefer = upon.defer()
							
							((layer, j) ->
							
								layerModel = new TileLayer.Model layer
								
								layerModel.save ->
									
									console.log "saved room #{i} layer #{j}"
									
									layerModels[j] = layerModel
									
									layerDefer.resolve()
								
							) layer, j
							
							layerDefer.promise
							
						)()
						
					upon.all(layerPromises).then ->
						
						room.layers = layerModels
						
						roomModel = new Room.Model room
						
						roomModel.save ->
							
							console.log "saved room #{i}"
							
							roomModels[i] = roomModel
							
							roomDefer.resolve()
					
				) room, i
				
				roomDefer.promise
				
			)()
		
		upon.all(roomPromises.concat [tilesetDefer]).then ->
			
			environment.rooms = roomModels
			environment.tileset = tilesetModel
			
			environmentModel = new Environment.Model environment
			
			environmentModel.save ->
				
				console.log "saved environment"
				
				environmentDefer.resolve()
		
				projectModel = new Project.Model
					name: 'Worlds Beyond'
					description: 'Oldskool console RPG!'
					environments: [environmentModel]
					tilesets: [tilesetModel]
					
				projectModel.save ->
					
					console.log "saved project"
					
					db.close()
