
mongoose = require 'mongoose'

TileLayer = require './TileLayer'

exports.Schema = RoomSchema = mongoose.Schema
	
	entities: []
	collision: []
	layers: [mongoose.Schema.Types.ObjectId]
	name: String
	size: [Number]

exports.Model = mongoose.model 'Room', RoomSchema
