
Environments = require 'Persea/Routes/Environments'
Tilesets = require 'Persea/Routes/Tilesets'

ProjectModel = require 'Persea/Models/Project'

exports.Controller = Ember.ObjectController.extend()
	
exports.View = Ember.View.extend

	template: Ember.Handlebars.compile """

<div id="project" class="container">
	
	<ul class="breadcrumb">
		<li><a {{action goToHome href=true}} >Home</a> <span class="divider">/</span></li>
		<li><a {{action goToProjects href=true}} >My Projects</a> <span class="divider">/</span></li>
		<li class="active">{{name}}</li>
	</ul>

	<div class="row">
		<div id="project-image-container" class="span2">
			<img id="project-image" class="img-polaroid" src="http://placekitten.com/g/128/128">
			<a id="project-image-overlay" href="#"></a>
		</div>
		<div id="project-title" class="span10">
			<h1>{{name}}</h1>
			<p>{{description}}</p>
		</div>
	</div>
	
	<hr>
	
	<div class="row">
		
		<div id="resources" class="span6">
			<div class="navbar">
				<div class="navbar-inner">
					<h2>Resources</h2>
					<ul class="nav">
						<li><a {{action goToProjectEnvironments content href=true}} ><i class="icon-globe"></i> Environments ({{environments.length}})</a></li>
						<li><a href="#"><i class="icon-user"></i> Entities ({{entities.length}})</a></li>
						<li><a {{action goToProjectTilesets content href=true}} ><i class="icon-th"></i> Tilesets ({{tilesets.length}})</a></li>
						<li><a href="#"><i class="icon-film"></i> Animations ({{animations.length}})</a></li>
					</ul>
				</div>
			</div>
		</div>
		
		<hr class="visible-phone">
		
		<div id="configuration" class="span6">
			<div class="navbar">
				<div class="navbar-inner">
					<h2>Configuration</h2>
					<ul class="nav">
						<li><a href="#"><i class="icon-book"></i> Instruction manual</a></li>
						<li><a href="#"><i class="icon-bullhorn"></i> Deployment</a></li>
						<li><a href="#"><i class="icon-tasks"></i> Settings</a></li>
					</ul>
				</div>
			</div>
		</div>
		
	</div>
</div>

"""

exports.Route = Ember.Route.extend
	
	goToProjectEnvironments: Ember.Route.transitionTo 'environments.index'
	goToProjectTilesets: Ember.Route.transitionTo 'tilesets.index'
	
	route: '/:id'
	
	deserialize: (router, context) ->
		
		App.store.find ProjectModel, context.id
	
	serialize: (router, context) ->
		
		id: context.id
	
	connectOutlets: (router, project) ->
		
		router.get('applicationController').connectOutlet 'nav', 'nav'
		
		router.set 'projectController.content', project
		
		router.get('applicationController').connectOutlet 'footer', 'footer'
		
		router.set 'navController.selected', 'project'
		router.set 'navController.fluid', false
		router.set 'footerController.fluid', false
		
		undefined
		
	index: Ember.Route.extend
	
		route: '/'
		
		connectOutlets: (router, project) ->
			
			router.get('applicationController').connectOutlet 'body', 'project'
			
	environments: Environments.Route
	tilesets: Tilesets.Route
	