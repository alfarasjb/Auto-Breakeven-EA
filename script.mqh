
#property copyright "Copyright 2023, Jay Benedict Alfaras" 
#property version   "1.00"
#property strict 

#include "auto_breakeven.mqh" 
#include "app.mqh"
CAutoBreakeven auto_breakeven; 
CTradeApp trade_app; 

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   trade_app.Init(); 
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0, -1, -1); 
   trade_app.Destroy(reason); 
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- 
   auto_breakeven.Scan(); 
  }
//+------------------------------------------------------------------+

