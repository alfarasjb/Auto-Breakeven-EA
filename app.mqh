#include <Controls/Defines.mqh> 
#include <Controls/Dialog.mqh> 
#include <Controls/Button.mqh> 
#include <Controls/Label.mqh> 


class CTradeApp : public CAppDialog {
private:
            double   dpi_scale_; 
public: 
   CTradeApp();  
   ~CTradeApp() {} 

            void     Init(); 
   virtual  bool     Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2); 
   virtual  void     Minimize(); 
   virtual  bool     ButtonCreate(CButton &bt, const string name, const int x1, const int y1); 
   
}; 

CTradeApp::CTradeApp() {
   double screen_dpi    = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI); 
   dpi_scale_           = screen_dpi / 96; 
}

bool     CTradeApp::Create(
   const long chart,
   const string name,
   const int subwin,
   const int x1,
   const int y1,
   const int x2,
   const int y2) {}
   
 

