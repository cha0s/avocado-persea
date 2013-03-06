Vector = require 'core/Extension/Vector'
Zoom = require 'Persea/Mixins/Zoom'

module.exports = Ember.Controller.extend Zoom,
	
	environmentBinding: 'environmentController.environment'
	
	navBarContent: [
		mode: 'move'
		i: 'icon-move'
		title: 'Move: Click and drag or swipe to move the tileset.'
	,
		mode: 'edit'
		i: 'icon-pencil'
		title: 'Edit: Click/tap and drag to select tiles.'
	,
		noLink: true
		text: '|'
	,
		id: 'tileset-zoom-out'
		noSelect: true
		i: 'icon-zoom-out'
		title: 'Zoom out from the environment.'
	,
		id: 'tileset-zoom-in'
		noSelect: true
		i: 'icon-zoom-in'
		title: 'Zoom in to the environment.'
	]
	navBarSelection: null
	
	drawLabel: 'With'
	drawTools: []
	currentDrawTool: null
	
	layersLabel: 'Layer'
	layersContent: [0, 1, 2, 3, 4]
	currentLayerIndex: 0
	
	solo: false
	
	_initDrawTools: ->
		
		drawTools = for drawTool in [
			'Paintbrush'
			'Floodfill'
			'RandomFloodfill'
		]
			
			require "Persea/Controllers/Environment/DrawTools/#{drawTool}"
			
		@set 'drawTools', drawTools
		@set 'currentDrawTool', drawTools[0]
	
	init: ->
		
		@_initDrawTools()
