EventEmitter = require 'core/Utility/EventEmitter'
Mixin = require 'core/Utility/Mixin'

module.exports = class
	
	constructor: (@group_) ->
		
		Mixin this, EventEmitter
		
		@stack_ = []
		@stackIndex_ = -1
		
		@group_?.addStack this
	
	canRedo: -> @stackIndex_ isnt @stack_.length - 1
	
	canUndo: -> @stackIndex_ isnt -1
		
	push: (command) ->
		
		canRedo = @canRedo()
		canUndo = @canUndo()
		
		@stackIndex_ += 1
		@stack_.length = @stackIndex_ + 1
		
		@stack_[@stackIndex_] = command
		
		command.redo()
		
		@emit 'canUndoChanged', @canUndo() unless canUndo
		@emit 'canRedoChanged', @canRedo() if canRedo
		
	redo: ->
		
		return unless @canRedo()
		
		canUndo = @canUndo()
		
		@stack_[++@stackIndex_].redo()

		@emit 'canRedoChanged', @canRedo() unless @canRedo()
		@emit 'canUndoChanged', @canUndo() unless canUndo
	
	setActive: -> @group_?.setActiveStack this
		
	undo: ->
		
		return unless @canUndo()
		
		canRedo = @canRedo()
		
		@stack_[@stackIndex_--].undo()
		
		@emit 'canRedoChanged', @canRedo() unless canRedo
		@emit 'canUndoChanged', @canUndo() unless @canUndo()
		