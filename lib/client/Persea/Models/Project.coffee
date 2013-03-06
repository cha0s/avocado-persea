EnvironmentModel = require 'Persea/Models/Environment'
TilesetModel = require 'Persea/Models/Tileset'

Model = module.exports = DS.Model.extend(
	revision: 11
	
	name: DS.attr 'string'
	description: DS.attr 'string'
	
	environments: DS.hasMany EnvironmentModel
	tilesets: DS.hasMany TilesetModel
	
).reopenClass
	
	collectionName: 'projects'
