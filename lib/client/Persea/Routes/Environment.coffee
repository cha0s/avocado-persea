TabPanesView = require 'Persea/Views/Bootstrap/TabPanes'

DocumentController = require 'Persea/Controllers/Environment/Document'
DocumentView = require 'Persea/Views/Environment/Document'

EnvironmentModel = require 'Persea/Models/Environment'

exports.Controller = Ember.Controller.extend
	
	documentController: DocumentController.create()
	
	roomSelectContent: []
	currentRoom: null
	
	environmentObjectChanged: (->
		
		return unless (environmentObject = @get 'environment.object')?
		
		roomSelectContent = for i in [0...environmentObject.roomCount()]
			
			index: i
			name: environmentObject.room(i).name()
			object: environmentObject.room i
				
		@set 'roomSelectContent', roomSelectContent
		@set 'currentRoom', roomSelectContent[0]
		
	).observes 'environment.object'
	
	_loadControls: ->
		
		controls = for controlType in [
			'Landscape'
			'Entities'
			'Collision'
		]
			
			lowered = controlType.charAt(0).toLowerCase() + controlType.substr(1)
			
			Controller = require "Persea/Controllers/Environment/#{controlType}"
			View = require "Persea/Views/Environment/#{controlType}"
			
			@set "#{lowered}Controller", controller = Controller.create
				environmentController: this
		
			title: controlType
			link: lowered
			paneView: View.extend
				controller: controller
		
		@set 'content', controls
		
	init: ->
		
		@_loadControls()
		
		@set 'documentController.environmentController', this
		
		@set 'selection', @get('content')[0]
		
exports.View = Ember.View.extend
	
	controlsView: TabPanesView
	
	documentView: DocumentView
	
	template: Ember.Handlebars.compile """

<div id="environment" class="container-fluid">
	
	<ul class="breadcrumb">
		<li><a {{action goToHome href=true}} >Home</a> <span class="divider">/</span></li>
		<li><a {{action goToProjects href=true}} >My Projects</a> <span class="divider">/</span></li>
		<li><a {{action goToProject currentProject href=true}} >{{currentProject.name}}</a> <span class="divider">/</span></li>
		<li><a {{action goToProjectEnvironments currentProject href=true}} >Environments</a> <span class="divider">/</span></li>
		<li class="active">
			{{#if environment.fetching}}
				{{environment.id}}
			{{else}}
				{{environment.name}}
			{{/if}}
		</li>
	</ul>

	<h1>{{environment.name}} <small>{{environment.fetching}}</small></h1>
	
	<div class="row-fluid">
		
		<div class="span4">
		
			<h2>Rooms</h2>
			<div class="rooms">
				{{view Bootstrap.Forms.Select
					contentBinding="roomSelectContent"
					selectionBinding="currentRoom"
					optionLabelPath="content.name"
					optionValuePath="content.index"
				}}
			</div>
			
			{{view view.controlsView
				id="environment-controls"
			}}
			
		</div>
		
		{{view view.documentView
			class="span8 document-container"
			controller=documentController
		}}
		
	</div>
	
</div>

"""

exports.Route = Ember.Route.extend
	
	route: '/:id'
	
	deserialize: (router, context) ->
		
		App.store.find EnvironmentModel, context.id.replace /\|/g, '/'
	
	serialize: (router, context) ->
		
		id: context.id.replace /\//g, '|'
	
	connectOutlets: (router, environment) ->
		
		router.get('applicationController').connectOutlet 'nav', 'nav'
		
		router.set 'environmentController.environment', environment
		
		router.get('applicationController').connectOutlet 'footer', 'footer'
		
		router.set 'navController.fluid', true
		router.set 'footerController.fluid', true
		
		undefined
		
	index: Ember.Route.extend
	
		route: '/'

		connectOutlets: (router, context) ->
			
			router.get('applicationController').connectOutlet 'nav', 'nav'
			
			project = router.get 'projectController.content'
			router.set 'environmentController.currentProject', project
			
			router.get('applicationController').connectOutlet 'body', 'environment'
			
			router.get('applicationController').connectOutlet 'footer', 'footer'
			
			router.set 'navController.selected', 'environment'
			
			undefined
