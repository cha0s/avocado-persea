
###
	
	Thanks bentjanderson! https://gist.github.com/4360857
	
	A Socket.IO adapter for ember-data.
	
	Requires ember.js and ember-data.js, socket.io
	
###

FIND        = 'find'
FIND_MANY   = 'findMany'
FIND_QUERY  = 'findQuery'
FIND_ALL    = 'findAll'
CREATE  	= 'create'
CREATES		= 'creates'
UPDATE		= 'update'
UPDATES		= 'updates'
DELETE		= 'delete'
DELETES		= 'deletes'

Transforms =

	serialized:
		
		deserialize: (serialized) ->
			
			if Ember.isNone serialized
				null
			else
				JSON.stringify serialized
			
		serialize: (deserialized) ->
			
			if Ember.isNone deserialized
				null
			else
				JSON.parse deserialized
	
	passthru:
		
		deserialize: (serialized) ->
			
			serialized
			
		serialize: (deserialized) ->
			
			deserialized
	
Transforms[key] = value for key, value of DS.JSONTransforms
	
exports.Serializer = SomberSerializer = DS.JSONSerializer.extend
	
	transforms: Transforms

exports.Adapter = DS.SomberAdapter = DS.Adapter.extend
	
	socket: null
	requests: {}
	serializer: SomberSerializer
	
	send: (store, action, type, data, result) ->
		
		return unless type.collectionName?
		
		collectionName = type.collectionName
		
		serializeModel = (model) ->
		
			if model instanceof DS.Model
				O = model.serialize()
				O._id = model.id
			else
				O = model
			
			O
			
		serializeModels = (models) ->
			
			if models instanceof Array
				for model in models
					serializeModel model
			else
				serializeModel models
			
		dataSerialized = serializeModels data
			
		# This UUID is strictly for tracking requests within EmberJS. It does
		# not serve to identify any objects except this particular adapter
		# transaction, and is disposed of when the server replies.
		uuid = (->
			S4 = -> Math.floor(Math.random() * 0x10000).toString 16
			"#{S4()}#{S4()}-#{S4()}-#{S4()}-#{S4()}-#{S4()}#{S4()}#{S4()}"
		)()
		
#		console.log action, type, dataSerialized
		
		@socket.emit 'somber-models', request =
			action: action
			data: dataSerialized
			collectionName: collectionName
			uuid: uuid
		
		# Extra data that isn't fit to be transmitted over the wire.
		localRequest =
			action: action
			data: dataSerialized
			rawData: data
			root: @get('serializer').rootForType type
			type: type
			store: store
			collectionName: collectionName
			uuid: uuid
		
		# So we have access to the original request upon a response from the
		# server.
		@get('requests')[uuid] = _.extend localRequest, request

	find: (store, type, id) ->
		
		@send store, FIND, type, id
	
	findMany: (store, type, ids, query) ->
		
		@send store, FIND_MANY, type, ids
	
	findQuery: (store, type, query, modelArray) ->
		
		@send(
			store
			FIND_QUERY
			type
			query
			modelArray
		).modelArray = modelArray
	
	findAll: (store, type) ->
		
		@send store, FIND_ALL, type
	
	createRecord: (store, type, model) ->
		
		@send store, CREATE, type, model
	
	createRecords: (store, type, array) ->
		
		@send store, CREATES, type, array.list
	
	updateRecord: (store, type, model) ->
		
		@send store, UPDATE, type, model
	
	updateRecords: (store, type, array) ->
		
		@send store, UPDATES, type, array.list
	
	deleteRecord: (store, type, model) ->
		
		@send store, DELETE, type, model
	
	deleteRecords: (store, type, array) ->
		
		@send store, DELETES, type, array.list
	
	init: ->
		
		@_super()
		
		socket = @get 'socket'
		
		socket.on 'somber-models', ({uuid, data}) =>
			
			requests = @get 'requests'
			
			{
				action
				modelArray
				rawData
				root
				type
				store
			} = requests[uuid] 
			
			normalizeIds = (data) ->
				
				if data instanceof Array
					
					datum.id = datum._id for datum in data
					
				else
					
					data.id = data._id
				
				data
			
			switch action
				
				when FIND
					
					store.load type, normalizeIds data
					
				when FIND_MANY
					
					payload = {}
					payload[@get('serializer').pluralize root] = normalizeIds data
					
					console.log root, type, payload
					
					@didFindMany store, type, payload
#					store.loadMany type, normalizeIds data
					
				when FIND_QUERY
					
					modelArray.load data
					
				when FIND_ALL
					
					store.loadMany type, normalizeIds data
					
				when CREATE
				
					store.didSaveRecord normalizeIds(data), rawData
					
				when CREATES
					
					store.didSaveRecords normalizeIds(data), rawData
				
				when UPDATE, DELETE
					
					store.didSaveRecord rawData
					
				when UPDATES, DELETES
					
					store.didSaveRecords rawData
					
				else throw "Unhandled Request: #{action}"
			
			delete requests[uuid]
		
		socket.on 'disconnect', ->
		
		return
