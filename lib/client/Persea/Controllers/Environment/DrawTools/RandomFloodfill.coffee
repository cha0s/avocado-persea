Floodfill = require 'core/Utility/Floodfill'
Matrix = require 'core/Extension/Matrix'
Vector = require 'core/Extension/Vector'

# Can be moved back inline as a closure when the issue here is solved:
# https://github.com/emberjs/ember.js/issues/1621
LayerRandomFloodfill = class extends Floodfill
	
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
			[1, 1]
			[x, y]
		)
	
	setValue: (x, y, unused) ->
		
		column = Math.floor @matrix.length * Math.random()
		row = Math.floor @matrix[0].length * Math.random()
		
		value = [[@matrix[column][row]]]
		
		@layer.setTileMatrix value, [x, y]
		
		@controller.updateLayerImage [x, y], value, @currentLayerIndex

module.exports = Ember.Object.create
	
	init: ->
		
		@shuffleInterval = null
	
	label: 'Random floodfill'
	
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

		floodfill = new LayerRandomFloodfill(
			roomObject.size()
			[1, 1]
			layer, selectionMatrix, currentLayerIndex, controller
		)
		
		index = if 1 is Matrix.size selectionMatrix then selectionMatrix[0][0] else -1
		floodfill.fillAt position[0], position[1], index
	
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
		
		clearInterval @shuffleInterval if @shuffleInterval?
		@shuffleInterval = setInterval(
			=>
				return unless this is documentController.get 'landscapeController.currentDrawTool'
				
				left = tileSize[0] * -(matrix[0] + Math.floor Math.random() * matrix[2])
				top = tileSize[1] * -(matrix[1] + Math.floor Math.random() * matrix[3])
				
				documentController.$('.draw-overlay .image').css
					top: "#{top}px";
					left: "#{left}px";
				
			100
		)
		
		left: tileSize[0] * -matrix[0]
		top: tileSize[1] * -matrix[1]
		width: tileSize[0]
		height: tileSize[1]
		imageUrl: tilesetObject.image().src
		
	eventHandler:
		
		mousedown: (event, documentView) ->
			
			@draw [event.clientX, event.clientY], documentView
						
		mousemove: (event, documentView) ->
			
			@setOverlayPosition documentView, documentView.positionTranslatedToOverlay [event.clientX, event.clientY]
