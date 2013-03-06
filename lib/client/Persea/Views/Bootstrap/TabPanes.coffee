Tabs = Bootstrap.Tabs.extend

	itemViewClass: Ember.View.extend(Bootstrap.ItemSelectionSupport, Bootstrap.ItemViewHrefSupport, {
		click: ->
		paneHref: (->
			"[data-tab-pane=\"#{@get('href')}\"]"
		).property 'href'
		
		template: Ember.Handlebars.compile """

<a data-toggle="tab" {{bindAttr href="view.paneHref"}} >{{view.title}}</a>

"""
	});

TabPane = Ember.View.extend Bootstrap.ItemSelectionSupport, Bootstrap.ItemViewHrefSupport,
	classNames: ['tab-pane']
	attributeBindings: ['data-tab-pane']
	'data-tab-pane': (->
		@get('href')
	).property 'href'
	
	click: ->
	template: Ember.Handlebars.compile """

{{view view.content.paneView
}}

"""

module.exports = Ember.View.extend
	
	tabs: Tabs

	paneView: Ember.CollectionView.extend
		classNames: ['tab-content']
		itemViewClass: TabPane
		selection: null

	template: Ember.Handlebars.compile """

{{view view.tabs
	contentBinding="content"
	selectionBinding="selection"
}}

{{view view.paneView
	contentBinding="content"
	selectionBinding="selection"
}}

"""

