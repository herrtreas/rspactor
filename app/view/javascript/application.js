Event.observe(window, 'load', resizeOuterWrapper);
Event.observe(window, 'resize', resizeOuterWrapper);

function resizeOuterWrapper() {
	var new_width = window.innerWidth - 2;
	var new_height = window.innerHeight - 2;
	$('outer_wrapper').setStyle({
		width: new_width + 'px',
		height: new_height + 'px'
	});
}

function toggleSpecBox(element) {
	Element.extend(element);
	element.nextSiblings()[0].toggle();
	var fold_button = element.childElements()[0];
	if (fold_button.innerHTML == '+') {
		fold_button.innerHTML = '-';
	} else {
		fold_button.innerHTML = '+';		
	}
}

function hideElement(element_id) {
  $(element_id).hide();
}