window.addEvent('domready', function(){
	// Categories
	var heads = $$('h2');
	var accordions = $$('ul');
	heads.each(function(heads, i){
		var headimg = new Element('img');
		headimg.setProperty('src', 'images/interface/menu_more.gif');
		headimg.injectInside(heads);
		heads.setStyles('cursor: pointer;');
	});
	var accordion = new Accordion(heads, accordions, {
		onActive: function(heads, accordions){
			var img = $E('img', heads);
			if (img) {
				img.setProperty('src', 'images/interface/menu_less.gif');
			};
		},
		onBackground: function(heads, accordions) {
			var img = $E('img', heads);
			if (img) {
				img.setProperty('src', 'images/interface/menu_more.gif');
			};
		}
	});
	// Links
	var list = $$('div#menu ul li a');
	list.each(function(element) {
		var fx = new Fx.Styles(element, {'duration': 300, 'wait': false});
		var fxparent = new Fx.Styles(element.getParent(), {'duration': 300, 'wait': false});
		element.mouseouted = true;
		element.addEvent('mouseenter', function(){
			fx.stop();
			element.setStyle('color','#000');
			fxparent.stop();
			element.getParent().setStyle('padding-left', '20px');
		});
		element.addEvent('mouseleave', function(){
			fx.start({
				'color': '#6e7475'
			});
			fxparent.start({
				'padding-left': '10px'
			});
		});
	});
});