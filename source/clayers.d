module clayers;

import consoled : setCursorPos;
import std.stdio;
import std.algorithm;
import std.datetime;

struct XY{int x,y;}

class ConsoleWindow{
	
	ConsoleLayer[] layers;
	XY size;
	
	protected char[][] slots;
	
	this(XY size = XY(80, 24), char background = ' ', char border = ' '){
		this.size = size;
		
		//Sets the width and height
		slots.length = size.x; foreach(int y; 0 .. size.x) slots[y].length = size.y;
		
		//Set every tile to be the background
		foreach(x; 0 .. size.x) slots[x][0 .. $] = background;

		if(border != ' '){
			foreach(x; 0 .. size.x)
			foreach(y; 0 .. size.y)
				if(x == 0 || x == size.x - 1 || y == 0 || y == size.y - 1)
					slots[x][y] = border;
		}
	}
	
	char getSlot(XY location){
		return snap()[location.x][location.y];
	}
	
	void addLayer(ConsoleLayer cl){
		layers ~= cl;
	}
	
	void print(){
		char[][] writes = snap();

		string print;
		foreach(int y; 0 .. size.y){
			foreach(int x; 0 .. size.x)
				print ~= writes[x][y];
			setCursorPos(0, y);
			write(print);
			print = null;
		}
		setCursorPos(0, 0);

		/+ The version below is about ~15 times faster, but unreliable.
		 + 
		 + For instance, once a whole 80 character line has been
		 + printed the console wraps around and begins on a new
		 + line. And then the command to send a newline happens
		 + which causes empty lines to appear.
		
		string print2;
		foreach(int y; 0 .. size.y){
			foreach(int x; 0 .. size.x)
				print2 ~= writes[x][y];
			print2 ~= "\n";
		}
		setCursorPos(0, 0);
		write(print2);
		+/
	}
	
	char[][] snap(){
		//Thanks ketmar from #d
		char[][] snap = new char[][](slots.length, slots[0].length);
		foreach (x, col; snap) col[] = slots[x][];

		foreach(a; 0 .. layers.length)
		foreach(x; 0 .. layers[a].size.x)
		foreach(y; 0 .. layers[a].size.y)
			snap[x + layers[a].location.x][y + layers[a].location.y] = layers[a].slots[x][y];
		
		return snap;
	}

	void removeLayer(ConsoleLayer cl){
		foreach(n; 0 .. layers.length){
			if(cl == layers[n]){
				layers = remove(layers, n);
				break;
			}
		}
	}

	void moveLayerFront(ConsoleLayer cl){
		foreach(a; 0 .. layers.length){
			if(layers[a] == cl){
				moveLayerForward(cl, layers.length - a);
			}
		}
	}

	void moveLayerBack(ConsoleLayer cl){
		foreach(a; 0 .. layers.length){
			if(layers[a] == cl){
				moveLayerBackward(cl, a);
			}
		}
	}

	void moveLayerForward(ConsoleLayer cl, int amount = 1){
		foreach(c; 0 .. amount)
		foreach(a; 0 .. layers.length){
			if(layers[a] == cl && a < layers.length - 1){
				auto t = layers[a + 1];
				layers[a + 1] = layers[a];
				layers[a] = t;
			}
		}
	}

	void moveLayerBackward(ConsoleLayer cl, int amount = 1){
		foreach(c; 0 .. amount)
		foreach(a; 0 .. layers.length){
			if(layers[a] == cl && a > 0){
				auto t = layers[a - 1];
				layers[a - 1] = layers[a];
				layers[a] = t;
			}
		}
	}
}

class ConsoleLayer : ConsoleWindow{
	XY location;
	this(XY location, XY size, char background = ' ', char border = ' '){
		this.location = location;
		super(size, background, border);
	}
	
	char getLayerSlot(XY location){
		return slots[location.x][location.y];
	}
	
	void setLayerSlot(XY location, char a){
		slots[location.x][location.y] = a;
	}
}
