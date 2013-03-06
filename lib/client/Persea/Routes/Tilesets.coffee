
CoreService = require 'main/web/Bindings/CoreService'
Tileset = require 'Persea/Routes/Tileset'

exports.Controller = Ember.ArrayController.extend
	sortProperties: ['name']

	projectName: (->
		
		projectName = @get 'currentProject.name'
		projectId = @get 'currentProject.id'
		
		if projectName then projectName else projectId
		
	).property 'currentProject.id', 'currentProject.name'
	
exports.View = Ember.View.extend

	tilesetViewClass: Ember.View.extend
		
		thumbnailStyle: (->
			
			"
background-image: url('#{
	if (tilesetObject = @get 'content.object')?
		tilesetObject.image().src
	else
		"/app/node.js/persea/static/img/spinner.svg"
	
}'); 
background-size: contain;
background-repeat: no-repeat;
"
			
		).property 'content.object'
		
		template: Ember.Handlebars.compile """

<div class="row">

	<a class="media span6" {{action goToProjectTileset view.content href=true}} >
		
		<div class="pull-left media-object thumb"
			{{bindAttr style="view.thumbnailStyle"}}
		>
		</div>
	    
	    <div class="media-body">
	    
		    {{#if view.content.fetching}}
			    <h4 class="media-heading"><small>{{view.content.fetching}}</small></h4>
		    {{else}}
			    <h4 class="media-heading">{{view.content.name}}</h4>
			    
		    	<p>{{view.content.description}}</p>
		    {{/if}}
		    
	    </div>
	    
	</a>
	
</div>

"""
	
	template: Ember.Handlebars.compile """

<div id="tileset-list" class="container">
	
	<ul class="breadcrumb">
		<li><a {{action goToHome href=true}} >Home</a> <span class="divider">/</span></li>
		<li><a {{action goToProjects href=true}} >My Projects</a> <span class="divider">/</span></li>
		<li><a {{action goToProject currentProject href=true}} >{{projectName}}</a> <span class="divider">/</span></li>
		<li class="active">Tilesets</li>
	</ul>

	<h1>{{projectName}}'s Tilesets</h1>
	
	{{collection contentBinding="content" itemViewClass="view.tilesetViewClass"}}
	
</div>

"""

exports.Route = Ember.Route.extend
	
	goToProjectTileset: Ember.Route.transitionTo 'tileset.index'
	
	route: '/tilesets'
	
	index: Ember.Route.extend
	
		route: '/'

		connectOutlets: (router, context) ->
			
			router.get('applicationController').connectOutlet 'nav', 'nav'
			
			project = router.get 'projectController.content'
			
			router.set 'tilesetsController.currentProject', project
			router.set 'tilesetsController.content', project.get 'tilesets'
			router.get('applicationController').connectOutlet 'body', 'tilesets'
			
			router.get('applicationController').connectOutlet 'footer', 'footer'
			
			router.set 'navController.fluid', false
			router.set 'footerController.fluid', false
			
			router.set 'navController.selected', 'tilesets'
			
			undefined

	tileset: Tileset.Route