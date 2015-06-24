module clayers;
import std.stdio;
import std.algorithm;
import std.conv;

/*
	TODO
	* Better logging
	* Fix all uncertainties, aka other TODO's
*/

struct XY{size_t x,y;}

class ConsoleWindow{

	//TODO: Should layers be able to have their own sub-layers, which in turn could have even more sub-layers? I can see some pretty interesting things with this. If not, just change protected to private. ;-)
	protected ConsoleLayer[] layers;
	protected XY size;
	protected dchar[][] slots;
	protected dchar[][] changeBuffert;

	private File log;

	this(XY size = XY(80, 24)){

		log = File("clayers.log", "w+");

		//To get access to the windows console
		version(Windows){
			hOutput = GetStdHandle(handle);
		}

		this.size = size;

		//Sets the width and height.
		slots = new dchar[][](size.x, size.y);	
		//Set every tile to be the background.
		foreach(x; 0 .. size.x) slots[x][0 .. $] = ' ';

		//Print out all the tiles to remove junk characters
		scp(XY(0, 0));

		foreach(y; 0 .. size.y)
		foreach(x; 0 .. size.x){
			scp(XY(x,y));
			write(slots[x][y]);
		}

		//Save to the change buffert
		changeBuffert = slots;
	}

	void clayersLog(string s){
		log.writeln(s);	
	}

	//Functions to operate correctly with console/terminal
	private{
		version(Windows){
			import core.sys.windows.windows;
			import std.algorithm;
			uint handle = STD_ERROR_HANDLE;
			CONSOLE_SCREEN_BUFFER_INFO info;
			HANDLE hOutput;
			
			XY screenSize() @property{
				GetConsoleScreenBufferInfo( hOutput, &info );
				return XY(info.srWindow.Right  - info.srWindow.Left + 1, info.srWindow.Bottom - info.srWindow.Top  + 1);
			}

			/**
			* Set cursor position
			*/
			void scp(XY pos){
				COORD c = {cast(short)min(screenSize.x, max(0,pos.x)), cast(short)max(0, pos.y)};
				stdout.flush();
				SetConsoleCursorPosition(hOutput, c);
			}

		}else version(Posix){
			/**
			* Set cursor position
			*/
			void scp(XY pos){
				stdout.flush();
				writef("\033[%d;%df", pos.y + 1, pos.x + 1);
			}
		}
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
	 * Returns the dchar at the specific X and Y coordinates in the window.
	*/
	dchar getSlot(XY location){
		return snap()[location.x][location.y];
	}

	/**
	* Prints all the layers in the correct order.
	*/
	void print(){
		dchar[][] writes = snap();

		if(writes == changeBuffert)
			return;

		foreach(y; 0 .. size.y)
		foreach(x; 0 .. size.x){
			if(writes[x][y] != changeBuffert[x][y]){
				scp(XY(x,y));
				write(writes[x][y]);
			}
		}

		changeBuffert = writes;
		scp(XY(0, 0));
	}
	
	/*
	* Returns a 'snap', snapshot, of all the layers merged.
	*/
	dchar[][] snap(){
		//Thanks ketmar from #d
		dchar[][] snap = new dchar[][](slots.length, slots[0].length);
		foreach (x, col; snap) col[] = slots[x][];

		foreach(a; 0 .. layers.length)
			if(layers[a].visible){
				foreach(x; 0 .. layers[a].size.x)
				foreach(y; 0 .. layers[a].size.y)
					if(!(layers[a].transparent && layers[a].getSlot(XY(x,y)) == ' '))
						snap[x+layers[a].location.x][y+layers[a].location.y] = layers[a].getSlot(XY(x,y));
		}
		return snap;
	}

	/**
	* Adds a new layer.
	* DO NOT USE `addLayer(new ConsoleLayer(...))`, because there is no way to remove the layer otherwise.
	*
	* Params:
	*	 cl = Should be a already defined layer.
	*/
	void addLayer(ConsoleLayer cl){
		cl.setParent(this);
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
				cl.removeParent();
				layers = remove(layers, n);
				return;
			}
		}
		clayersLog("A layer could not be removed.");
	}

}

class ConsoleLayer : ConsoleWindow{
	private ConsoleWindow parent;

	protected XY location;
	protected bool transparent_ = false, visible_ = true;

	this(XY location, XY size, bool transparent = false){
		this.location = location;
		this.transparent = transparent;
		
		super(size);
	}

	protected void setParent(ConsoleWindow cw){
		parent = cw;
	}
	protected void removeParent(){
		parent = null;
	}

	@property{
		/**
		* Is the layer transparent or not?
		*/
		bool transparent(){
			return transparent_;
		}
		
		bool transparent(bool isTransparent){
			return transparent_ = isTransparent;
		}
		
		/**
		* Is the layer visible or not?
		*/
		bool visible(){
			return visible_;
		}
		
		bool visible(bool isVisible){
			return visible_ = isVisible;
		}
	}
	
	/*
	* Returns the dchar at specified slot.
	*
	* Params:
	*	 location = X and Y coordinates of the slot to return.
	*/	
	override dchar getSlot(XY location){
		return slots[location.x][location.y];
	}
	
	/*
	* Functions like std.stdio.write(), only it writes in the layer.
	*
	* Params:
	*	 xy = X and Y positions of where to write.
	*	 c = The character to write.
	*/
	void write(XY xy, dchar c){
		try{
			slots[xy.x][xy.y] = c;
		}catch{
			clayersLog("Warning: Failed to write " ~ text(c));
		}
	}

	/*
	* Functions like std.stdio.write(), only it writes in the layer.
	*
	* Params:
	*	 xy = X and Y positions of where to write.
	*	 c = The character to write.
	*/
	void write(XY xy, char c){
		try{
			slots[xy.x][xy.y] = c;
		}catch{
			clayersLog("Warning: Failed to write " ~ text(c));
		}
	}

	/*
	* Functions like std.stdio.write(), only it writes in the layer. Does not wrap. 
	*
	* Params:
	*	 xy = X and Y positions of where to write.
	*	 s = The string to be written.
	*/
	void write(XY xy, string s){
		foreach(a; 0 .. s.length){
			try{
				//int split = cast(int)((xy.x + a) / size.x);
				slots[xy.x + a][xy.y] = s[a];
			}catch{
				clayersLog("Warning: Failed to write " ~ s ~ ", specifically " ~ text(s[a]) ~ ", letter #" ~ text(a + 1));
			}
		}
	}

	/**
	* Remove the layer.
	*/
	void remove(){
		parent.removeLayer(this);
	}
	/**
	* Moves the layer to the front.
	*
	* Params:
	*	 cl = Layer to be moved to the front.
	*/
	void moveToFront(){
		moveForward(parent.layers.length);
	}

	/**
	* Moves the layer to the back.
	*
	* Params:
	*	 cl = Layer to be moved to the back.
	*/
	void moveToBack(){
		moveBackward(parent.layers.length);
	}

	/*
	* Moves the layer forward `amount` amount of times.
	*
	* Params:
	*	 cl = Layer to be moved. 
	*	 amount = The amount of times the layer should be moved.
	*/
	void moveForward(size_t amount = 1){
		foreach(c; 0 .. amount)
		foreach(a; 0 .. parent.layers.length){
			if(parent.layers[a] == this && a < parent.layers.length - 1){
				auto t = parent.layers[a + 1];
				parent.layers[a + 1] = parent.layers[a];
				parent.layers[a] = t;
			}
		}
	}

	/*
	* Moves the layer backwards `amount` amount of times.
	*
	* Params:
	*	 cl = Layer to be moved. 
	*	 amount = The amount of times the layer should be moved.
	*/
	void moveBackward(size_t amount = 1){
		foreach(c; 0 .. amount)
		foreach(a; 0 .. parent.layers.length){
			if(parent.layers[a] == this && a > 0){
				auto t = parent.layers[a - 1];
				parent.layers[a - 1] = parent.layers[a];
				parent.layers[a] = t;
			}
		}
	}
}

