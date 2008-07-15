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