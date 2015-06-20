import clayers;
import std.stdio;
import std.experimental.logger;

void main(){

	ConsoleWindow win = new ConsoleWindow();

	ConsoleLayer a  = new ConsoleLayer(XY(0, 0),  XY(20,10));
	ConsoleLayer a2 = new ConsoleLayer(XY(25,5),  XY(20,10), ' ', '-');
	ConsoleLayer a3 = new ConsoleLayer(XY(50,10), XY(20,10), '.', '^');

	win.addLayer(a);
	win.addLayer(a2);
  win.addLayer(a3);

  a .layerWrite(XY(0, 2), "Well hello there this is a test!");
	a2.layerWrite(XY(1, 2), "Well hello there, this is the second test! Hope it goes well for you!");
	a3.layerWrite(XY(30,0), 's');

	win.print();

	readln();

}
