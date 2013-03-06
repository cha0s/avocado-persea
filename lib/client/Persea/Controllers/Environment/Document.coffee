Floodfill = require 'core/Utility/Floodfill'
Image = require('Graphics').Image
Matrix = require 'core/Extension/Matrix'
NavBarView = require 'Persea/Views/Bootstrap/NavBar'
Rectangle = require 'core/Extension/Rectangle'
RoomLayersView = require 'Persea/Views/Environment/RoomLayers'
UndoCommand = require 'Persea/Undo/Command'
UndoStack = require 'Persea/Undo/Stack'
UndoGroup = require 'Persea/Undo/Group'
Vector = require 'core/Extension/Vector'
Zoom = require 'Persea/Mixins/Zoom'

DocumentZoom = Ember.Mixin.create Zoom, zoomLevel: 200

module.exports = Ember.Controller.extend DocumentZoom,
	
	init: ->
		
		@undoStacks = []
		
	environmentBinding: Ember.Binding.oneWay 'environmentController.environment'
	currentRoomBinding: Ember.Binding.oneWay 'environmentController.currentRoom'
	
	navBarContent: [
		mode: 'move'
		i: 'icon-move'
		title: 'Move: Click and drag or swipe to move within the room.'
	,
		mode: 'edit'
		i: 'icon-pencil'
		title: 'Edit: Click/tap and drag to draw upon the current layer.'
	,
		noLink: true
		text: '|'
	,
		id: 'document-undo'
		noSelect: true
		i: 'icon-backward'
		title: 'Undo the last action.'
	,
		id: 'document-redo'
		noSelect: true
		i: 'icon-forward'
		title: 'Redo the last undone action.'
	,
		noLink: true
		text: '|'
	,
		id: 'document-zoom-out'
		noSelect: true
		i: 'icon-zoom-out'
		title: 'Zoom out from the room.'
	,
		id: 'document-zoom-in'
		noSelect: true
		i: 'icon-zoom-in'
		title: 'Zoom in to the room.'
	,
		noLink: true
		text: '|'
	,
		id: 'document-resize'
		noSelect: true
		i: 'icon-cog'
		title: 'Resize this room.'
	]
	navBarSelection: null
	navBarView: NavBarView
	
	# Convenience property to DRY up client usage of the active undo stack.
	undoStack: null
	
	undoGroup: null
	
	environmentObjectChanged: (->
		
		return unless (environmentObject = @get 'environment.object')?
		
		@set 'undoGroup', undoGroup = new UndoGroup()
		
		undoGroup.on 'activeStackChanged', (activeStack) =>
			@set 'undoStack', activeStack
		
		@undoStacks = for i in [0...environmentObject.roomCount()]
			new UndoStack undoGroup
			
	).observes 'environment.object'
	
	roomChanged: (->
		
		return unless (currentRoom = @get 'currentRoom')?
		return unless (undoGroup = @get 'undoGroup')?
		
		undoGroup.setActiveStack @undoStacks[currentRoom.index]
		
	).observes 'currentRoom', 'undoGroup'
	
	roomLayers: []
	
	roomLayersChanged: (->
		
		return unless (roomObject = @get 'currentRoom.object')?
		return unless (tilesetObject = @get 'environment.tileset.object')?
		
		canvasSize = Vector.mul(
			roomObject.size()
			tilesetObject.tileSize()
		)
		
		roomLayers = for i in [0...roomObject.layerCount()]
			Ember.Object.create
				
				index: i
				
				roomObject: roomObject
				tilesetObject: tilesetObject
				layerImage: null
				
				width: canvasSize[0]
				height: canvasSize[1]
				
				solo: false
				
		@set 'roomLayers', roomLayers
		
	).observes 'currentRoom.object', 'environment.tileset.object'

	updateLayerImage: (position, matrix, layerIndex) ->
		
		return unless (roomLayers = @get 'roomLayers')?
		return unless (tilesetObject = @get 'environment.tileset.object')?
		
		layerImage = roomLayers[layerIndex].layerImage
		tileSize = tilesetObject.tileSize()
		
		layerImage.drawFilledBox Rectangle.compose(
			Vector.mul tileSize, position
			Vector.mul tileSize, Matrix.sizeVector matrix
		), 0, 0, 0, 0
		
		for row, y in matrix
			
			for index, x in row
		
				tilesetObject.render(
					Vector.add(
						Vector.mul position, tileSize
						Vector.mul [x, y], tileSize
					)
					layerImage
					index
				) if index
				
		undefined
