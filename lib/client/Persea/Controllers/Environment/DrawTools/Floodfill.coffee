Floodfill = require 'core/Utility/Floodfill'
Matrix = require 'core/Extension/Matrix'
Vector = require 'core/Extension/Vector'

# Can be moved back inline as a closure when the issue here is solved:
# https://github.com/emberjs/ember.js/issues/1621
LayerFloodfill = class extends Floodfill
	
	constructor: (
		@areaSize
		@unitSize
		@layer
		@matrix
		@currentLayerIndex
		@controller
	) ->
		super @areaSize, @unitSize
	
	valueEquals: Matrix.equals
		
	value: (x, y) ->
		
		@layer.tileMatrix(
			Matrix.sizeVector @matrix
			[x, y]
		)
	
	setValue: (x, y, matrix) ->
		
		@layer.setTileMatrix @matrix, [x, y]
		
		@controller.updateLayerImage [x, y], @matrix, @currentLayerIndex

module.exports = Ember.Object.create
	
	label: 'Floodfill'
	
	draw: (position, documentView) ->
		
		return unless (drawCommands = documentView.get 'drawCommands')?
		return unless (roomObject = documentView.get 'currentRoom.object')?
		return unless (tilesetObject = documentView.get 'environment.tileset.object')?
		
		controller = documentView.get 'controller'
		currentLayerIndex = documentView.get 'landscapeController.currentLayerIndex'
		layer = roomObject.layer currentLayerIndex
		position = documentView.positionTranslatedToLayer position
		selectionMatrix = documentView.tileMatrixFromSelectionMatrix()
		tileMatrix = layer.tileMatrix(
			Matrix.sizeVector selectionMatrix
			position
		)
		tileSize = tilesetObject.tileSize()
		
		oldMatrix = layer.tileMatrix(
			roomObject.size()
			[0, 0]
		)

		floodfill = new LayerFloodfill(
			roomObject.size()
			Matrix.sizeVector selectionMatrix
			layer, selectionMatrix, currentLayerIndex, controller
		)
		floodfill.fillAt position[0], position[1], selectionMatrix
	
		newMatrix = layer.tileMatrix(
			roomObject.size()
			[0, 0]
		)
		
		drawCommands.push
			position: position
			
			undo: ->
				layer.setTileMatrix oldMatrix, [0, 0]
				controller.updateLayerImage [0, 0], oldMatrix, currentLayerIndex
			redo: ->
				layer.setTileMatrix newMatrix, [0, 0]
				controller.updateLayerImage [0, 0], newMatrix, currentLayerIndex
	
	setOverlayPosition: (documentView, position) ->
		
		documentView.$('.draw-overlay').css
			left: position[0]
			top: position[1]
	
	drawOverlayStyle: (documentController) ->
		
		return unless (matrix = documentController.get 'landscapeController.tilesetSelectionMatrix')?
		return unless (tilesetObject = documentController.get 'environment.tileset.object')?
		
		tileSize = tilesetObject.tileSize()
		
		left: tileSize[0] * -matrix[0]
		top: tileSize[1] * -matrix[1]
		width: tileSize[0] * matrix[2]
		height: tileSize[1] * matrix[3]
		imageUrl: tilesetObject.image().src
		
	eventHandler:
		
		mousedown: (event, documentView) ->
			
			@draw [event.clientX, event.clientY], documentView
						
		mousemove: (event, documentView) ->
			
			@setOverlayPosition documentView, documentView.positionTranslatedToOverlay [event.clientX, event.clientY]
