
#property copyright "Copyright 2023, Jay Benedict Alfaras" 
#property version   "1.00"
#property strict 

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
bool     IsNewCandle(); 
bool     AccountInProfit();


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
bool  AccountInProfit() { return AccountInfoDouble(ACCOUNT_PROFIT); }

bool  IsNewCandle() {
   //--- Checks if current candle is new candle. 
   static datetime saved_candle_time; 
   datetime current_time = iTime(Symbol(), PERIOD_CURRENT, 0); 
   
   bool new_candle = current_time != saved_candle_time; 
   
   saved_candle_time = current_time; 
   return new_candle; 
   
}


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
   if (InpBEFrequency == Candle && !IsNewCandle()) return;   
   if (AccountInProfit()) return; 
   for (int i = 0; i < ops.PosTotal(); i++) {
      int s = ops.OP_OrderSelectByIndex(i);  
      int ticket = ops.PosTicket();
      if (!IsAboveBreakevenThreshold(ticket)) continue; 
      SetBreakeven(ticket); 
   } 
}
