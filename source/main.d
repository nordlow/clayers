import clayers;

void main(){
    bool gameloop = true;

    int split = 50;

    auto window = new ConsoleWindow(XY(80, 24));

    auto layerMain    = new ConsoleLayer(XY(0,  0), XY(split, window.height));
    auto layerSidebar = new ConsoleLayer(XY(split, 0), XY(window.width - split, window.height)); //A sidebar
    auto layerPopup   = new ConsoleLayer(XY(2, 15), XY(window.width - 5, 7 )); //Opaque box
    auto layerPopup2  = new ConsoleLayer(XY(42, 4), XY(30, 15)); //Transparent box

    window.addLayer(layerMain);
    window.addLayer(layerSidebar);
    window.addLayer(layerPopup);
    window.addLayer(layerPopup2);

    layerPopup2.transparent(true);
    layerPopup2.moveBackward();

    foreach(x; 0 .. layerPopup.width)
        foreach(y; 0 .. layerPopup.height){
            if(x == 0 || x == layerPopup.width - 1 || y == 0 || y == layerPopup.height - 1)
                layerPopup.write(XY(x,y), '*');
        }

    foreach(x; 0 .. layerPopup2.width)
        foreach(y; 0 .. layerPopup2.height){
            if(x == 0 || x == layerPopup2.width - 1 || y == 0 || y == layerPopup2.height - 1)
                layerPopup2.write(XY(x,y), '#', fg.yellow, bg.red, mode.bold);
        }

    foreach(x; 0 .. layerSidebar.width)
        foreach(y; 0 .. layerSidebar.height)
        if(x == 0 || x == layerSidebar.width - 1 || y == 0 || y == layerSidebar.height - 1)
            layerSidebar.write(XY(x,y), '+');

    foreach(x; 0 .. layerMain.width)
        foreach(y; 0 .. layerMain.height)
        if(x % 2 == 0 && x < layerMain.width)
            layerMain.write(XY(x,y), '.', fg.blue);

    layerPopup.write(XY(2, 2), "This is a popup! There could be some information in here.");
    layerPopup.write(XY(2, 4), "For instance, this layer is opaque.");

    layerPopup2.write(XY(2, 2), "This box is translucent.");
    layerPopup2.write(XY(2, 8), "This layer is also behind", fg.yellow, bg.white);
    layerPopup2.write(XY(2, 9), "that one |", fg.yellow, bg.white);
    layerPopup2.write(XY(11, 10), 'V', fg.yellow, bg.white);

    while(gameloop)
        window.print();
}