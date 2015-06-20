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

## Usage
Start off by creating a new ConsoleWindow. It's from here you handle all layers.
```d
auto window = new ConsoleWindow(XY(80, 24));
```
XY(80,24) tells the size of the window (in amount of slots). You can make it smaller or bigger, but 80x24 is the standard console window size.

Now add a new layer! It's easy, just do:
```d
auto layer = new ConsoleLayer(XY(0, 0), XY(15, 15));
window.addLayer(layer);
```
This creates a new layer at position 0,0 with the size of 15x15 slots, and then the layer is added to the window.
***NOTE:** You can make changes to the layers even after you've added them. See below for example!*

Okay! Layer is set, but let's add a some text, and maybe a little star ;-)
```d
layer.layerWrite(XY(0, 0), "Hello World!");
layer.layerWrite(XY(7, 7), '*');
```
Now we've added some text at (0,0), and a star in the middle (7,7) of the screen! Good job!

Hm... Maybe we should add a new layer? Or maybe two? Yeah just follow along.
```d
auto layer2 = new ConsoleLayer(XY(60, 0), XY(20, 24)); //A sidebar                                            
auto layer3 = new ConsoleLayer(XY(50, 9), XY(15, 5)); //Small box


window.addLayer(layer2);
window.addLayer(layer3);

//some code for visualisation
foreach(y; 0 .. 15) layer. layerWrite(XY(0, y), "...............");
foreach(y; 0 .. 24) layer2.layerWrite(XY(0, y), "*********************");
foreach(y; 0 .. 5)  layer3.layerWrite(XY(0, y), "---------------");

```
So what we have now is like this:

* layer3 (---)
* layer2 (***)
* layer (...)
* window

Now to actually see what we have done, let's run the almighty command
```d
window.print();
```
to see what we have so far!

You should get something like this:
[**There is supposed to be an image here, but I haven't added it yet**]

Now notice how layer3 is ontop of layer2. Let's change that.
```d
layer3.moveLayerBackward(1);
```
What this line of code does is simply moving layer3 backwards **1** step. There are other of course the other commands ```moveLayerForward()```, ```moveLayerFront()``` and ```moveLayerBack()```, 

Now what we have is like this:

* layer2 (***)
* layer3 (---)
* layer (...)
* window

and we get this:
[**Would you look at that image I haven't added yet**]

Hmm, let's not show that ugly box though.
```d
layer3.visible(false);
```
Now the box won't get printed.

You know what? I really dislike that box so much I just want it gone from my life.
```d
layer3.remove(); //or alternatively window.removeLayer(layer3);
```

###Amazing!jj
If you followed though this little tutorial, you should be able to use clayers! Nice! ;-)

## Reference
### class ```ConsoleWindow```

```@propery size_t width()```
Returns the width of the window/layer.

```@propery size_t height()```
Returns the width of the window/layer.

```getSlot(XY location)```
Returns the char at the specific X and Y coordinates in the window. 

```void print()```
Prints all the layers in the correct order.

```char[][] snap()```
Returns a 'snap', snapshot, of all the layers merged.

```void addLayer(ConsoleLayer cl)```
Adds a new layer.
DO NOT USE ```new ConsoleLayer(...)```, because there is no way to remove the layer otherwise.

```void removeLayer(ConsoleLayer cl)```
Removes a specific layer

### class ```ConsoleLayer``` inherits from ```ConsoleWindow```
```@property bool transparent```
```@property bool transparent(bool isTransparent)```
Is the layer transparent or not?

```@property bool visible()```
```@property bool visible(bool isVisible)```
Is the layer visible or not?

```override char getSlot(XY location)```
Returns the char at specified slot.

```void layerWrite(XY xy, char c)```
Functions like std.stdio.write(), only it writes in the layer.

```void layerWrite(XY xy, string s)```
Functions like std.stdio.write(), only it writes in the layer. Does wrap around badly, no overflow.

```void remove()```
Calls removeLayer(this);

```void moveLayerFront()```
Moves the layer to the front.

```void moveLayerBack()```
Moves the layer to the back.

```void moveLayerForward(size_t amount = 1)```
Moves the layer forward `amount` amount of times.

```void moveLayerBackward(size_t amount = 1)```
Moves the layer backwards `amount` amount of times.

