# clayers
clayers (**c**onsole **layers**) is a cross-platform console render library for game devs, supporting multiple layers, efficient rendering and easy management. Layers can be added, removed and rearranged as well as toggled between translucent and opaque. Rendering only writes out what has changed, minimizing rendering to as little and quick as possible.

### Features

##### Cross-platform

* Works on Windows and POSIX (OS X, Linux, BSD, etc.)

##### Layers

* Sized and positioned
* See-through, meaning whitspaces are transparent
* Toggled visiblity
* Can be moved forwards and backwards

##### Rendering

* Printing out all layers merged
* Only writing out what has changed

## Demonstration
This code was used to create screenshot above.
```d
import clayers;

void main(){

	int split = 50;

	auto window = new ConsoleWindow(XY(80, 24));

	auto layerMain    = new ConsoleLayer(XY(0,  0), XY(split, window.height));
	auto layerSidebar = new ConsoleLayer(XY(split, 0), XY(window.width - split, window.height)); //A sidebar
	auto layerPopup   = new ConsoleLayer(XY(2, 15), XY(window.width - 5, 7 )); //Opaque box
	auto layerPopup2  = new ConsoleLayer(XY(split - 8, 4), XY(30, 15)); //Transparent box

	window.addLayer(layerMain);
	window.addLayer(layerSidebar);
	window.addLayer(layerPopup);
	window.addLayer(layerPopup2);

	layerPopup2.transparent(true);
	layerPopup2.moveBackward();

	foreach(x; 0 .. window.width)
	foreach(y; 0 .. window.height){
		if(x == 0 || x == layerPopup.width - 1 || y == 0 || y == layerPopup.height - 1)
			layerPopup.write(XY(x,y), '*');
		if(x == 0 || x == layerPopup2.width - 1 || y == 0 || y == layerPopup2.height - 1)
			layerPopup2.write(XY(x,y), 'o');
		if(x == 0 || x == layerSidebar.width - 1 || y == 0 || y == layerSidebar.height - 1)
			layerSidebar.write(XY(x,y), '+');
		if(x % 2 == 0){
			layerMain.write(XY(x,y), '.');
		}
	}

	layerPopup.write(XY(2, 2), "This is a popup! There could be some information in here.");
	layerPopup.write(XY(2, 4), "For instance, this layer is opaque.");

	layerPopup2.write(XY(2, 2), "This box is translucent.");
	layerPopup2.write(XY(2, 8), "This layer is also behind");
	layerPopup2.write(XY(2, 9), "that one |");
	layerPopup2.write(XY(11, 10), 'V');

	window.print();
}
```

## Extra
* [Usage](../master/doc/USAGE.md) - Quick guide of how to use clayers.
* [Reference](../master/doc/REFERENCE.md) - Reference list of all the functions.

