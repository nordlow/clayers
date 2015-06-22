# clayers
**clayers** (console layers) is an easy thing for handling various layers in a console environment. By letting you have multiple layers on top of each other, you can easily move the layers forth and back, make them "transparent", etc.

## Demonstration
```d
import clayers;

void main(){

	auto window = new ConsoleWindow(XY(80, 24));

	auto layer = new ConsoleLayer(XY(0, 0), XY(15, 15));
	window.addLayer(layer);

	layer.layerWrite(XY(0, 0), "Hello World!");
	layer.layerWrite(XY(7, 7), '*');

	auto layer2 = new ConsoleLayer(XY(60, 0), XY(20, 24)); //A sidebar
	auto layer3 = new ConsoleLayer(XY(50, 9), XY(15, 5)); //Small box

	window.addLayer(layer2);
	window.addLayer(layer3);

	//some code for visualisation
	foreach(y; 0 .. 15) layer. layerWrite(XY(0, y), "...............");
	foreach(y; 0 .. 24) layer2.layerWrite(XY(0, y), "*********************");
	foreach(y; 0 .. 5)  layer3.layerWrite(XY(0, y), "---------------");

	window.print();
}
```

## Extra
* [Usage](../master/doc/USAGE.md) - Quick guide of how to use clayers.
* [Reference](../master/doc/REFERENCE.md) - Reference list of all the functions.

