CoreService = require 'main/web/Bindings/CoreService'
ember = require 'Persea/ember'
NetworkConfig = 'core/Config/Network'
somber = require 'Persea/somber'
Timing = require 'Timing'

# SPI proxies.
require 'core/proxySpiis'

timeCounter = new Timing.Counter()
setInterval(
	-> Timing.TimingService.setElapsed timeCounter.current() / 1000
	25
)

app =

	ApplicationView: Ember.View.extend
	
		template: Ember.Handlebars.compile """

{{outlet nav}}
{{outlet body}}
{{outlet footer}}

"""
	
	ApplicationController: Ember.Controller.extend()
	
router =
	
	actions:
		
		enableLogging: false
		
	routes:

		goToHome:  Ember.Route.transitionTo 'root.index'
		index: Ember.Route.extend
			route: '/'
			connectOutlets: (router, context) ->
				
				router.get('applicationController').connectOutlet 'nav', 'nav'
				router.get('applicationController').connectOutlet 'body', 'home'
				router.get('applicationController').connectOutlet 'footer', 'footer'
				
				router.set 'navController.selected', 'home'
				router.set 'navController.fluid', false
		
for route in [
	'Footer', 'Home', 'Nav'
	
	'Environment', 'Environments'
	'Project', 'Projects'
	'Tileset', 'Tilesets'
]

	ember.mixinRoutes app, router, route

routerObject = router.actions
routerObject.root = Ember.Route.extend router.routes

app.Router = Ember.Router.extend routerObject

window.App = Ember.Application.create app

App.store = DS.Store.create
	revision: 11

	adapter: somber.Adapter.create
		
		socket: io.connect NetworkConfig.host
	
###	
	adapter: DS.FixtureAdapter.create
		simulateRemoteResponse: true
		latency: 10
###

ember.mixinModels App, [
	'TileLayer'
	'Room'
	'Environment'
	'Project'
	'Tileset'
]

App.initialize()
