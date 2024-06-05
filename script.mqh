
#property copyright "Copyright 2023, Jay Benedict Alfaras" 
#property version   "1.00"
#property strict 

#include <utilities/Utilities.mqh> 
#include <utilities/TradeOps.mqh>

CTradeOps   ops; 

enum Frequency { Tick, Candle }; 

input int         InpBEPointsThreshold    = 100; // Breakeven Points Threshold 
input Frequency   InpBEFrequency          = Tick; // Breakeven Frequency 

int      TradeDiffToTradePoints(string symbol, double value); 
bool     IsAboveBreakevenThreshold(int ticket); 
void     SetBreakeven(int ticket); 
void     Scan(); 
double   SymbolBid(string symbol); 
double   SymbolAsk(string symbol); 


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- 
   Scan(); 
  }
//+------------------------------------------------------------------+

double SymbolBid(string symbol) { return SymbolInfoDouble (symbol, SYMBOL_BID); }
double SymbolAsk(string symbol) { return SymbolInfoDouble (symbol, SYMBOL_ASK); }

//--- Converts trade diff into points 
int TradeDiffToTradePoints(string symbol, double value) {
   double points = SymbolInfoDouble(symbol, SYMBOL_POINT);  // 1e-5  
   int trade_pts = value / points; 
   return trade_pts;
}

//--- Checks if ticket is above breakeven threshold 
bool IsAboveBreakevenThreshold(int ticket) {
   if (ticket != ops.PosTicket()) int s = ops.OP_OrderSelectByTicket(ticket);  
   if (!ops.PosProfit()) return false;  
   
   ENUM_ORDER_TYPE order_type = ops.PosOrderType();  
   double trade_diff = 0; 
   string symbol = ops.PosSymbol();
   switch (order_type) {
      case ORDER_TYPE_BUY: 
         trade_diff  = SymbolBid(symbol) - ops.PosOpenPrice(); 
         if (trade_diff < 0) return false; 
         break; 
      case ORDER_TYPE_SELL:
         trade_diff  = ops.PosOpenPrice() - SymbolAsk(symbol);
         if (trade_diff < 0) return false; 
         break; 
      default:
         // pending  
         return false; 
   }
   int points = TradeDiffToTradePoints(symbol, trade_diff);  
   return points > InpBEPointsThreshold; 
} 

//--- Sets breakeven for specified ticket 
void SetBreakeven(int ticket) {
   if (ticket != ops.PosTicket()) int s = ops.OP_OrderSelectByTicket(ticket); 
   bool m = ops.OP_ModifySL(ticket, ops.PosOpenPrice()); 
   // Set Logs here 
}

//--- Scans order pool for trades above threshold 
void Scan() { 
   if (InpBEFrequency == Candle && !UTIL_IS_NEW_CANDLE()) return;   
   if (!UTIL_ACCOUNT_PROFIT()) return; 
   for (int i = 0; i < ops.PosTotal(); i++) {
      int s = ops.OP_OrderSelectByIndex(i);  
      int ticket = ops.PosTicket();
      if (!IsAboveBreakevenThreshold(ticket)) continue; 
      SetBreakeven(ticket); 
   } 
}
