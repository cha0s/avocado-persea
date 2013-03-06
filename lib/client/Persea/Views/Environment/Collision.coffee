module.exports = Ember.View.extend
	
	classNames: ['collision']
	
	template: Ember.Handlebars.compile """

<h3>Collision</h3>
<div class="collision">
	{{view Bootstrap.Forms.Select
		contentBinding="collisionContent"
		selectionBinding="collisionSelection"
		labelBinding="collisionLabel"
	}}
</div>

"""

