
mongoose = require 'mongoose'

exports.Schema = TileLayerSchema = mongoose.Schema
	
	tileIndices: [Number]
	size: [Number]

exports.Model = mongoose.model 'TileLayer', TileLayerSchema
