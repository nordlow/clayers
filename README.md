# clayers
**clayers** (console layers) is an easy thing for handling various layers in a console environment.

## Demonstration
```
void main(){
	ConsoleWindow win = new ConsoleWindow(XY(80, 24));
	ConsoleLayer smallbox = new ConsoleLayer(XY(10,10), XY(10,10));

	win.addLayer(smallbox);
	win.print();
}
```