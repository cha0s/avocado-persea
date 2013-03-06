module.exports = Ember.CollectionView.extend
	classNames: ['nav']
	tagName: 'ul'

	itemViewClass: Ember.View.extend(Bootstrap.ItemSelectionSupport, Bootstrap.ItemViewHrefSupport, {

		template: Ember.Handlebars.compile """

{{#if view.content.noLink}}
	<p class="navbar-text" {{bindAttr id="view.content.id"}} >{{view.content.text}}</p>
{{else}}
	<a {{bindAttr title="view.content.title"}} {{bindAttr noselect="view.content.noSelect"}} {{bindAttr href="javascript:void(0)"}} {{bindAttr id="view.content.id"}} >
		{{#if view.content.i}}
			<i {{bindAttr class="view.content.i"}} ></i>		
		{{/if}}
		{{view.content.text}}
	</a>
{{/if}}

"""

		click: (event) ->
			
			# Only care about links.
			return false unless $('a', event.currentTarget).length > 0
			return false if 'noselect' is $('a', event.currentTarget).attr 'noselect'
			
			@_super event
			
		mouseDown: (event) ->
			
			return unless Modernizr.touch
			
			@click event
			
			false
			
	})

