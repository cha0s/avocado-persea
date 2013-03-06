
exports.Controller = Ember.Controller.extend()

exports.View = Ember.View.extend
	
	template: Ember.Handlebars.compile """

<div id="footer" {{bindAttr class="fluid:container-fluid:container"}} >

	<hr>
	
	<footer>
		<p>&copy; The Avocado Group 2012</p>
	</footer>

</div>

"""
