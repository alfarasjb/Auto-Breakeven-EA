#include <Controls/Defines.mqh> 
#include <Controls/Dialog.mqh> 
#include <Controls/Button.mqh> 
#include <Controls/Label.mqh> 

#undef      CONTROLS_FONT_SIZE
#undef      CONTROLS_FONT_NAME

#define     CONTROLS_FONT_NAME      "Calibri"
#define     MAIN_PANEL_X1  10 
#define     MAIN_PANEL_Y1  20 
#define     MAIN_PANEL_WIDTH 250 
#define     MAIN_PANEL_HEIGHT 120 

#define     PRICE_FIELD_INDENT_TOP 10  
#define     PRICE_FIELD_WIDTH 130 
#define     PRICE_FIELD_HEIGHT 20
#define     BUTTON_HEIGHT 50 
#define     ADJ_BUTTON_SIZE 20; 
#define     FIELD_LABEL_FONT_SIZE 9
#define     WIDE_BUTTON_WIDTH 210
#define     WIDE_BUTTON_HEIGHT 28

//--- Enums
enum Frequency { Tick, Candle }; 

//--- Inputs 
input int         InpBEPointsThreshold    = 100; // Breakeven Points Threshold 
input Frequency   InpBEFrequency          = Tick; // Breakeven Frequency 
