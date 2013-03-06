###
	
	Thanks bentjanderson! https://gist.github.com/4360857
	
	A Socket.IO adapter for ember-data.
	
	Requires ember.js and ember-data.js, socket.io
	
###

_ = require 'core/Utility/underscore'
async = require 'async'

exports.socket = socket = (socket, Models) ->
	
	collectionMap = {}
	for i, Model of Models
		
		collectionMap[Model.collection.name] = Model
	
	socket.on 'somber-models', (packet) ->
		
		packet.Model = collectionMap[packet.collectionName]
		
		dispatch packet, (error, results) ->
		
			throw error if error?
			
			socket.emit 'somber-models',
				
				uuid: packet.uuid
				action: packet.action
				collectionName: packet.collectionName
				data: results
	
exports.express = express = (app, Models) ->
	
	collectionMap = {}
	for i, Model of Models
		collectionMap[Model.collection.name] = Model
	
	app.get '/somber/:type/:id/:field', (req, res) ->
		
		{type, id, field} = req.params
		
		unless (Model = collectionMap[type])?
			
			res.send 404
			res.end()
		
		Model.find id, (error, [model]) ->
			
			throw error if error?
			
			res.end model[field]
	
dispatch = (packet, callback) ->

	FIND = 'find'
	FIND_MANY = 'findMany'
	FIND_QUERY = 'findQuery'
	FIND_ALL = 'findAll'
	CREATE = 'create'
	CREATES = 'creates'
	UPDATE = 'update'
	UPDATES = 'updates'
	DELETE = 'delete'
	DELETES = 'deletes'

	switch packet.action
		
#		when CREATE, CREATES
#			
#			packet.Model.create packet.data, (error, newModel) ->
#				
#				if error?
#					callback error, null
#				else
#					callback null, newModel
#
		when UPDATE, UPDATES
			
			updateDocument = (id, data) ->
				
				(callback) ->
				
					# "Mod on _id not allowed" otherwise. Strange, because I
					# thought that would only be a problem if the IDs weren't
					# the same.
					delete data._id
					
					packet.Model.castHash? data
					
					packet.Model.update {_id: id}, data, (error, results) ->
						
						throw error if error?
						
						callback error, results
				
			if packet.data instanceof Array
				asyncUpdates = for datum in packet.data
					updateDocument datum._id, datum
					
				async.parallel asyncUpdates, ->
					callback null, null
				
			else
				updateDocument(packet.data._id, packet.data) ->
					callback null, null
			
#		when DELETE, DELETES
#			
#			packet.Model.remove {_id: packet.data._id}, callback
					
		when FIND
			
			packet.Model.findById packet.data, callback
			
		when FIND_MANY
			
			packet.Model.find packet.data, callback
			
#		when FIND_QUERY
#			
#			callback null, O
#			
		when FIND_ALL
			
			packet.Model.find callback
		
		else throw "Unhandled action #{packet.action}"
