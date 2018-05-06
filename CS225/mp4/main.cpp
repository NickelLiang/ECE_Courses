
#include "cs225/PNG.h"
#include "FloodFilledImage.h"
#include "Animation.h"

#include "imageTraversal/DFS.h"
#include "imageTraversal/BFS.h"

#include "colorPicker/RainbowColorPicker.h"
#include "colorPicker/GradientColorPicker.h"
#include "colorPicker/GridColorPicker.h"
#include "colorPicker/SolidColorPicker.h"
#include "colorPicker/MyColorPicker.h"

#include <iostream>

using namespace cs225;



int main() {
    PNG Background; Background.readFromFile("Background.png");
    cout << "Background.png Loaded." << endl;
    PNG iPhone; iPhone.readFromFile("iPhone.png");
    cout << "iPhone.png Loaded." << endl;
    PNG iPad; iPad.readFromFile("iPad.png");
    cout << "iPad.png Loaded." << endl;
    PNG iPad_Screen; iPad_Screen.readFromFile("iPad_Screen.png");
    cout << "iPad_Screen.png Loaded." << endl;
    PNG MacBook; MacBook.readFromFile("MacBook.png");
    cout << "MacBook.png Loaded." << endl;
    PNG MacBook_Screen; MacBook_Screen.readFromFile("MacBook_Screen.png");
    cout << "MacBook_Screen.png Loaded." << endl;
    PNG iMac; iMac.readFromFile("iMac.png");
    cout << "iMac.png Loaded." << endl;
    PNG iMac_Screen; iMac_Screen.readFromFile("iMac_Screen.png");
    cout << "iMac_Screen.png Loaded." << endl;

    double factor = (double)Background.width() / 1080;
    cout << "Factor" << factor << endl;
    unsigned interval_logo = 10000;
    unsigned interval_reverse = 50000;
    unsigned interval_iphone = 1000;
    unsigned interval_ipad = 2500;
    unsigned interval_macbook = 4000;
    unsigned interval_imac = 5500;
    unsigned interval = 10000;
    unsigned pause = 20;
    double tolerance = 0.05;

    MyColorPicker bkg(0xfafafa);
    MyColorPicker logo(0x999999);
    MyColorPicker blue(0x4285F4);
    MyColorPicker green(0x34A853);
    MyColorPicker yellow(0xFBBC05);
    MyColorPicker red(0xEA4335);
    cout << "Color Computed." << endl;

    /* Fill Logo */
    // BFS _1_bfs(iPhone, Point(540*factor, 320*factor), tolerance);
    // FloodFilledImage _1_logo_body(Background);
    // _1_logo_body.addFloodFill(_1_bfs, logo);
    // Animation animation = _1_logo_body.animate(interval_logo);
    // cout << "_1_logo_body Filled." << endl;
    //
    // BFS _2_bfs(iPhone, Point(540*factor, 310*factor), tolerance);
    // FloodFilledImage _2_logo_leaf(animation.getFrame(animation.frameCount() - 1));
    // _2_logo_leaf.addFloodFill(_2_bfs, logo);
    // Animation _2_animation = _2_logo_leaf.animate(interval_logo);
    // for (unsigned i = 0; i < _2_animation.frameCount(); i++)
    //     animation.addFrame(_2_animation.getFrame(i));
    // cout << "_2_logo_leaf Filled." << endl;
    //
    // DFS _3_dfs(iPhone, Point(508*factor, 272*factor), tolerance);
    // FloodFilledImage _3_iPhone_screen(animation.getFrame(animation.frameCount() - 1));
    // _3_iPhone_screen.addFloodFill(_3_dfs, red);
    // cout << "_3_iPhone_screen Flood." << endl;
    // Animation _3_animation = _3_iPhone_screen.animate(interval);
    // cout << "_3_iPhone_screen Computed." << endl;
    // for (unsigned i = 0; i < _3_animation.frameCount(); i++)
    //     animation.addFrame(_3_animation.getFrame(i));
    // cout << "_3_iPhone_screen Filled." << endl;

    /* Clear boarder */
    BFS _19r_bfs(iMac_Screen, Point(540*factor, 360*factor), tolerance);
    FloodFilledImage _19r_iMac_frame(Background);
    _19r_iMac_frame.addFloodFill(_19r_bfs, bkg);
    Animation animation = _19r_iMac_frame.animate(100000);
    cout << "_19r_iMac_frame Filled." << endl;

    /* Fill iPhone with Blue */
    DFS _0_dfs(iPhone, Point(508*factor, 272*factor), tolerance);
    FloodFilledImage _0_iPhone_screen(animation.getFrame(animation.frameCount() - 1));
    _0_iPhone_screen.addFloodFill(_0_dfs, blue);
    Animation _0_animation = _0_iPhone_screen.animate(interval_iphone);
    for (unsigned i = 0; i < _0_animation.frameCount(); i++)
        animation.addFrame(_0_animation.getFrame(i));
    cout << "_0_iPhone_screen Filled." << endl;

    /* Fill iPhone outline with Red */
    BFS _1_bfs(iPhone, Point(506*factor, 271*factor), tolerance);
    FloodFilledImage _1_iPhone_frame(animation.getFrame(animation.frameCount() - 1));
    _1_iPhone_frame.addFloodFill(_1_bfs, red);
    Animation _1_animation = _1_iPhone_frame.animate(interval_iphone);
    for (unsigned i = 0; i < _1_animation.frameCount(); i++)
        animation.addFrame(_1_animation.getFrame(i));
    cout << "_1_iPhone_frame Filled." << endl;

    BFS _2_bfs(iPhone, Point(501*factor, 252*factor), tolerance);
    FloodFilledImage _2_iPhone_frame(animation.getFrame(animation.frameCount() - 1));
    _2_iPhone_frame.addFloodFill(_2_bfs, red);
    Animation _2_animation = _2_iPhone_frame.animate(interval_iphone);
    for (unsigned i = 0; i < _2_animation.frameCount(); i++)
        animation.addFrame(_2_animation.getFrame(i));
    cout << "_2_iPhone_frame Filled." << endl;

    BFS _3_bfs(iPhone, Point(525*factor, 257*factor), tolerance);
    FloodFilledImage _3_iPhone_frame(animation.getFrame(animation.frameCount() - 1));
    _3_iPhone_frame.addFloodFill(_3_bfs, red);
    Animation _3_animation = _3_iPhone_frame.animate(interval_iphone);
    for (unsigned i = 0; i < _3_animation.frameCount(); i++)
        animation.addFrame(_3_animation.getFrame(i));
    cout << "_3_iPhone_frame Filled." << endl;

    BFS _4_bfs(iPhone, Point(533*factor, 257*factor), tolerance);
    FloodFilledImage _4_iPhone_frame(animation.getFrame(animation.frameCount() - 1));
    _4_iPhone_frame.addFloodFill(_4_bfs, red);
    Animation _4_animation = _4_iPhone_frame.animate(interval_iphone);
    for (unsigned i = 0; i < _4_animation.frameCount(); i++)
        animation.addFrame(_4_animation.getFrame(i));
    cout << "_4_iPhone_frame Filled." << endl;

    BFS _5_bfs(iPhone, Point(533*factor, 385*factor), tolerance);
    FloodFilledImage _5_iPhone_frame(animation.getFrame(animation.frameCount() - 1));
    _5_iPhone_frame.addFloodFill(_5_bfs, red);
    Animation _5_animation = _5_iPhone_frame.animate(interval_iphone);
    for (unsigned i = 0; i < _5_animation.frameCount(); i++)
        animation.addFrame(_5_animation.getFrame(i));
    cout << "_5_iPhone_frame Filled." << endl;

    BFS _6_bfs(iPhone, Point(538*factor, 385*factor), tolerance);
    FloodFilledImage _6_iPhone_frame(animation.getFrame(animation.frameCount() - 1));
    _6_iPhone_frame.addFloodFill(_6_bfs, red);
    Animation _6_animation = _6_iPhone_frame.animate(interval_iphone);
    for (unsigned i = 0; i < _6_animation.frameCount(); i++)
        animation.addFrame(_6_animation.getFrame(i));
    cout << "_6_iPhone_frame Filled." << endl;

    /* Add a pause */
    for (unsigned i = 0; i < pause; i++)
        animation.addFrame(animation.getFrame(animation.frameCount() - 1));
    cout << "Pause Added." << endl;




    /* Fill iPad with Red */
    DFS _7_dfs(iPad, Point(451*factor, 202*factor), tolerance);
    FloodFilledImage _7_iPad_screen(animation.getFrame(animation.frameCount() - 1));
    _7_iPad_screen.addFloodFill(_7_dfs, red);
    Animation _7_animation = _7_iPad_screen.animate(interval_ipad);
    for (unsigned i = 0; i < _7_animation.frameCount(); i++)
        animation.addFrame(_7_animation.getFrame(i));
    cout << "_7_iPad_screen Filled." << endl;

    /* Fill iPad frame with Yellow */
    BFS _8_bfs(iPad, Point(447*factor, 312*factor), tolerance);
    FloodFilledImage _8_iPad_frame(animation.getFrame(animation.frameCount() - 1));
    _8_iPad_frame.addFloodFill(_8_bfs, yellow);
    Animation _8_animation = _8_iPad_frame.animate(interval_ipad);
    for (unsigned i = 0; i < _8_animation.frameCount(); i++)
        animation.addFrame(_8_animation.getFrame(i));
    cout << "_8_iPad_frame Filled." << endl;

    BFS _9_bfs(iPad, Point(435*factor, 176*factor), tolerance);
    FloodFilledImage _9_iPad_frame(animation.getFrame(animation.frameCount() - 1));
    _9_iPad_frame.addFloodFill(_9_bfs, yellow);
    Animation _9_animation = _9_iPad_frame.animate(interval_ipad);
    for (unsigned i = 0; i < _9_animation.frameCount(); i++)
        animation.addFrame(_9_animation.getFrame(i));
    cout << "_9_iPad_frame Filled." << endl;

    BFS _10_bfs(iPad, Point(538*factor, 184*factor), tolerance);
    FloodFilledImage _10_iPad_frame(animation.getFrame(animation.frameCount() - 1));
    _10_iPad_frame.addFloodFill(_10_bfs, yellow);
    Animation _10_animation = _10_iPad_frame.animate(interval_ipad);
    for (unsigned i = 0; i < _10_animation.frameCount(); i++)
        animation.addFrame(_10_animation.getFrame(i));
    cout << "_10_iPad_frame Filled." << endl;

    BFS _11_bfs(iPad, Point(533*factor, 460*factor), tolerance);
    FloodFilledImage _11_iPad_frame(animation.getFrame(animation.frameCount() - 1));
    _11_iPad_frame.addFloodFill(_11_bfs, yellow);
    Animation _11_animation = _11_iPad_frame.animate(interval_ipad);
    for (unsigned i = 0; i < _11_animation.frameCount(); i++)
        animation.addFrame(_11_animation.getFrame(i));
    cout << "_11_iPad_frame Filled." << endl;

    BFS _12_bfs(iPad, Point(538*factor, 460*factor), tolerance);
    FloodFilledImage _12_iPad_frame(animation.getFrame(animation.frameCount() - 1));
    _12_iPad_frame.addFloodFill(_12_bfs, yellow);
    Animation _12_animation = _12_iPad_frame.animate(interval_ipad);
    for (unsigned i = 0; i < _12_animation.frameCount(); i++)
        animation.addFrame(_12_animation.getFrame(i));
    cout << "_12_iPad_frame Filled." << endl;

    /* Add a pause */
    for (unsigned i = 0; i < pause; i++)
        animation.addFrame(animation.getFrame(animation.frameCount() - 1));
    cout << "Pause Added." << endl;

    /* Clear boarder */
    BFS _12r_bfs(iPad_Screen, Point(435*factor, 176*factor), tolerance);
    FloodFilledImage _12r_iPad_frame(animation.getFrame(animation.frameCount() - 1));
    _12r_iPad_frame.addFloodFill(_12r_bfs, bkg);
    Animation _12r_animation = _12r_iPad_frame.animate(interval_ipad);
    for (unsigned i = 0; i < _12r_animation.frameCount(); i++)
        animation.addFrame(_12r_animation.getFrame(i));
    cout << "_12r_iPad_frame Filled." << endl;




    /* Fill MacBook with Yellow */
    DFS _13_dfs(MacBook, Point(339*factor, 195*factor), tolerance);
    FloodFilledImage _13_MacBook_screen(animation.getFrame(animation.frameCount() - 1));
    _13_MacBook_screen.addFloodFill(_13_dfs, yellow);
    Animation _13_animation = _13_MacBook_screen.animate(interval_macbook);
    for (unsigned i = 0; i < _13_animation.frameCount(); i++)
        animation.addFrame(_13_animation.getFrame(i));
    cout << "_13_MacBook_screen Filled." << endl;

    /* Fill MacBook frame with Green */
    BFS _14_bfs(MacBook, Point(333*factor, 189*factor), tolerance);
    FloodFilledImage _14_MacBook_frame(animation.getFrame(animation.frameCount() - 1));
    _14_MacBook_frame.addFloodFill(_14_bfs, green);
    Animation _14_animation = _14_MacBook_frame.animate(interval_macbook);
    for (unsigned i = 0; i < _14_animation.frameCount(); i++)
        animation.addFrame(_14_animation.getFrame(i));
    cout << "_14_MacBook_frame Filled." << endl;

    BFS _15_bfs(MacBook, Point(312*factor, 170*factor), tolerance);
    FloodFilledImage _15_MacBook_frame(animation.getFrame(animation.frameCount() - 1));
    _15_MacBook_frame.addFloodFill(_15_bfs, green);
    Animation _15_animation = _15_MacBook_frame.animate(interval_macbook);
    for (unsigned i = 0; i < _15_animation.frameCount(); i++)
        animation.addFrame(_15_animation.getFrame(i));
    cout << "_15_MacBook_frame Filled." << endl;

    BFS _16_bfs(MacBook, Point(538*factor, 178*factor), tolerance);
    FloodFilledImage _16_MacBook_frame(animation.getFrame(animation.frameCount() - 1));
    _16_MacBook_frame.addFloodFill(_16_bfs, green);
    Animation _16_animation = _16_MacBook_frame.animate(interval_macbook);
    for (unsigned i = 0; i < _16_animation.frameCount(); i++)
        animation.addFrame(_16_animation.getFrame(i));
    cout << "_16_MacBook_frame Filled." << endl;

    /* Add a pause */
    for (unsigned i = 0; i < pause; i++)
        animation.addFrame(animation.getFrame(animation.frameCount() - 1));
    cout << "Pause Added." << endl;

    /* Clear boarder */
    BFS _16r_bfs(MacBook_Screen, Point(312*factor, 170*factor), tolerance);
    FloodFilledImage _16r_MacBook_frame(animation.getFrame(animation.frameCount() - 1));
    _16r_MacBook_frame.addFloodFill(_16r_bfs, bkg);
    Animation _16r_animation = _16r_MacBook_frame.animate(interval_macbook);
    for (unsigned i = 0; i < _16r_animation.frameCount(); i++)
        animation.addFrame(_16r_animation.getFrame(i));
    cout << "_16r_MacBook_frame Filled." << endl;




    /* Fill iMac with Green */
    DFS _17_dfs(iMac, Point(223*factor, 119*factor), tolerance);
    FloodFilledImage _17_iMac_screen(animation.getFrame(animation.frameCount() - 1));
    _17_iMac_screen.addFloodFill(_17_dfs, green);
    Animation _17_animation = _17_iMac_screen.animate(interval_imac);
    for (unsigned i = 0; i < _17_animation.frameCount(); i++)
        animation.addFrame(_17_animation.getFrame(i));
    cout << "_17_iMac_screen Filled." << endl;

    /* Fill iMac frame with Blue */
    BFS _18_bfs(iMac, Point(216*factor, 113*factor), tolerance);
    FloodFilledImage _18_iMac_frame(animation.getFrame(animation.frameCount() - 1));
    _18_iMac_frame.addFloodFill(_18_bfs, blue);
    Animation _18_animation = _18_iMac_frame.animate(interval_imac);
    for (unsigned i = 0; i < _18_animation.frameCount(); i++)
        animation.addFrame(_18_animation.getFrame(i));
    cout << "_18_iMac_frame Filled." << endl;

    BFS _19_bfs(iMac, Point(193*factor, 96*factor), tolerance);
    FloodFilledImage _19_iMac_frame(animation.getFrame(animation.frameCount() - 1));
    _19_iMac_frame.addFloodFill(_19_bfs, blue);
    Animation _19_animation = _19_iMac_frame.animate(interval_imac);
    for (unsigned i = 0; i < _19_animation.frameCount(); i++)
        animation.addFrame(_19_animation.getFrame(i));
    cout << "_19_iMac_frame Filled." << endl;



    /* Add a pause */
    for (unsigned i = 0; i < pause; i++)
        animation.addFrame(animation.getFrame(animation.frameCount() - 1));
    cout << "Pause Added." << endl;

    PNG lastFrame = animation.getFrame(animation.frameCount() - 1);
    lastFrame.writeToFile("myFloodFill.png");
    cout << "Last Frame Saved." << endl;

    animation.write("myFloodFill.gif");
    cout << "GIF Saved." << endl;
    return 0;
}
