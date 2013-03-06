
mongoose = require 'mongoose'

Room = require './Room'
Tileset = require './Tileset'

exports.Schema = EnvironmentSchema = mongoose.Schema

	name: String
	description: String
	tileset: mongoose.Schema.Types.ObjectId
	rooms: [mongoose.Schema.Types.ObjectId]

exports.Model = mongoose.model 'Environment', EnvironmentSchema
