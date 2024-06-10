#include "definition.mqh"

class CTradeApp : public CAppDialog {
private:
            double   dpi_scale_;  
            
            //--- Buttons
            CButton  increment_be_bt_, decrement_be_bt_, be_all_bt_; 
            
            //--- Fields
            CEdit    be_field_;  
            
            //--- Labels
            CLabel   be_label_; 
            
            int      Scale(double value)     { return (int)MathRound(value * dpi_scale_); }
public: 
   CTradeApp();  
   ~CTradeApp();

            void     Init(); 
   virtual  bool     Create(const long chart, const string name, const int subwin, const int x1, const int y1); 
   virtual  void     Minimize(); 
   virtual  bool     ButtonCreate(CButton &bt, const string name, const int x1, const int y1); 
   
   //--- Templates
   virtual  bool     CreateTextField(CEdit &field, CLabel &field_label, const string field_name, const string field_text, const string label_name, const string label_text, const int x1, const int y1);  
   virtual  bool     CreateAdjustButton(CButton &bt, const string name, const int x1, const int y1, const int x2, const int y2, const string text);  
   virtual  bool     CTradeApp::CreateTextFieldLabel(CLabel &field_label, const string label_name, const string label_text, const int x1, const int y1, const int y1, const int y2); 
   virtual  bool     CTradeApp::CreateWideButton(CButton &bt, const string name, const int x1, const int y1, const int x2, const int y2, const string text);
   //--- Fields 
   virtual  bool     CreateBERow(); 
   
   //--- Buttons
   virtual  bool     CreateBEAllButton(); 
   
   //--- Event Handlers
            void     OnClickIncrementBEPoints(); 
            void     OnClickDecrementBEPoints(); 
            void     OnStartEditBEField(); 
            void     OnEndEditBEField(); 
            void     OnClickBEAllPositions(); 
   
   //--- Event Mapping 
            EVENT_MAP_BEGIN(CTradeApp)
            ON_EVENT(ON_CLICK, increment_be_bt_, OnClickIncrementBEPoints); 
            ON_EVENT(ON_CLICK, decrement_be_bt_, OnClickDecrementBEPoints); 
            ON_EVENT(ON_CLICK, be_all_bt_, OnClickBEAllPositions); 
            ON_EVENT(ON_START_EDIT, be_field_, OnStartEditBEField); 
            ON_EVENT(ON_END_EDIT, be_field_, OnEndEditBEField); 
            EVENT_MAP_END(CAppDialog)
   
}; 

//--- App Constructor 
CTradeApp::CTradeApp() {
   double screen_dpi    = (double)TerminalInfoInteger(TERMINAL_SCREEN_DPI); 
   dpi_scale_           = screen_dpi / 96; 
}

//--- App Destructor 
CTradeApp::~CTradeApp() {
   
}

//--- Init function. Called OnInit 
void     CTradeApp::Init() {
   bool  c  = Create(0, "Auto Breakeven", 0, MAIN_PANEL_X1, MAIN_PANEL_Y1); 
   Run(); 
}

//--- Minimizes Panel
void     CTradeApp::Minimize() {
   CAppDialog::Minimize(); 
}

//--- Creates the app. Called by Init function 
bool     CTradeApp::Create(
   const long chart,
   const string name,
   const int subwin,
   const int x1,
   const int y1) {
   
   int scaled_x2  = x1 + Scale(MAIN_PANEL_WIDTH); 
   int scaled_y2  = y1 + Scale(MAIN_PANEL_HEIGHT); 
   
   if (!CAppDialog::Create(chart, name, subwin, x1, y1, scaled_x2, scaled_y2)) return false; 
   if (!CreateBERow()) return false;  
   if (!CreateBEAllButton()) return false; 
   return true;       
}

bool     CTradeApp::CreateTextField(
   CEdit &field,
   CLabel &field_label,
   const string field_name,
   const string field_text,
   const string label_name,
   const string label_text,
   const int x1,
   const int y1) {  
   
   int x2   = x1 + PRICE_FIELD_WIDTH; 
   int y2   = y1 + PRICE_FIELD_HEIGHT; 
   //--- Field
   if (!field.Create(0, field_name, 0, x1, y1, x2, y2)) return false; 
   if (!field.TextAlign(ALIGN_CENTER)) return false; 
   if (!field.Text(field_text)) return false; 
   if (!field.Font(CONTROLS_FONT_NAME)) return false; 
   if (!Add(field)) return false; 
   
   //--- Label 
   if (!CreateTextFieldLabel(field_label, label_name, label_text, x2-5, y1+2, x2, y2)) return false; 
   return true; 
}

bool     CTradeApp::CreateTextFieldLabel(CLabel &field_label, const string label_name, const string label_text, const int x1, const int y1, const int x2, const int y2) {
   string lbl_name = label_name+"_label"; 
   if (!field_label.Create(0, lbl_name, 0, x1, y1, x2, y2)) return false;
   if (!field_label.Text(label_text)) return false; 
   if (!ObjectSetInteger(0, field_label.Name(), OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER)) return false; 
   if (!field_label.FontSize(FIELD_LABEL_FONT_SIZE)) return false; 
   if (!Add(field_label)) return false; 
   return true;
}

bool     CTradeApp::CreateAdjustButton(CButton &bt,const string name,const int x1,const int y1,const int x2,const int y2,const string text) {
   
   if (!bt.Create(0, name, 0, x1, y1, x2, y2)) return false;
   if (!bt.Text(text)) return false;
   if (!bt.Font(CONTROLS_FONT_NAME)) return false; 
   if (!Add(bt)) return false; 
   return true;
}

bool     CTradeApp::CreateWideButton(CButton &bt, const string name, const int x1, const int y1, const int x2, const int y2, const string text) {
   if (!bt.Create(0, name, 0, x1, y1, x2, y2)) return false; 
   if (!bt.Text(text)) return false; 
   if (!bt.Font(CONTROLS_FONT_NAME)) return false; 
   if (!Add(bt)) return false; 
   return true; 
}
//--- Creates BE Row
bool     CTradeApp::CreateBERow() {
   // TODO
   // All scaling goes here 
   int y1   = PRICE_FIELD_INDENT_TOP; 
   int y2   = y1 + ADJ_BUTTON_SIZE; 
   
   int dec_x1  = 10;
   int dec_x2  = dec_x1 + ADJ_BUTTON_SIZE; 
   
   if (!CreateAdjustButton(decrement_be_bt_, "SubBE", dec_x1, y1, Scale(dec_x2), Scale(y2), "-")) return false;  
   if (!CreateTextField(be_field_, be_label_, "BEField", (string)InpBEPointsThreshold, "Points-BE", "Points", Scale(dec_x2), y1)) return false; 
   
   int inc_x1  = be_field_.Right() - 14; 
   int inc_x2  = inc_x1 + ADJ_BUTTON_SIZE; 
   if (!CreateAdjustButton(increment_be_bt_, "AddBE", inc_x1, y1, Scale(inc_x2), Scale(y2), "+")) return false; 
   
   return true;
}
   
bool     CTradeApp::CreateBEAllButton() {
   // TODO
   int x1   = 10; // Offset from app left 
   int x2   = x1 + WIDE_BUTTON_WIDTH; 
   int y1   = 50; 
   int y2   = y1 + Scale(WIDE_BUTTON_HEIGHT);  
   if (!CreateWideButton(be_all_bt_, "BEAll", x1, y1, x2, y2, "BE All")) return false; 
   return true; 
}

