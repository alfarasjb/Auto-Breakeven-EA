#include <utilities/TradeOps.mqh> 

#include "definition.mqh" 

class CAutoBreakeven : public CTradeOps { 

private: 
      //--- Private member variables 
      int      be_points_, step_, min_points_; 

      void     SetBreakeven(const int ticket); 
      int      TradeDiffToTradePoints(const string symbol, double value); 
      
      //--- Boolean 
      bool     IsAboveBreakevenThreshold(const int ticket); 
      bool     IsNewCandle(); 
      bool     AccountInProfit() const { return AccountInfoDouble(ACCOUNT_PROFIT); }
      double   SymbolBid(const string symbol) const   { return SymbolInfoDouble(symbol, SYMBOL_BID); }
      double   SymbolAsk(const string symbol) const   { return SymbolInfoDouble(symbol, SYMBOL_ASK); } 

public:
      CAutoBreakeven() : be_points_(InpBEPointsThreshold), step_(InpStep), min_points_(InpMinPoints) {}  
      ~CAutoBreakeven() {}
      void     Scan();
      int      BreakevenAllPositions();  
      
      
      //--- Wrapper 
      int      BEPoints() const     { return be_points_; }
      void     BEPoints(int value)  { be_points_ = value; }
      
      int      Step() const         { return step_; }    
      void     Step(int value)      { step_ = value; } 
      
      int      Increment(int value) { return value += Step(); }
      int      Decrement(int value) { return value -= Step(); }  
      
      int      MinPoints() const    { return min_points_; }
      void     MinPoints(int value) { min_points_ = value; }
      
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
   
   return points > be_points_; 
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

//--- Sets all positions to breakeven 
int    CAutoBreakeven::BreakevenAllPositions() {
   if (PosTotal() == 0) {
      Console_.LogInformation("No trades to modify. Order pool is empty.", __FUNCTION__);    
      return 0; 
   }
   
   Console_.LogInformation(StringFormat("%i trades found. Attempting to set breakeven.", PosTotal()), __FUNCTION__); 
   int s, ticket, num_modified = 0; 
   for (int i = 0; i < PosTotal(); i++) {
      s = OP_OrderSelectByIndex(i); 
      ticket = PosTicket(); 
      
      if (!OP_ModifySL(ticket, PosOpenPrice())) continue; 
      num_modified++; 
   }
   return num_modified; 
}