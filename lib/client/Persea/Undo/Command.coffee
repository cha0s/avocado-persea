
module.exports = class
	
	constructor: ->
		
		@text_ = 'Unnamed command'
		
	text: -> @text_
	setText: (@text_) ->
	
	redo: -> throw new Error 'Undo command did not implement redo()'
	undo: -> throw new Error 'Undo command did not implement undo()'
	