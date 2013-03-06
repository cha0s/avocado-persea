
module.exports = Ember.Mixin.create
	
	zoomLevel: 100
	
	minZoom: 25
	
	maxZoom: 400
	
	decreaseZoom: ->
		
		@set 'zoomLevel', Math.max @get('zoomLevel') / 2, @get 'minZoom'
	
	increaseZoom: ->
		
		@set 'zoomLevel', Math.min @get('zoomLevel') * 2, @get 'maxZoom'
	
	zoomMayDecrease: (->
		
		@get('zoomLevel') isnt @get 'minZoom'
		
	).property 'zoomLevel'
	
	zoomMayIncrease: (->
		
		@get('zoomLevel') isnt @get 'maxZoom'
		
	).property 'zoomLevel'
	
	zoomRatio: (->
		
		@get('zoomLevel') / 100
		
	).property 'zoomLevel'
