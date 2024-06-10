#include <utilities/TradeOps.mqh> 

#include "definition.mqh" 

class CAutoBreakeven : public CTradeOps { 

private: 
      void     SetBreakeven(const int ticket); 
      int      TradeDiffToTradePoints(const string symbol, double value); 
      
      //--- Boolean 
      bool     IsAboveBreakevenThreshold(const int ticket); 
      bool     IsNewCandle(); 
      bool     AccountInProfit() const { return AccountInfoDouble(ACCOUNT_PROFIT); }
      double   SymbolBid(const string symbol) const   { return SymbolInfoDouble(symbol, SYMBOL_BID); }
      double   SymbolAsk(const string symbol) const   { return SymbolInfoDouble(symbol, SYMBOL_ASK); }

public:
      CAutoBreakeven() {}  
      ~CAutoBreakeven() {  Print("Destructor"); }
      void     Scan(); 

};

bool     CAutoBreakeven::IsNewCandle() {
   //--- Checks if current candle is new candle. 
   static datetime saved_candle_time; 
   datetime current_time = iTime(Symbol(), PERIOD_CURRENT, 0); 
   
   bool new_candle = current_time != saved_candle_time; 
   
   saved_candle_time = current_time; 
   
   return new_candle; 
}

//--- Converts trade diff into points 
int      CAutoBreakeven::TradeDiffToTradePoints(string symbol, double value) {
   double points = SymbolInfoDouble(symbol, SYMBOL_POINT);  // 1e-5  
   int trade_pts = value / points; 
   
   return trade_pts;
} 

//--- Checks if ticket is above breakeven threshold 
bool     CAutoBreakeven::IsAboveBreakevenThreshold(int ticket) {
   if (ticket != PosTicket()) int s = OP_OrderSelectByTicket(ticket);  
   if (!PosProfit()) return false;  
   
   ENUM_ORDER_TYPE order_type = PosOrderType();  
   double trade_diff = 0; 
   string symbol = PosSymbol();
   switch (order_type) {
      case ORDER_TYPE_BUY: 
         trade_diff  = SymbolBid(symbol) - PosOpenPrice(); 
         if (trade_diff < 0) return false; 
         break; 
      case ORDER_TYPE_SELL:
         trade_diff  = PosOpenPrice() - SymbolAsk(symbol);
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
void     CAutoBreakeven::SetBreakeven(int ticket) {
   if (ticket != PosTicket()) int s = OP_OrderSelectByTicket(ticket); 
   bool m = OP_ModifySL(ticket, PosOpenPrice()); 
   // Set Logs here 
}


//--- Scans order pool for trades above threshold 
void     CAutoBreakeven::Scan() { 
   if (InpBEFrequency == Candle && !IsNewCandle()) return;   
   if (AccountInProfit()) return; 
   for (int i = 0; i < PosTotal(); i++) {
      int s = OP_OrderSelectByIndex(i);  
      int ticket = PosTicket();
      if (!IsAboveBreakevenThreshold(ticket)) continue; 
      SetBreakeven(ticket); 
   } 
}

