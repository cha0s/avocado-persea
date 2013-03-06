
exports.mixinRoutes = (app, router, route) ->
	
	mvc = require "Persea/Routes/#{route}"
	
	app["#{route}Controller"] = mvc.Controller if mvc.Controller?
	app["#{route}View"] = mvc.View if mvc.View?
	
	_.extend router.actions, mvc.Router?.actions ? {}
	_.extend router.routes, mvc.Router?.routes ? {}
	
	undefined

exports.mixinModels = (App, modelNames) ->
	
	for modelName in modelNames
		
		App["#{modelName}Model"] = require "Persea/Models/#{modelName}"
	
	undefined
