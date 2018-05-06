#include "Image.h"
#include "StickerSheet.h"

int main() {
    Image universe; universe.readFromFile("universe.png");
    Image roadster; roadster.readFromFile("roadster.png");
    Image mars;     mars.readFromFile("mars.png");
    Image mission;  mission.readFromFile("mission.png");
    Image spacex;   spacex.readFromFile("spacex.png");

    StickerSheet sheet(universe, 6);
    sheet.addSticker(mars, 443, 0);
    sheet.addSticker(mission, 51, 753);
    sheet.addSticker(spacex, 51, 1018);
    sheet.addSticker(roadster, 868, 649);

    Image output = sheet.render();
    output.writeToFile("myImage.png");
    return 0;
}
