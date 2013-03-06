
PerseaModel = module.exports = DS.Model.extend
	
	objectProperties: []
	commit: ->
	commitDelay: 2000
	
	init: ->
		
		@_super()
		
		for propertyKey in @get 'objectProperties'
			
			@addObserver propertyKey, this, '_loadObject'
			@addObserver propertyKey, this, '_synchronizeObject'
		
		@updateCommitDelay()
		
		return
	
	fetching: (->
		
		object = @get 'object'
		id = @get 'id'
		
		if object? then '' else "Fetching #{id} from server..."
		
	).property 'object'
	
	updateCommitDelay: (->
		
		@set 'commit', _.debounce(
			-> @store.commit()
			@get 'commitDelay'
		)
		
	).observes 'commitDelay'
		
	_loadObject: ->
		
		for propertyKey in @get 'objectProperties'
			return unless @get propertyKey
		
		@get('loadObject')?.call this
		
	_synchronizeObject: ->
		
		return unless (object = @get 'object')?
		
		@commit()
		
		@get('synchronizeObject')?.call this
