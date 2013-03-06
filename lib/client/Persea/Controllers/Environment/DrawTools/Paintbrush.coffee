Matrix = require 'core/Extension/Matrix'
Vector = require 'core/Extension/Vector'

module.exports = Ember.Object.create
	
	label: 'Paintbrush'
	
	draw: (position, documentView) ->
		
		return unless (drawCommands = documentView.get 'drawCommands')?
		return unless (roomObject = documentView.get 'currentRoom.object')?
		
		controller = documentView.get 'controller'
		currentLayerIndex = documentView.get 'landscapeController.currentLayerIndex'
		layer = roomObject.layer currentLayerIndex
		position = documentView.positionTranslatedToLayer position
		selectionMatrix = documentView.tileMatrixFromSelectionMatrix()
		tileMatrix = layer.tileMatrix(
			Matrix.sizeVector selectionMatrix
			position
		)
		
		hasDraw = _.find drawCommands, (draw) ->
			
			Vector.equals draw.position, position
		
		oldMatrix = layer.tileMatrix(
			Matrix.sizeVector selectionMatrix
			position
		)
		
		controller.updateLayerImage position, selectionMatrix, currentLayerIndex
		layer.setTileMatrix selectionMatrix, position
		
		newMatrix = layer.tileMatrix(
			Matrix.sizeVector selectionMatrix
			position
		)
		
		unless hasDraw?
		
			drawCommands.push
				position: position
				
				undo: ->
					layer.setTileMatrix oldMatrix, position
					controller.updateLayerImage position, oldMatrix, currentLayerIndex
				redo: ->
					layer.setTileMatrix newMatrix, position
					controller.updateLayerImage position, newMatrix, currentLayerIndex

	setOverlayPosition: (documentView, position) ->
		
		documentView.$('.draw-overlay').css
			left: position[0]
			top: position[1]
	
	drawOverlayStyle: (documentView) ->
		
		return unless (matrix = documentView.get 'landscapeController.tilesetSelectionMatrix')?
		return unless (tilesetObject = documentView.get 'environment.tileset.object')?
		
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
			
			return unless documentView.get 'drawing'
			
			@draw [event.clientX, event.clientY], documentView
