
Environment = require 'Persea/Routes/Environment'
Image = require('Graphics').Image

exports.Controller = Ember.ArrayController.extend
	sortProperties: ['name']

	projectName: (->
		
		projectName = @get 'currentProject.name'
		projectId = @get 'currentProject.id'
		
		if projectName then projectName else projectId
		
	).property 'currentProject.id', 'currentProject.name'
	
exports.View = Ember.View.extend
	
	environmentViewClass: Ember.View.extend
		
		didInsertElement: ->
			
			@redrawThumbnail()
		
		redrawThumbnail: (->
			
			return unless (environmentObject = @get 'content.object')?
			return unless (tilesetObject = @get 'content.tileset.object')?
			
			room = environmentObject.room 0
			
			image = new Image()
			image.Canvas = @$('.thumb')[0]
			
			for layer in room.layers_
				layer.fastRender tilesetObject, image
			
		).observes 'content.object', 'content.tileset.object'
		
		thumbnailStyle: (->
			
			if (tilesetObject = @get 'content.tileset.object')?
				"
background: none
"
			else
				"
background-image: url('/app/node.js/persea/static/img/spinner.svg'); 
background-size: contain;
"
			
		).property 'content.tileset.object'
		
		template: Ember.Handlebars.compile """

<div class="row">
	
	<a class="media span6" {{action goToProjectEnvironment view.content href=true}} >
		
	    <canvas width="512" height="512" class="pull-left media-object thumb"
	    	{{bindAttr style="view.thumbnailStyle"}}
	    ></canvas>
	    
	    {{view.content.rooms}}
	    
	    <div class="media-body">
	    	
		    <h4 class="media-heading">{{view.content.name}} <small>{{view.content.fetching}}</small></h4>
		    
		    {{#unless view.content.fetching}}
		    	<p>{{view.content.description}}</p>
		    {{/unless}}
		    
	    </div>
	    
	</a>
	
</div>

"""
	
	template: Ember.Handlebars.compile """

<div id="environment-list" class="container">
	
	<ul class="breadcrumb">
		<li><a {{action goToHome href=true}} >Home</a> <span class="divider">/</span></li>
		<li><a {{action goToProjects href=true}} >My Projects</a> <span class="divider">/</span></li>
		<li><a {{action goToProject currentProject href=true}} >{{projectName}}</a> <span class="divider">/</span></li>
		<li class="active">Environments</li>
	</ul>

	<h1>{{projectName}}'s Environments</h1>
	
	{{collection
		contentBinding="content"
		itemViewClass="view.environmentViewClass"
	}}
	
</div>

"""

exports.Route = Ember.Route.extend
	
	goToProjectEnvironment: Ember.Route.transitionTo 'environment.index'
	
	route: '/environments'
	
	index: Ember.Route.extend
	
		route: '/'

		connectOutlets: (router, context) ->
			
			router.get('applicationController').connectOutlet 'nav', 'nav'
			
			project = router.get 'projectController.content'
			
			router.set 'environmentsController.currentProject', project
			router.set 'environmentsController.content', project.get 'environments'
			router.get('applicationController').connectOutlet 'body', 'environments'
			
			router.get('applicationController').connectOutlet 'footer', 'footer'
			
			router.set 'navController.fluid', false
			router.set 'footerController.fluid', false
			
			router.set 'navController.selected', 'environments'
			
			undefined

	environment: Environment.Route
	