# clayers
**clayers** (console layers) is an easy thing for handling various layers in a console environment. By letting you have multiple layers on top of each other, you can easily move the layers forth and back, make them "transparent", etc.

## Demonstration
```d
void main(){
	ConsoleWindow win = new ConsoleWindow(XY(80, 24));
	ConsoleLayer smallbox = new ConsoleLayer(XY(10,10), XY(10,10));
	win.addLayer(smallbox);	

	smallbox.layerWrite(XY(0,0), "u sux m9");
	win.print();
}
```

## Extra
* [Usage](../master/doc/USAGE.md) - Quick guide of how to use clayers.
* [Reference](../master/doc/REFERENCE.md) - Reference list of all the functions.

