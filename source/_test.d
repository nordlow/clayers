import clayers;
import std.stdio;
import std.experimental.logger;

void main(){

	ConsoleWindow win = new ConsoleWindow();

	ConsoleLayer a  = new ConsoleLayer(XY(0, 0),  XY(20,10));
	ConsoleLayer a2 = new ConsoleLayer(XY(25,5),  XY(20,10));
	ConsoleLayer a3 = new ConsoleLayer(XY(30,10), XY(20,10), true);

	win.addLayer(a);
	win.addLayer(a2);
    win.addLayer(a3);

    foreach(x; 0 .. 20)
    foreach(y; 0 .. 10)
        a2.layerWrite(XY(x,y), '*');
        

    a .layerWrite(XY(0, 0), "Well hello there this is a test!");
	a3.layerWrite(XY(0, 0), "Well hello there, this is the second test! Hope it goes well for you!");

	win.print();
}
