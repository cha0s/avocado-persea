	
exports.Controller = Ember.Controller.extend
	
	fluid: false

exports.View = Ember.View.extend
	
	selectedBinding: 'controller.selected'
	
	ItemView: Ember.View.extend
		tagName: 'li'
		classNameBindings: 'isActive:active'.w()
		isActive: (->
			@get('item') is @get('parentView.selected')
		).property('item', 'parentView.selected').cacheable()
	
	template: Ember.Handlebars.compile """

<div class="navbar navbar-inverse navbar-fixed-top">
	<div class="navbar-inner">
		<div {{bindAttr class="fluid:container-fluid:container"}} >
			<a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
				<span class="icon-bar"></span>
			</a>

			<a id="project-name" class="brand" {{action goToHome href=true}}>Persea</a>
			
			<div class="nav-collapse collapse">
				
				<ul class="nav">
				
					{{#view view.ItemView item="home" }}
						<a {{action goToHome href=true}} >Home</a>
					{{/view}}				
					
					{{#view view.ItemView item="projects" }}
						<a {{action goToProjects href=true}} >My Projects</a>
					{{/view}}
					
				</ul>
				
				<form class="navbar-form pull-right">
					<input type="email" placeholder="Email" class="span2">
					<input type="password" placeholder="Password" class="span2">
					<button class="btn" type="submit">Sign in</button>
				</form>						
			</div>
		</div>
	</div>
</div>

"""
