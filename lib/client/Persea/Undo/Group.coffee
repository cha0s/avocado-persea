EventEmitter = require 'core/Utility/EventEmitter'
Mixin = require 'core/Utility/Mixin'

module.exports = class

	constructor: ->
		
		Mixin this, EventEmitter
		
		@stacks_ = []
		@activeStackIndex_ = -1
	
	_canRedoChanged: (canRedo) -> @emit 'canRedoChanged', canRedo
	
	_canUndoChanged: (canUndo) -> @emit 'canUndoChanged', canUndo
	
	_findStackIndex: (stack) -> @stacks_.indexOf stack
	
	_setActiveStackIndex: (index) ->
		
		@activeStackIndex_ = index
		
		@emit 'activeStackChanged', @activeStack()
	
	activeStack: -> @stacks_[@activeStackIndex_]
	
	addStack: (stack) ->
		
		stack.on 'canRedoChanged', @_canRedoChanged, this
		stack.on 'canUndoChanged', @_canUndoChanged, this
		
		@stacks_.push stack
	
	canRedo: -> @activeStack()?.canRedo()
	
	canUndo: -> @activeStack()?.canUndo()
	
	redo: -> @activeStack()?.redo()
	
	removeStack: (stack) ->
		
		activeStack = @activeStack()
		
		removedStackIndex = @_findStackIndex stack
		removedStack = @stacks_[removedStackIndex]
		
		@_setActiveStackIndex -1 if removedStack if activeStack
		
		removedStack.off 'canRedoChanged', @_canRedoChanged
		removedStack.off 'canUndoChanged', @_canUndoChanged
		
		delete @stacks_[removedStackIndex]
		
	setActiveStack: (stack) ->
		
		activeStackIndex = @_findStackIndex stack
		
		return unless @stacks_[activeStackIndex]?
		
		@_setActiveStackIndex activeStackIndex
		
	stacks: -> @stacks_

	undo: -> @activeStack()?.undo()
