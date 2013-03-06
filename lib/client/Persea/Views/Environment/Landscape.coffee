CoreService = require('Core').CoreService
NavBarView = require 'Persea/Views/Bootstrap/NavBar'
Rectangle = require 'core/Extension/Rectangle'
Swipey = require 'Swipey'
Vector = require 'core/Extension/Vector'

module.exports = Ember.View.extend
	
	environmentBinding: 'controller.environment'
	navBarContentBinding: 'controller.navBarContent'
	navBarSelectionBinding: 'controller.navBarSelection'
	soloBinding: 'controller.solo'
	swipey: null
	tilesetSelectionMatrixBinding: 'controller.tilesetSelectionMatrix'
	zoomMayDecreaseBinding: Ember.Binding.oneWay 'controller.zoomMayDecrease'
	zoomMayIncreaseBinding: Ember.Binding.oneWay 'controller.zoomMayIncrease'
	zoomRatioBinding: Ember.Binding.oneWay 'controller.zoomRatio'
	
	classNames: ['landscape']
	
	tileAt: (position) ->
		
		return unless (tilesetObject = @get 'environment.tileset.object')?
		
		tileSize = Vector.scale tilesetObject.tileSize(), @get 'zoomRatio'
		
		position = Vector.add position, [
			$(window).scrollLeft()
			$(window).scrollTop()
		]
		
		imagePosition = $('#tileset .image').position()
		
		tilesetOffset = $('#tileset').offset()
		
		Vector.div(
			Vector.add(
				Vector.scale(
					[imagePosition.left, imagePosition.top]
					-1
				)
				Vector.mul(
					Vector.floor Vector.div(
						Vector.sub(
							position
							[tilesetOffset.left, tilesetOffset.top]
						)
						tileSize
					)
					tileSize
				)
			)
			tileSize
		)
		
	updateSelectionDimensions: ->
		
		return unless (tilesetObject = @get 'environment.tileset.object')?
		
		tilesetSelectionMatrix = @get 'tilesetSelectionMatrix'
		
		tileSize = Vector.scale tilesetObject.tileSize(), @get 'controller.zoomRatio'
		
		position = $('#tileset .image').position()
		
		[left, top] = Vector.add(
			[
				position.left
				position.top
			]
			Vector.mul(
				Rectangle.position tilesetSelectionMatrix
				tileSize
			)
		)
		[width, height] = Vector.mul(
			Rectangle.size tilesetSelectionMatrix
			tileSize
		)
		
		$('#tileset .selection').css
			left: left
			top: top
			width: width
			height: height
			
	selectedMode: (->
		
		return unless (swipey = @get 'swipey')?
		
		switch @get 'navBarSelection.mode'
			
			when 'move'
				
				swipey.active = true
				
			when 'edit'
				
				swipey.active = false
		
	).observes 'navBarSelection'
	
	setSwipeyMinMax: (->
		
		return unless (tilesetObject = @get 'environment.tileset.object')?
		return unless (swipey = @get 'swipey')?
		
		area = Vector.scale tilesetObject.tileSize(), @get 'zoomRatio'
		
		swipey.area = area
		
		swipey.setMinMax(
			[0, 0]
			Vector.sub(
				tilesetObject.tiles()
				Vector.floor Vector.div(
					[256, 256]
					area
				)
			)
		)
		
	).observes 'environment.tileset.object', 'swipey', 'zoomRatio'
	
	tilesetStyle: (->
		
		$tileset = $ '#tileset'
		
		cursor = ''
		
		switch @get 'navBarSelection.mode'
			
			when 'move'
				
				cursor = 'move'
				
			when 'edit'
				
				cursor = 'default'
		
		if (@get 'environment.tileset.object')?
			"
cursor: #{cursor}; 
background: none;
"
		else
			"
cursor: #{cursor}; 
background-image: 
url(/app/node.js/persea/static/img/spinner.svg); 
background-size: contain;
"
		
	).property 'environment.tileset.object', 'navBarSelection'
	
	tilesetImageStyle: (->
		
		if (tilesetObject = @get 'environment.tileset.object')?
			
			size = Vector.scale tilesetObject.image().size(), @get 'zoomRatio'
			
			"
background-image: url(#{tilesetObject.image().src}); 
width: #{size[0]}px; 
height: #{size[1]}px; 
background-size: contain;
"
		else
			
			"
background: none;
"
		
	).property 'environment.tileset.object', 'zoomRatio'
	
	navBarView: NavBarView
	
	zoomMayDecreaseChanged: (->
		@$('#tileset-zoom-out').closest('li').toggleClass(
			'disabled'
			not @get 'zoomMayDecrease'
		)
	).observes 'zoomMayDecrease'
		
	zoomMayIncreaseChanged: (->
		@$('#tileset-zoom-in').closest('li').toggleClass(
			'disabled'
			not @get 'zoomMayIncrease'
		)
	).observes 'zoomMayIncrease'
		
	didInsertElement: ->
		
		controller = @get 'controller'
		
		$('#tileset-zoom-out, #tileset-zoom-in').each (i, elm) =>
			$(elm).click =>
				controller[['decreaseZoom', 'increaseZoom'][i]]()
				@updateSelectionDimensions()
		
		@set 'tilesetSelectionMatrix', [0, 0, 1, 1]
		
		# Reset the tileset selection.
		@updateSelectionDimensions()
		
		@zoomMayDecreaseChanged()
		@zoomMayIncreaseChanged()
		
		$tileset = $('#tileset')
		
		$('#tileset .selection').css opacity: .55, width: 16, height: 16
			
		(pulseSelection = ->
			$('#tileset .selection').animate
				opacity: .15
			,
				500
				->
					$('#tileset .selection').animate
						opacity: .55
					,
						500
						pulseSelection
		)()
		
		if Modernizr.touch
			
			$el = $tileset
			mousedown = 'vmousedown'
			mousemove = 'vmousemove'
			mouseup = 'vmouseup'
			
		else
			
			$el = $(window)
			mousedown = 'mousedown'
			mousemove = 'mousemove'
			mouseup = 'mouseup'
		
		$el.off '.environmentLandscapeTileset'
		
		holding = false
		
		$tileset.on(
			"#{mousedown}.environmentLandscapeTileset"
			(event) =>
				
				return if 'move' is @get 'navBarSelection.mode'
				
				holding = true
				
				# Recalculate the selection matrix as a 1x1 starting at the
				# selected tile.
				@set 'tilesetSelectionMatrix', Rectangle.compose(
					@selectionStart = @tileAt [event.clientX, event.clientY]
					[1, 1]
				)
				
				@updateSelectionDimensions()
					
				false
		)
		
		$el.on(
			"#{mouseup}.environmentLandscapeTileset"
			(event) =>
				
				return if 'move' is @get 'navBarSelection.mode'
				
				holding = false
				
				false
		)
		
		$el.on(
			"#{mousemove}.environmentLandscapeTileset"
			(event) =>
				
				return unless holding
				return if 'move' is @get 'navBarSelection.mode'
				return unless (tilesetObject = @get 'environment.tileset.object')?
				
				tileSize = tilesetObject.tileSize()
				
				# Recalculate the new selection matrix.
				tileAt = @tileAt [event.clientX, event.clientY]
				topLeft = Vector.min @selectionStart, tileAt
				bottomRight = Vector.max @selectionStart, tileAt
				@set 'tilesetSelectionMatrix', Rectangle.compose(
					topLeft
					Vector.add [1, 1], Vector.sub bottomRight, topLeft
				) 
				
				@updateSelectionDimensions()
				
				false
		)
		
		# Attach swiping behaviors to the tileset.
		swipey = new Swipey $tileset, [0, 0], 'tilesetSwipey'
		swipey.on 'update', (offset) =>
			
			return unless (tilesetObject = @get 'environment.tileset.object')?
			
			tileSize = tilesetObject.tileSize()
			
			# Update the tileset image offset.
			[left, top] = Vector.mul(
				offset
				Vector.scale(
					Vector.scale tileSize, -1
					@get 'zoomRatio'
				)
			)
			
			$('#tileset .image').css left: left, top: top
			
			@updateSelectionDimensions()
			
		@set 'swipey', swipey
		
		$solo = @$('.solo')
		$solo.change =>
			
			@set 'solo', $('input', $solo).attr('checked')?
			
			return true
		
		@set 'navBarSelection', @get('navBarContent')[0]
		
	template: Ember.Handlebars.compile """

<h3>Draw</h3>
<div class="draw">
	{{view Bootstrap.Forms.Select
		contentBinding="drawTools"
		optionLabelPath="content.label"
		selectionBinding="currentDrawTool"
		labelBinding="drawLabel"
	}}
</div>

<p class="upon">upon</p>

<div class="layers">
	{{view Bootstrap.Forms.Select
		contentBinding="layersContent"
		selectionBinding="currentLayerIndex"
		labelBinding="layersLabel"
	}}
</div>

<label class="checkbox inline solo">
	<input type="checkbox"> Solo
</label>

<h3>Tileset <small>({{environment.tileset.id}})</small></h3>

<div class="navbar">
	<div class="navbar-inner">
		{{view view.navBarView
			contentBinding="navBarContent"
			selectionBinding="navBarSelection"
		}}
	</div>	
</div>

<div {{bindAttr style="view.tilesetStyle"}} id="tileset" unselectable="on">
	<div {{bindAttr style="view.tilesetImageStyle"}} class="image">
	</div>
	<div class="selection"></div>
</div>

"""

