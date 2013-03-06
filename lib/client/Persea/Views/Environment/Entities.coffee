module.exports = Ember.View.extend
	
	classNames: ['entities']
	
	template: Ember.Handlebars.compile """

<h3>Entities</h3>
<div class="entities">
	{{view Bootstrap.Forms.Select
		contentBinding="entitiesContent"
		selectionBinding="entitiesSelection"
		labelBinding="entitiesLabel"
	}}
</div>

"""

