
mongoose = require 'mongoose'

Environment = require './Environment'
Tileset = require './Tileset'

exports.Schema = ProjectSchema = mongoose.Schema
	
	name: String
	description: String
	
	environments: [mongoose.Schema.Types.ObjectId]
	tilesets: [mongoose.Schema.Types.ObjectId]
	
exports.Model = mongoose.model 'Project', ProjectSchema
