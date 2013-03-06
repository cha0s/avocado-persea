
mongoose = require 'mongoose'

exports.Schema = TilesetSchema = mongoose.Schema
	
	name: String
	description: String
	
	tileSize: [Number]
	tileData: Buffer
	
exports.Model = TilesetModel = mongoose.model 'Tileset', TilesetSchema

TilesetModel.castHash = (O) ->
	
	O.tileData = new Buffer O.tileData, 'base64'
