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
* **NOTE:** You can make changes to the layers even after you've added them. See below for example!

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

###Amazing!
If you followed though this little tutorial, you should be able to use clayers! Nice! ;-)
