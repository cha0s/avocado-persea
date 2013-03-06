CoreService = require('Core').CoreService
Floodfill = require 'core/Utility/Floodfill'
Image = require('Graphics').Image
Matrix = require 'core/Extension/Matrix'
NavBarView = require 'Persea/Views/Bootstrap/NavBar'
Rectangle = require 'core/Extension/Rectangle'
RoomLayersView = require 'Persea/Views/Environment/RoomLayers'
Swipey = require 'Swipey'
UndoCommand = require 'Persea/Undo/Command'
UndoStack = require 'Persea/Undo/Stack'
UndoGroup = require 'Persea/Undo/Group'
Vector = require 'core/Extension/Vector'

module.exports = Ember.View.extend
	
	currentRoomBinding: Ember.Binding.oneWay 'controller.currentRoom'
	environmentControllerBinding: Ember.Binding.oneWay 'controller.environmentController'
	environmentBinding: Ember.Binding.oneWay 'controller.environment'
	landscapeControllerBinding: Ember.Binding.oneWay 'environmentController.landscapeController'
	navBarContentBinding: Ember.Binding.oneWay 'controller.navBarContent'
	navBarSelectionBinding: 'controller.navBarSelection'
	roomLayersBinding: Ember.Binding.oneWay 'controller.roomLayers'
	undoGroupBinding: Ember.Binding.oneWay 'controller.undoGroup'
	undoStackBinding: Ember.Binding.oneWay 'controller.undoStack'
	zoomMayDecreaseBinding: Ember.Binding.oneWay 'controller.zoomMayDecrease'
	zoomMayIncreaseBinding: Ember.Binding.oneWay 'controller.zoomMayIncrease'
	zoomRatioBinding: Ember.Binding.oneWay 'controller.zoomRatio'
	
	attributeBindings: ['unselectable']
	unselectable: 'on'
	
	handleResize: _.throttle(
		->
			
			return unless (roomObject = @get 'currentRoom.object')?
			return unless (tilesetObject = @get 'environment.tileset.object')?
			
			$el = $ '#environment-document'
			
			documentOffset = $el.offset()
			$row = $el.parent()
			rowOffset = $row.offset()
			tileSize = Vector.scale tilesetObject.tileSize(), @get 'zoomRatio'
			
			# Calcuate the maximum width and height that the layout will allow
			# for the canvas.
			width = $row.width() - (documentOffset.left - rowOffset.left)
			
			windowHeight = $(window).height()
			height = windowHeight
			height -= @$('.statusbar').outerHeight true
			unless height < $('#footer').offset().top
				height -= $('#footer').height()
			height -= documentOffset.top
			height = Math.max(
				320
				if height <= 0
					windowHeight - 40
				else
					height
			)
			
			# Shrink the canvas to fit a small room.
			canvasSize = Vector.min(
				[width, height]
				Vector.mul roomObject.size(), tileSize
			)
			
			# Quantize to tile size.
			size = Vector.mul(
				Vector.floor Vector.div(
					canvasSize
					tileSize
				)
				tileSize
			)
			
			$el.css
				width: size[0]
				height: size[1]
				
			# Remove the spinner.
			$el.parent().css
				background: 'none'
			
			@swipeyReset()
			
		75
	).observes 'currentRoom.object', 'environment.object', 'zoomRatio'
		
	drawOverlayStyle: (->
		
		return '' if 'move' is @get 'navBarSelection.mode'
		
		currentDrawTool = @get 'landscapeController.currentDrawTool'
		return "" unless (properties = currentDrawTool.drawOverlayStyle? this)?
		{width, height} = properties
		
		zoomRatio = @get 'zoomRatio'
		[width, height] = Vector.scale [width, height], zoomRatio
		
		currentLayerIndex = @get 'landscapeController.currentLayerIndex'
		zIndex = currentLayerIndex * 10 + 1
		
		"
width: #{width}px; height: #{height}px; 
z-index: #{zIndex};
"

	).property(
		'environment.object'
		'landscapeController.currentDrawTool'
		'landscapeController.currentLayerIndex'
		'landscapeController.tilesetSelectionMatrix'
		'navBarSelection.mode'
		'zoomRatio'
	)
	
	drawOverlayImageStyle: (->
		
		return '' if 'move' is @get 'navBarSelection.mode'
		
		return '' unless (tilesetObject = @get 'environment.tileset.object')?
		
		currentDrawTool = @get 'landscapeController.currentDrawTool'
		return "" unless (properties = currentDrawTool.drawOverlayStyle? this)?
		{top, left} = properties
		
		zoomRatio = @get 'zoomRatio'
		
		imageSize = Vector.scale tilesetObject.image().size(), zoomRatio
		[left, top] = Vector.scale [left, top], zoomRatio
		
		"
width: #{imageSize[0]}px; height: #{imageSize[1]}px; 
top: #{top}px; left: #{left}px;
"

	).property(
		'environment.tileset.object'
		'landscapeController.currentDrawTool'
		'landscapeController.currentLayerIndex'
		'landscapeController.tilesetSelectionMatrix'
		'navBarSelection.mode'
		'zoomRatio'
	)
	
	drawOverlayImgStyle: (->
		
		return '' if 'move' is @get 'navBarSelection.mode'
		
		return '' unless (tilesetObject = @get 'environment.tileset.object')?
		
		currentDrawTool = @get 'landscapeController.currentDrawTool'
		return "" unless (properties = currentDrawTool.drawOverlayStyle? this)?
		{top, left} = properties
		
		imageSize = Vector.scale tilesetObject.image().size(), @get 'zoomRatio'
		
		"
width: #{imageSize[0]}px; height: #{imageSize[1]}px; 
"

	).property(
		'environment.tileset.object'
		'landscapeController.currentDrawTool'
		'landscapeController.currentLayerIndex'
		'landscapeController.tilesetSelectionMatrix'
		'navBarSelection.mode'
		'zoomRatio'
	)
	
	drawOverlayImgSrc: (->
		
		return '/app/node.js/persea/static/img/spinner.svg' if 'move' is @get 'navBarSelection.mode'
		
		currentDrawTool = @get 'landscapeController.currentDrawTool'
		return '/app/node.js/persea/static/img/spinner.svg' unless (properties = currentDrawTool.drawOverlayStyle? this)?
		{imageUrl} = properties
		
		imageUrl
		
	).property(
		'environment.object'
		'landscapeController.currentDrawTool'
		'landscapeController.currentLayerIndex'
		'landscapeController.tilesetSelectionMatrix'
		'navBarSelection.mode'
	)
	
	soloChanged: (->
		
		currentLayerIndex = @get 'landscapeController.currentLayerIndex'
		roomLayers = @get 'roomLayers'
		solo = @get 'landscapeController.solo'
		
		if solo
			
			for roomLayer, index in roomLayers
				roomLayer.set 'solo', currentLayerIndex isnt index
			
		else
			roomLayer.set 'solo', false for roomLayer in roomLayers
			
	).observes(
		'landscapeController.currentLayerIndex'
		'landscapeController.solo'
		'roomLayers'
	)
	
	undoGroupChanged: (->
		
		return unless (undoGroup = @get 'undoGroup')?
		
		undoGroup.on 'canUndoChanged', (canUndo) ->
			$('#document-undo').closest('li').toggleClass(
				'disabled'
				not canUndo
			)
		
		undoGroup.on 'canRedoChanged', (canRedo) ->
			$('#document-redo').closest('li').toggleClass(
				'disabled'
				not canRedo
			)
		
	).observes 'undoGroup'
	
	undoStackChanged: (->
		
		return unless (undoStack = @get 'undoStack')?
		
		$('#document-undo, #document-redo').each (i, elm) =>
			$(elm).closest('li').toggleClass(
				'disabled', not undoStack?["can#{['Undo', 'Redo'][i]}"]()
			)
			
	).observes 'undoStack'
	
	selectedModeChanged: (->
		
		return unless (swipey = @get 'swipey')?
		
		$environmentDocument = $('#environment-document')
		
		switch @get 'navBarSelection.mode'
			
			when 'move'
				
				swipey.active = true
				$environmentDocument.css cursor: 'move'
				
			when 'edit'
				
				swipey.active = false
				$environmentDocument.css cursor: 'default'
		
	).observes 'navBarSelection'
	
	swipeyReset: (->
		
		return unless (roomObject = @get 'currentRoom.object')?
		return unless (swipey = @get 'swipey')?
		return unless (tilesetObject = @get 'environment.tileset.object')?
		
		$environmentDocument = $('#environment-document')
		
		area = Vector.scale tilesetObject.tileSize(), @get 'zoomRatio'
		swipey.area = area
		
		swipey.setMinMax(
			[0, 0]
			Vector.sub(
				roomObject.size()
				Vector.floor Vector.div(
					[
						$environmentDocument.width()
						$environmentDocument.height()
					]
					area
				)
			)
		)
		
	).observes 'currentRoom.object', 'environment.tileset.object', 'swipey', 'zoomRatio'

	swipeyPositionReset: (->
		
		return unless (roomObject = @get 'currentRoom.object')?
		return unless (swipey = @get 'swipey')?
		return unless (tilesetObject = @get 'environment.tileset.object')?
		
		swipey.setOffset [0, 0]
		
	).observes 'currentRoom.object', 'environment.tileset.object', 'swipey'

	positionTranslatedToTile: (position) ->
		
		return [0, 0] unless (tilesetObject = @get 'environment.tileset.object')?
		
		$environmentDocument = $('#environment-document')
		offset = $environmentDocument.offset()
		
		position = Vector.sub(
			Vector.add(
				position
				[$(window).scrollLeft(), $(window).scrollTop()]
			)
			[offset.left, offset.top]
		)
		
		position = Vector.floor Vector.div(
			position
			Vector.scale tilesetObject.tileSize(), @get 'zoomRatio'
		)
		
	positionTranslatedToLayer: (position) ->
		
		return [0, 0] unless (swipey = @get 'swipey')?
		
		position = @positionTranslatedToTile position
		
		position = Vector.add position, swipey.offset()
		
	positionTranslatedToOverlay: (position) ->
		
		return [0, 0] unless (tilesetObject = @get 'environment.tileset.object')?
				
		position = @positionTranslatedToTile position
		
		position = Vector.mul position, Vector.scale tilesetObject.tileSize(), @get 'zoomRatio'
		
	tileMatrixFromSelectionMatrix: (selectionMatrix) ->
		
		return [[0]] unless (selectionMatrix = @get 'landscapeController.tilesetSelectionMatrix')?
		return [[0]] unless (tilesetObject = @get 'environment.tileset.object')?
		
		index = selectionMatrix[1] * tilesetObject.tiles()[0] + selectionMatrix[0]
		
		tileMatrix = []
		for y in [0...selectionMatrix[3]]
			
			row = []
			tileMatrix.push row
			
			for x in [0...selectionMatrix[2]]
				
				tileIndex = index + y * tilesetObject.tiles()[0] + x
				
				row.push tileIndex
				
		tileMatrix
	
	commitDrawCommands: ->
		
		return if (drawCommands = @get 'drawCommands').length is 0
		return unless (undoStack = @get 'undoStack')?		
		
		draws = _.map drawCommands, _.identity
		
		ranFirstRedo = false
		
		undoStack.push new class extends UndoCommand
			
			undo: ->
				
				for i in [draws.length - 1..0]
					draw = draws[i]
					
					draw.undo()
			
			redo: ->
				
				if ranFirstRedo

					for draw in draws
						
						draw.redo()
						
				ranFirstRedo = true
		
	zoomMayDecreaseChanged: (->
		@$('#document-zoom-out').closest('li').toggleClass(
			'disabled'
			not @get 'zoomMayDecrease'
		)
	).observes 'zoomMayDecrease'
		
	zoomMayIncreaseChanged: (->
		@$('#document-zoom-in').closest('li').toggleClass(
			'disabled'
			not @get 'zoomMayIncrease'
		)
	).observes 'zoomMayIncrease'
	
	resizeRoom: (newSize) ->

		return unless (roomObject = @get 'currentRoom.object')?
		return unless (undoStack = @get 'undoStack')?		
		
		commandGenerator = (size, layers) =>
			
			=>
		
				roomObject.size_ = size
				roomObject.layers_ = layers
			
				@beginPropertyChanges()
				
				@set 'currentRoom.object', null
				@set 'currentRoom.object', roomObject
				
				@endPropertyChanges()

		undo = commandGenerator(
			Vector.copy roomObject.size()
			layer.copy() for layer in roomObject.layers_
		)
		
		redo = commandGenerator(
			newSize
			layer.copy().resize newSize for layer in roomObject.layers_
		)
		
		undoStack.push new class extends UndoCommand
			
			redo: redo
			undo: undo
		
	didInsertElement: ->
		
		controller = @get 'controller'
		
		$('#document-undo, #document-redo').each (i, elm) =>
			$(elm).click =>
				(@get 'undoStack')?[['undo', 'redo'][i]]()
				false

		controller.roomChanged()
		
		@zoomMayDecreaseChanged()
		@zoomMayIncreaseChanged()
		
		$('#document-resize').click =>
			
			return unless (roomObject = @get 'currentRoom.object')?
			
			$('#resize-modal .width').val roomObject.width()
			$('#resize-modal .height').val roomObject.height()
			
			$('#resize-modal').modal('show')    
		
		$('#resize-modal .btn-primary').click =>
			
			@resizeRoom [
				+$('#resize-modal .width').val()
				+$('#resize-modal .height').val()
			]
			
			$('#resize-modal').modal('hide')
		
		$('#document-resize')
			.attr href: '#resize-modal', role: 'button', 'data-toggle': 'modal'
		
		$environmentDocument = $('#environment-document')
		
		$('.draw-overlay', $environmentDocument).css opacity: .85, width: 16, height: 16
		(pulseOverlay = ->
			$('.draw-overlay', $environmentDocument).animate
				opacity: .45
			,
				500
				->
					$('.draw-overlay', $environmentDocument).animate
						opacity: .85
					,
						500
						pulseOverlay
		)()
		
		if Modernizr.touch
			
			$el = $environmentDocument
			mousedown = 'vmousedown'
			mousemove = 'vmousemove'
			mouseout = 'vmouseout'
			mouseover = 'vmouseover'
			mouseup = 'vmouseup'
			
		else
			
			$el = $(window)
			mousedown = 'mousedown'
			mousemove = 'mousemove'
			mouseout = 'mouseout'
			mouseover = 'mouseover'
			mouseup = 'mouseup'
		
		$el.off '.environmentDocument'
		
		$('#document-zoom-in').click ->
			controller.increaseZoom()
		
		$('#document-zoom-out').click ->
			controller.decreaseZoom()
		
		holding = false
		
		$environmentDocument.on(
			"#{mousedown}.environmentDocument"
			(event) =>
				
				return if 'move' is @get 'navBarSelection.mode'
				
				@set 'drawing', true
				@set 'drawCommands', []
				
				currentDrawTool = @get 'landscapeController.currentDrawTool'
				currentDrawTool.eventHandler['mousedown']?.call currentDrawTool, event, this
				
				false
		)
		
		$environmentDocument.on(
			"#{mousemove}.environmentDocument"
			(event) =>
				
				onTile = @positionTranslatedToLayer [event.clientX, event.clientY]
				@$('.on-tile').text "[#{onTile[0]}, #{onTile[1]}]"
				
				return if 'move' is @get 'navBarSelection.mode'
				
				currentDrawTool = @get 'landscapeController.currentDrawTool'
				currentDrawTool.eventHandler['mousemove']?.call currentDrawTool, event, this
				
				false
		)
		
		$el.on(
			"#{mouseup}.environmentDocument"
			(event) =>
				
				return if 'move' is @get 'navBarSelection.mode'
				
				return unless @get 'drawing'
				
				currentDrawTool = @get 'landscapeController.currentDrawTool'
				currentDrawTool.eventHandler['mouseup']?.call currentDrawTool, event, this
				
				@commitDrawCommands()
				
				@set 'drawing', false
				
				false
		)
		
		$environmentDocument.on(
			"#{mouseout}.environmentDocument"
			(event) =>
				
				return if 'move' is @get 'navBarSelection.mode'
				
				@$('.draw-overlay').hide()
				
				currentDrawTool = @get 'landscapeController.currentDrawTool'
				currentDrawTool.eventHandler['mouseout']?.call currentDrawTool, event, this
				
				false
		)
		
		$environmentDocument.on(
			"#{mouseover}.environmentDocument"
			(event) =>
				
				return if 'move' is @get 'navBarSelection.mode'
				
				@$('.draw-overlay').show()
				
				currentDrawTool = @get 'landscapeController.currentDrawTool'
				currentDrawTool.eventHandler['mouseover']?.call currentDrawTool, event, this
				
				false
		)
		
		# Attach swiping behaviors to the tileset.
		swipey = new Swipey $environmentDocument, [1, 1], 'environmentSwipey'
		swipey.on 'update', (offset) =>
			
			return unless (tilesetObject = @get 'environment.tileset.object')?
			
			tileSize = tilesetObject.tileSize()
			
			# Update the layer image offset.
			[left, top] = Vector.mul(
				offset
				Vector.scale(
					Vector.scale tileSize, @get 'zoomRatio'
					-1
				)
			)
			
			$('.layers', $environmentDocument).css left: left, top: top
			
		@set 'swipey', swipey
		
		offset = $environmentDocument.offset()
		
		windowHeight = $(window).height()
		
		autoCanvasHeight = windowHeight
		
		footerOffset = $('#footer').offset()
		unless autoCanvasHeight < footerOffset.top
			autoCanvasHeight -= $('#footer').height()
		
		autoCanvasHeight -= offset.top
		
		autoCanvasHeight = Math.max(
			320
			autoCanvasHeight
		)
		
		height = Math.max(
			320
			if autoCanvasHeight <= 0
				windowHeight - 40
			else
				autoCanvasHeight
		)
		
		$environmentDocument.css
			height: height
			
		$environmentDocument.parent().css
			background: "url('/app/node.js/persea/static/img/spinner.svg') center no-repeat"
			'background-size': 'contain'
		
		@handleResize()
		$(window).resize =>
			@handleResize()
			
		@set 'navBarSelection', @get('navBarContent')[0]
		
	roomLayersView: RoomLayersView
	
	template: Ember.Handlebars.compile """

<div class="navbar">
	<div class="navbar-inner">
		{{view navBarView
			contentBinding="navBarContent"
			selectionBinding="navBarSelection"
		}}
	</div>	
</div>

<div id="resize-modal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="resize-modal-label" aria-hidden="true">
	<div class="modal-header">
		<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
		<h3 id="resize-modal-label">Resize room</h3>
	</div>
	<div class="modal-body">
		<label>Width</label>
		<div class="input-append">
			{{view Ember.TextField class="width input-mini" type="number" valueBinding="tileWidth"}}
			<span class="add-on">px</span>
		</div>
		
		<label>Height</label>
		<div class="input-append">
			{{view Ember.TextField class="height input-mini" type="number" valueBinding="tileHeight"}}
			<span class="add-on">px</span>
		</div>		
	</div>
	<div class="modal-footer">
		<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
		<button class="btn btn-primary">Lock it in</button>
	</div>
</div>

<div id="environment-document">
	<div class="draw-overlay" {{bindAttr style="view.drawOverlayStyle"}} >
		<div class="image"
			{{bindAttr style="view.drawOverlayImageStyle"}}
		>
			<img
				{{bindAttr style="view.drawOverlayImgStyle"}}
				{{bindAttr src="view.drawOverlayImgSrc"}}
			/>
		</div>
	</div>
	
	{{view view.roomLayersView
		class="layers"
		contentBinding="roomLayers"
		zoomRatioBinding="zoomRatio"
	}}
	
</div>

<div class="well well-small statusbar">
<strong>Tile:</strong>
<span class="on-tile">[N/A, N/A]</span>
</div>

"""
