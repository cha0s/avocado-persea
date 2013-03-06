
EventEmitter = require 'core/Utility/EventEmitter'
Mixin = require 'core/Utility/Mixin'
Transition = require 'core/Utility/Transition'
Vector = require 'core/Extension/Vector'

module.exports = class
	
	constructor: (
		@el
		@area
		@namespace = 'swipey'
	) ->
		
		Mixin this, EventEmitter
		
		@detach()
		
		@active = true

		swipeOffset = [0, 0]
		swipeOffset.x = -> @[0]
		swipeOffset.setX = (x) -> @[0] = x
		swipeOffset.y = -> @[1]
		swipeOffset.setY = (y) -> @[1] = y
		Mixin swipeOffset, Transition
		
		@setArea = (@area) ->
		
		swiping = null
		
		holding = false
		holdStartPosition = [0, 0]
		holdStartOffset = [0, 0]
		
		@setMinMax = (@min, @max) =>
			
			clamped = Vector.clamp swipeOffset, @min, @max
			swipeOffset[i] = clamped[i] for i in [0..1]
			
			@emit 'update', swipeOffset
		
		@setOffset = (offset) ->
			swipeOffset[0] = offset[0]
			swipeOffset[1] = offset[1]
		
		@offset = -> Vector.floor swipeOffset
		
		@setMinMax [0, 0], [0, 0]
		
		if Modernizr.touch
			
			$el = $(@el)
			mousedown = 'vmousedown'
			mousemove = 'vmousemove'
			mouseup = 'vmouseup'
			
		else
			
			$el = $(window)
			mousedown = 'mousedown'
			mousemove = 'mousemove'
			mouseup = 'mouseup'
		
		$el.on(
			"#{mouseup}.#{@namespace}"
			=>
				return true unless @active
				
				holding = false
				
				true
			
		)
		
		$el.on(
			"#{mousemove}.#{@namespace}"
			(event) =>
				
				return true unless @active
				
				if holding
					
					position = [event.clientX, event.clientY]
					delta = Vector.sub position, holdStartPosition
					delta = Vector.floor Vector.div delta, Vector.scale @area, -1
					
					offset = Vector.clamp(
						Vector.add delta, holdStartOffset
						@min
						@max
					)
					
					swipeOffset[i] = offset[i] for i in [0..1]
					
					@emit 'update', @offset()
					
				false
					
		)
		
		$(@el).on(
			"#{mousedown}.#{@namespace}"
			(event) =>
				
				return true unless @active
				
				swiping?.stopTransition()
				
				holding = true
				holdStartPosition = [event.clientX, event.clientY]
				holdStartOffset = Vector.copy swipeOffset
				
				false
				
		)
		
		$(@el).on(
			"swipe.#{@namespace}"
			(event, delta) =>
				return true unless @active
				
				dp = []
				
				for i in [0..1]
					
					delta[i] = delta.end.coords[i] - delta.start.coords[i]
					
					dp[i] = if delta[i] < 0 then 1 else -1
					
					delta[i] = Math.pow(
						Math.abs delta[i]
						1.2
					)
				
				delta = Vector.floor Vector.div delta, @area
				delta = Vector.mul delta, dp
				
				destination = Vector.clamp(
					Vector.add delta, swipeOffset
					@min
					@max
				)
				
				swiping = swipeOffset.transition(
					x: destination[0]
					y: destination[1]
				,
					500
				)
				
				update = => @emit 'update', @offset()
				
				swiping.defer.then(
					update
					->
					update
				)
		)
		
	detach: ->
	
		if Modernizr.touch
			
			$el = $(@el)
			
		else
			
			$el = $(window)
			
		$el.off ".#{@namespace}"
		$(@el).off ".#{@namespace}"
