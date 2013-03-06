	
exports.Controller = Ember.Controller.extend()

exports.View = Ember.View.extend
	
	template: Ember.Handlebars.compile """

<div id="hero" class="container">

	<div class="hero-unit">
		<h1>Create. Share. Enjoy!</h1>
		<p>Persea is a next-generation application for creating rich, interactive worlds.</p>
		<p><a class="btn btn-primary btn-large">Yes, please »</a></p>
	</div>
	
	<div class="row">
		<div class="span4">
			<h2>Plug in</h2>
			<p>Get signed up so you can carve out your own piece of the pie.</p>
			<p><a href="#" class="btn">View details »</a></p>
		</div>
		<div class="span4">
			<h2>Hook it up</h2>
			<p>Create your environments, the characters that populate them, and all the little intricacies your heart desires. Start from scratch or build on others' work. It's up to you!</p>
			<p><a href="#" class="btn">View details »</a></p>
		</div>
		<div class="span4">
			<h2>Take off</h2>
			<p>Publish and share your work.</p>
			<p><a href="#" class="btn">View details »</a></p>
		</div>
	</div>
	
</div>

"""
