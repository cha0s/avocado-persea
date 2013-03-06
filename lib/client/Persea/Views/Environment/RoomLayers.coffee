Image = require('Graphics').Image
Vector = require 'core/Extension/Vector'

module.exports = Ember.CollectionView.extend
	
	attributeBindings: ['unselectable']
	unselectable: 'on'
	
	itemViewClass: Ember.View.extend
		
		attributeBindings: ['unselectable', 'style']
		unselectable: 'on'
		
		style: (->
			
			index = @get 'content.index'
			
			"
z-index: #{index * 10};
	"
		).property 'content.index'
		
		layerStyle: (->
			
			roomObject = @get 'content.roomObject'
			tilesetObject = @get 'content.tilesetObject'
			
			canvasSize = Vector.scale(
				Vector.mul roomObject.size(), tilesetObject.tileSize()
				@get 'parentView.zoomRatio'
			)
			
			"
width: #{canvasSize[0]}px; height: #{canvasSize[1]}px; 
"
			
		).property 'parentView.zoomRatio'
		
		didInsertElement: ->
			
			$layer = @$()
			
			roomObject = @get 'content.roomObject'
			tilesetObject = @get 'content.tilesetObject'
			
			sizeInTiles = roomObject.size()
			tileIndices = roomObject.layer($layer.index()).tileIndices_
			tileSize = tilesetObject.tileSize()
			
			layer = new Image()
			layer.Canvas = $('canvas', $layer)[0]
			@set 'content.layerImage', layer
			
			# Render the layer, row by row.
			y = 0
			indexPointer = 0
			renderPosition = [0, 0]
			(renderTile = =>
				for x in [0...sizeInTiles[0]]
					if index = tileIndices[indexPointer++]
						tilesetObject.render(
							renderPosition
							layer
							index
						)
					
					renderPosition[0] += tileSize[0]
					
				renderPosition[0] = 0
				renderPosition[1] += tileSize[1]
				
				# Defer the next render until we get a tick from the VM, to
				# the browser's UI thread a chance to keep updating.
				_.defer renderTile if ++y < sizeInTiles[1]
			)()
		
		classNames: ['layer']
		template: Ember.Handlebars.compile """

<canvas
	unselectable="on"
	class="canvas"
	{{bindAttr width="view.content.width"}}
	{{bindAttr height="view.content.height"}}
	{{bindAttr style="view.layerStyle"}}
	{{bindAttr solo="view.content.solo"}}
>
</canvas>

"""

