module clayers;
import std.stdio;
import std.algorithm;

struct XY{size_t x,y;}

class ConsoleWindow{

    //TODO: Should layers be able to have their own sub-layers, which in turn could have even more sub-layers? I can see some pretty interesting things with this. If not, just change protected to private. ;-)
	protected ConsoleLayer[] layers;
    protected char[][] slots;
 	
	protected XY size;
    protected bool transparent = false;

	this(XY size = XY(80, 24)){
		this.size = size;

		//Sets the width and height.
		slots = new char[][](size.x, size.y);	
		//Set every tile to be the background.
		foreach(x; 0 .. size.x) slots[x][0 .. $] = ' ';
	}
	
	version(Windows){
		import core.sys.windows.windows;
		HANDLE hOutput = null, hInput = null;
	}
	/**
	 * Sets the cursor's position.
	 * NOTE: This should only be used by clayers.
	 *
	 * Params:
	 *	XY = X and Y coordinates where the cursor should be put.
	*/
	private void scp(XY pos){
		version(Windows){
			COORD c = {cast(short)min(width,max(0,pos.x)), cast(short)max(0,pos.y)};
			stdout.flush();
			SetConsoleCursorPosition(hOutput, c);
		}else version(Posix){
			stdout.flush();
			writef("\033[%d;%df", pos.y + 1, pos.x + 1);
		}
		//All code in this function is stolen from setCursorPos() from ConsoleD.
	}

	@property{
		/**
		 * Returns the width of the window/layer.
		*/
		size_t width(){
			return size.x;
		}
		
		/**
		 * Returns the height of the windows/layer.
		*/
		size_t height(){
			return size.y;
		}
	}
	
	/**
	 * Returns the char at the specific X and Y coordinates in the window.
	 * 
	 * When called, it merges all the layers together, then returns the char.
	*/
	char getSlot(XY location){
		return snap()[location.x][location.y];
	}

	/**
	* Prints all the layers in the correct order.
	*/
	void print(){
		char[][] writes = snap();

		string print;
		foreach(y; 0 .. size.y){
			foreach(x; 0 .. size.x){
				print ~= writes[x][y];
			}

			scp(XY(0, y));
			std.stdio.write(print);
			print = null;
		}
		scp(XY(0, 0));

		/+ The version below is about ~15 times faster, but unreliable.
		 + 
		 + For instance, once a whole 80 character line has been
		 + printed the console wraps around and begins on a new
		 + line. And then the command to send a newline happens
		 + which causes empty lines to appear.
		 +
		 + TODO: I guess I could check if the width is less than the window width minus one (somehow), and only then append the '\n'. 

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
	
	/*
	* Returns a 'snap', snapshot, of all the layers merged.
	*/
	char[][] snap(){
		//Thanks ketmar from #d
		char[][] snap = new char[][](slots.length, slots[0].length);
		foreach (x, col; snap) col[] = slots[x][];

		foreach(a; 0 .. layers.length)
		foreach(x; 0 .. layers[a].size.x)
		foreach(y; 0 .. layers[a].size.y)
            if(!(layers[a].isTransparent() && layers[a].getSlot(XY(x,y)) == ' '))
    			snap[x+layers[a].location.x][y+layers[a].location.y] = layers[a].getSlot(XY(x,y));

		return snap;
	}

	/*
	* Functions like std.stdio.write(), only it writes in the layer.
	*
	* Params:
	*	 xy = X and Y positions of where to write.
	*	 c = The character to write.
	*/
	void layerWrite(XY xy, char c){
		try{
			slots[xy.x][xy.y] = c;
		}catch{ /* Well, I don't really know what to do then. TODO: Log maybe? */ }
	}

	/*
	* Functions like std.stdio.write(), only it writes in the layer.
	*
	* Params:
	*	 xy = X and Y positions of where to write.
	*	 s = The string to be written. Does wrap around, does not overwrite border
	*/
	void layerWrite(XY xy, string s){
		try{
            foreach(a; 0 .. s.length){
                int split = cast(int)((xy.x + a) / size.x);
                slots[(xy.x + a) % size.x][xy.y + split] = s[a];
            }
		}catch{ /* If the string 'overflows', what to do? TODO: Log maybe? */ }
	}

	/**
	* Adds a new layer.
	* DO NOT USE `new ConsoleLayer(...)`, because there is no way to remove the
	* layer otherwise.
	*
	* Params:
	*	 cl = Should be a already defined layer.
	*/
	void addLayer(ConsoleLayer cl){
		layers ~= cl;
	}
	
	/**
	* Removes a specific layer
	*
	* Params:
	*	 cl = Layer to be removed.
	*/
	void removeLayer(ConsoleLayer cl){
		foreach(n; 0 .. layers.length){
			if(cl == layers[n]){
				layers = remove(layers, n);
				return;
			}
		}
		//TODO: Log if layer could not be removed.
	}

	/**
	* Move a specific layer to the front.
	*
	* Params:
	*	 cl = Layer to be moved to the front.
	*/
	void moveLayerFront(ConsoleLayer cl){
		foreach(a; 0 .. layers.length){
			if(layers[a] == cl){
				moveLayerForward(cl, layers.length - a);
			}
		}
	}

	/**
	* Move a specific layer to the back.
	*
	* Params:
	*	 cl = Layer to be moved to the back.
	*/
	void moveLayerBack(ConsoleLayer cl){
		foreach(a; 0 .. layers.length){
			if(layers[a] == cl){
				moveLayerBackward(cl, a);
			}
		}
	}

	/*
	* Moves a layer forward `amount` amount of times.
	*
	* Params:
	*	 cl = Layer to be moved. 
	*	 amount = The amount of times the layer should be moved.
	*/
	void moveLayerForward(ConsoleLayer cl, size_t amount = 1){
		foreach(c; 0 .. amount)
		foreach(a; 0 .. layers.length){
			if(layers[a] == cl && a < layers.length - 1){
				auto t = layers[a + 1];
				layers[a + 1] = layers[a];
				layers[a] = t;
			}
		}
	}

	/*
	* Moves a layer backwards	`amount` amount of times.
	*
	* Params:
	*	 cl = Layer to be moved. 
	*	 amount = The amount of times the layer should be moved.
	*/
	void moveLayerBackward(ConsoleLayer cl, size_t amount = 1){
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
	this(XY location, XY size, bool transparent = false){
		this.location = location;
        this.transparent = transparent;

		super(size);
	}

    /**
    * Is the layer transparent or not?
    */
    bool isTransparent(){
        return transparent;
    }
	
	/*
	* Returns the char at specified slot.
	*
	* Params:
	*	 location = X and Y coordinates of the slot to return.
	*/	
	override char getSlot(XY location){
		return slots[location.x][location.y];
	}
	
	/*
	* Sets a char at specified slot.
	*
	* Params:
	*	 location = X and Y coordinates of the slot to change.
	*	 a = The char to set in the slot.
	*/	
	void setSlot(XY location, char a){
		slots[location.x][location.y] = a;
	}
}

