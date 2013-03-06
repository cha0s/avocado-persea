
Project = require 'Persea/Routes/Project'
ProjectModel = require 'Persea/Models/Project'

exports.Controller = Ember.ArrayController.extend
	sortProperties: ['name']
	
exports.View = Ember.View.extend
	
	template: Ember.Handlebars.compile """

<div id="project-list" class="container">
	
	<ul class="breadcrumb">
		<li><a {{action goToHome href=true}} >Home</a> <span class="divider">/</span></li>
		<li class="active">My Projects</li>
	</ul>

	<h1>My Projects</h1>
	
	{{#each controller}}
		<a class="media" {{action goToProject this href=true}}>
		    <img class="pull-left media-object" src="http://placekitten.com/g/64/64">
		    <div class="media-body">
			    <h2 class="media-heading">{{name}}</h2>
			    <p>{{description}}</p> 
		    </div>
		</a>
	{{/each}}
	
</div>

"""

exports.Router =
	
	actions:
	
		goToProjects: Ember.Route.transitionTo 'root.projects.index'
		
	routes:
		
		goToProject: Ember.Route.transitionTo 'project.index'
		
		projects: Ember.Route.extend
			
			route: '/projects'
			
			index: Ember.Route.extend
				route: '/'
				
				connectOutlets: (router, context) ->
					
					router.get('applicationController').connectOutlet 'nav', 'nav'
					router.get('applicationController').connectOutlet 'body', 'projects', App.store.findAll ProjectModel
					router.get('applicationController').connectOutlet 'footer', 'footer'
					
					router.set 'navController.selected', 'projects'
					router.set 'navController.fluid', false
					router.set 'footerController.fluid', false
					
					undefined
		
			project: Project.Route
			