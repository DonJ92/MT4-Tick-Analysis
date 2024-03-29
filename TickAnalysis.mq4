//+------------------------------------------------------------------+
//|                                                 TickAnalysis.mq4 |
//|                                           Copyright 2020,Jupiter |
//|                                          https://www.jupiter.com |
//+------------------------------------------------------------------+
#property copyright "10PipsScalpingAcademy"
#property link      "https://www.jupiter.com"
#property version   "1.00"
#property strict
#property indicator_chart_window


#define OBJECT_PREFIX   "TICK_ANALYSIS_"



#define  EURUSD   0
#define  EURGBP   1
#define  EURJPY   2
#define  EURAUD   3
#define  GBPUSD   4
#define  GBPJPY   5
#define  GBPAUD   6
#define  USDJPY   7
#define  AUDUSD   8
#define  AUDJPY   9

datetime g_last_time[10] = {0,0,0,0,0,0,0,0,0,0};
//================== input variables =====================
input    string   InpPrefix = "";
input    string   InpSuffix = "";

//================== global variables ====================
string   SYMBOLS[10] = {"EURUSD", "EURGBP", "EURJPY", "EURAUD", "GBPUSD", "GBPJPY", "GBPAUD","USDJPY","AUDUSD","AUDJPY"};
MqlTick  g_ticks[10];
color    g_red_colors[10] = {C'255,40,40',C'255,60,60',C'255,80,80',C'255,100,100',C'255,120,120',C'255,140,140',C'255,160,160',C'255,190,190',C'255,220,220',C'255,255,255'};
color    g_blue_colors[10] = {C'40,40,255',C'60,60,255',C'80,80,255',C'100,100,255',C'120,120,255',C'140,140,255',C'160,160,255',C'190,190,255',C'220,220,255',C'255,255,255'};
double   g_diffs[100];
int      g_indice[4] = {EURUSD, GBPUSD, USDJPY, AUDUSD};
int      g_symbol_indice[20] = {
   EURUSD, GBPUSD, USDJPY, AUDUSD,
   EURUSD, EURGBP, EURJPY, EURAUD,
   EURGBP, GBPUSD, GBPJPY, GBPAUD,
   EURJPY, USDJPY, GBPJPY, AUDJPY,
   EURAUD, AUDUSD, GBPAUD, AUDJPY
};
int g_sign[20] = {
   -1,-1,1,-1,
      1,1,1,1,
      -1,1,1,1,
      -1,-1,-1,-1,
      -1,1,-1,1
   };
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   ResetValues();
   InitSettings();
   DrawTemplate();
   EventSetMillisecondTimer(200);
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
//---

//--- return value of prev_calculated for next call
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Delete objects                                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   DeleteObjects();
}

//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer() {
   UpdateValues();
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitSettings() {
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, clrBlack);
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, clrBlack);
   ChartSetInteger(0, CHART_COLOR_GRID, clrBlack);
   ChartSetInteger(0, CHART_COLOR_VOLUME, clrBlack);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, clrBlack);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, clrBlack);
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, clrBlack);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, clrBlack);
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, clrBlack);
   ChartSetInteger(0, CHART_COLOR_BID, clrBlack);
   ChartSetInteger(0, CHART_COLOR_ASK, clrBlack);
   ChartSetInteger(0, CHART_COLOR_LAST, clrBlack);
   ChartSetInteger(0, CHART_COLOR_STOP_LEVEL, clrBlack);
}
//+------------------------------------------------------------------+
//| Draw Template.                                                   |
//+------------------------------------------------------------------+
void DrawTemplate() {

   int start_x = 60, starty = 40, startny=200;
   int cell_w = 40, cell_h = 20;
   color col_bk_color = C'220,220,220';
   string object_id = "";

   object_id = OBJECT_PREFIX + "RESET_BUTTON";

   CreateButton(object_id, "リセット", clrBlack);
   MoveObjects(object_id, start_x +100, starty- 26, 80, 24);

   object_id = OBJECT_PREFIX + "CURRENCY_LABEL";
   CreateLabel(object_id, "▼主要通貨合計", ANCHOR_LEFT_UPPER, clrWhite);
   MoveObjects(object_id, start_x -10, starty - cell_h, cell_w*2, cell_h);

   object_id = OBJECT_PREFIX + "PAIR_LABEL";
   CreateLabel(object_id, "▼通貨ぺア(USD基軸)", ANCHOR_LEFT_UPPER, clrWhite);
   MoveObjects(object_id, start_x -10, startny - cell_h, cell_w*2, cell_h);

   object_id= OBJECT_PREFIX + "PAIR_SUM";
   CreateRectangleLabel(object_id, BORDER_FLAT, clrGray, col_bk_color);
   MoveObjects(object_id, start_x, starty, cell_w*2, cell_h);
   object_id= OBJECT_PREFIX + "LABEL_PAIR_SUM";
   CreateLabel(object_id, "通貨計", ANCHOR_CENTER, clrBlack);
   MoveObjects(object_id, start_x + cell_w, starty + cell_h/2, cell_w*2, cell_h);

   object_id= OBJECT_PREFIX + "PAIR";
   CreateRectangleLabel(object_id, BORDER_FLAT, clrGray, col_bk_color);
   MoveObjects(object_id, start_x, startny, cell_w*2, cell_h);
   object_id= OBJECT_PREFIX + "LABEL_PAIR";
   CreateLabel(object_id, "通貨ぺア", ANCHOR_CENTER, clrBlack);
   MoveObjects(object_id, start_x + cell_w, startny + cell_h/2, cell_w*2, cell_h);

   string currencies[5] = {"USD", "EUR", "GBP", "JPY", "AUD"};
   for(int i = 0; i<5; i++) {
      object_id= OBJECT_PREFIX + "BUTTON_CUR_SUM_"+ IntegerToString(i);
      CreateButton(object_id, currencies[i] + "計", clrBlack);
      MoveObjects(object_id, start_x, starty + (i+1)*cell_h, cell_w*2, cell_h);
   }

   for(int i = 0; i<4; i++) {
      object_id = OBJECT_PREFIX + "PAIR_ID_" + IntegerToString(i);
      CreateRectangleLabel(object_id, BORDER_FLAT, clrGray, col_bk_color);
      MoveObjects(object_id, start_x, startny + (i+1)*cell_h, cell_w*2, cell_h);
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_" + IntegerToString(i);
      CreateLabel(object_id, "XXXXXX", ANCHOR_CENTER, clrBlack);
      MoveObjects(object_id, start_x + cell_w, startny + (int)((i+1.5)*cell_h), cell_w*2, cell_h);

   }
   for(int i = 0; i<10; i++) {
      object_id = OBJECT_PREFIX + "CURRENCY_COL_" + IntegerToString(i);
      CreateRectangleLabel(object_id, BORDER_FLAT, clrGray, col_bk_color);
      MoveObjects(object_id, start_x + (i+2)*cell_w, starty, cell_w, cell_h);
      object_id = OBJECT_PREFIX + "LABEL_CURRENCY_COL_" + IntegerToString(i);
      CreateLabel(object_id, IntegerToString(i+1), ANCHOR_CENTER, clrBlack);
      MoveObjects(object_id, start_x + (int)((i+2.5)*cell_w), starty+cell_h/2, cell_w, cell_h);

      object_id = OBJECT_PREFIX + "PAIR_COL_" + IntegerToString(i);
      CreateRectangleLabel(object_id, BORDER_FLAT, clrGray, col_bk_color);
      MoveObjects(object_id, start_x + (i+2)*cell_w, startny, cell_w, cell_h);
      object_id = OBJECT_PREFIX + "LABEL_PAIR_COL_" + IntegerToString(i);
      CreateLabel(object_id, IntegerToString(i+1), ANCHOR_CENTER, clrBlack);
      MoveObjects(object_id, start_x + (int)((i+2.5)*cell_w), startny+cell_h/2, cell_w, cell_h);
   }

   for(int i = 0; i < 5; i++) {
      for(int j = 0; j< 10; j++) {
         object_id = OBJECT_PREFIX + "CURRENCY_CELL_" + IntegerToString(i) + "_" + IntegerToString(j);
         CreateRectangleLabel(object_id, BORDER_FLAT, clrGray, clrWhite);
         MoveObjects(object_id, start_x + (j+2)*cell_w, starty + (i + 1)*cell_h, cell_w, cell_h);
         object_id = OBJECT_PREFIX + "LABEL_CURRENCY_CELL_" + IntegerToString(i) + "_" + IntegerToString(j);
         CreateLabel(object_id, "0.00", ANCHOR_CENTER, clrBlack);
         MoveObjects(object_id, start_x + (int)((j+2.5)*cell_w), starty+(int)((i + 1.5)*cell_h), cell_w, cell_h);
      }
   }

   for(int i = 0; i < 4; i++) {
      for(int j = 0; j< 10; j++) {
         object_id = OBJECT_PREFIX + "PAIR_CELL_" + IntegerToString(i) + "_" + IntegerToString(j);
         CreateRectangleLabel(object_id, BORDER_FLAT, clrGray, clrWhite);
         MoveObjects(object_id, start_x + (j+2)*cell_w, startny + (i + 1)*cell_h, cell_w, cell_h);
         object_id = OBJECT_PREFIX + "LABEL_PAIR_CELL_" + IntegerToString(i) + "_" + IntegerToString(j);
         CreateLabel(object_id, "0.00", ANCHOR_CENTER, clrBlack);
         MoveObjects(object_id, start_x + (int)((j+2.5)*cell_w), startny+(int)((i + 1.5)*cell_h), cell_w, cell_h);
      }
   }
   ObjectSetInteger(0, OBJECT_PREFIX + "BUTTON_CUR_SUM_0", OBJPROP_STATE, true);
   ChangeCurrency("USD");
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetValues() {
   for(int i = 0; i < 100; i++) {
      g_diffs[i] = 0;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateValues() {
   double diff[10] = {0,0,0,0,0,0,0,0,0,0};
   for(int i = 0; i < 10; i++) {
      MqlTick tick;
      string symbol = InpPrefix + SYMBOLS[i]+InpSuffix;
      SymbolInfoTick(symbol, tick);
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      if(g_ticks[i].bid != tick.bid) {
         if(g_ticks[i].bid !=0 && g_ticks[i].bid != EMPTY_VALUE) {
            diff[i] = NormalizeDouble((tick.bid-g_ticks[i].bid)/(point*100), 2);
         }
         g_ticks[i] = tick;
      }
   }
   for(int i = 0 ; i < 10; i++) {
      if(diff[i] != 0) {
         for(int j = 9; j > 0; j--) {
            g_diffs[i*10 + j] = g_diffs[i*10 + j - 1];
         }
         g_diffs[i*10] += diff[i];
         if(IsNewBar(i)) {
            string symbol = InpPrefix + SYMBOLS[i]+InpSuffix;
            double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
            g_diffs[i*10] = NormalizeDouble((iOpen(symbol, PERIOD_CURRENT, 0)-iClose(symbol, PERIOD_CURRENT, 1))/(point*100),2);
         }
      }
   }
   UpdateCells();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateCells() {
   string object_id = "";
   for(int i = 0; i < 4; i++) {
      int symbol_index = g_indice[i];
      for(int j = 0; j < 10; j++) {
         object_id = OBJECT_PREFIX + "LABEL_PAIR_CELL_" + IntegerToString(i) + "_" + IntegerToString(j) ;
         double value = g_diffs[symbol_index*10 + j];
         ObjectSetString(0, object_id, OBJPROP_TEXT, DoubleToString(value, 2));
         object_id = OBJECT_PREFIX + "PAIR_CELL_" + IntegerToString(i) + "_" + IntegerToString(j);
         ObjectSetInteger(0, object_id, OBJPROP_BGCOLOR, GetBackColor(value));
      }
   }

   double sum_plus;
   double sum_minus;
   int   count_plus;
   int   count_minus;
   int s_index=0;
   double value =0 ;
   for(int i = 0; i < 5; i++) {
      for(int j = 0; j<10; j++) {
         sum_plus = 0;
         sum_minus = 0;
         count_plus = 0;
         count_minus = 0;
         for(int k = 0 ; k < 4; k++) {
            s_index = g_symbol_indice[i*4+k];
            value = g_diffs[s_index*10+j]*g_sign[i*4+k];
            if(value >= 0) {
               sum_plus += value;
               count_plus++;
            } else if(value < 0) {
               sum_minus += value;
               count_minus++;
            }
         }
         double avg = 0;
         if(count_plus !=0 ) {
            if(sum_plus >= MathAbs(sum_minus)) {
               avg = NormalizeDouble(sum_plus / count_plus, 2);
            } else {
               avg = NormalizeDouble(sum_minus / count_minus, 2);
            }

//            if(avg != 0) {
               object_id = OBJECT_PREFIX + "LABEL_CURRENCY_CELL_" + IntegerToString(i) + "_" + IntegerToString(j);
               ObjectSetString(0, object_id, OBJPROP_TEXT, DoubleToString(avg, 2));
               object_id = OBJECT_PREFIX + "CURRENCY_CELL_" + IntegerToString(i) + "_" + IntegerToString(j);
               ObjectSetInteger(0, object_id, OBJPROP_BGCOLOR, GetBackColor(avg));
//            }
         }
      }
   }


}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color GetBackColor(double value) {
   int index = (int)((MathAbs(value)-0.01)*10);//(int)(MathAbs(value)* 2);
   if(index > 9) index = 9;
   if(value > 0) {
      return g_red_colors[9-index];
   } else if(value < 0) {
      return g_blue_colors[9-index];
   }
   return clrWhite;
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateRectangleLabel(string object_id,  int border_type, color border_color, color back_color) {
   if(ObjectFind(object_id)<0) {
      ObjectCreate(0,object_id, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, object_id, OBJPROP_BGCOLOR, back_color);
      ObjectSetInteger(0, object_id, OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, object_id, OBJPROP_BORDER_COLOR, border_color);
      ObjectSetInteger(0, object_id, OBJPROP_SELECTABLE, false);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string object_id,  string text, int anchor_type, color text_color ) {
   if(ObjectFind(object_id)<0) {
      ObjectCreate(0,object_id, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, object_id, OBJPROP_COLOR, text_color);
      ObjectSetInteger(0, object_id, OBJPROP_ANCHOR, anchor_type);
      ObjectSetInteger(0, object_id, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, object_id, OBJPROP_FONT, "MeiryoKe_Gothic");
      ObjectSetString(0, object_id, OBJPROP_TEXT, text);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateButton(string object_id,  string text, color text_color ) {
   if(ObjectFind(object_id)<0) {
      ObjectCreate(0,object_id, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, object_id, OBJPROP_COLOR, text_color);
      ObjectSetInteger(0, object_id, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, object_id, OBJPROP_FONT, "MeiryoKe_Gothic");
      ObjectSetString(0, object_id, OBJPROP_TEXT, text);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MoveObjects(string object_id, int x, int y, int w, int h) {
   ObjectSetInteger(0, object_id, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(0, object_id, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(0, object_id, OBJPROP_XSIZE, w);
   ObjectSetInteger(0, object_id, OBJPROP_YSIZE, h);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjects() {
   int k = 0;

   while (k<ObjectsTotal())   {
      string objname = ObjectName(k);
      if (StringSubstr(objname,0,StringLen(OBJECT_PREFIX)) == OBJECT_PREFIX)
         ObjectDelete(objname);
      else
         k++;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeCurrency(string currency) {
   string object_id = "";
   if(currency == "EUR") {
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_0";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "EURUSD");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_1";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "EURGBP");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_2";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "EURJPY");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_3";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "EURAUD");
      g_indice[0] = EURUSD;
      g_indice[1] = EURGBP;
      g_indice[2] = EURJPY;
      g_indice[3] = EURAUD;
   } else if(currency == "USD") {
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_0";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "EURUSD");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_1";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "GBPUSD");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_2";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "USDJPY");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_3";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "AUDUSD");
      g_indice[0] = EURUSD;
      g_indice[1] = GBPUSD;
      g_indice[2] = USDJPY;
      g_indice[3] = AUDUSD;
   } else if(currency == "GBP") {
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_0";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "EURGBP");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_1";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "GBPUSD");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_2";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "GBPJPY");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_3";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "GBPAUD");
      g_indice[0] = EURGBP;
      g_indice[1] = GBPUSD;
      g_indice[2] = GBPJPY;
      g_indice[3] = GBPAUD;
   } else if(currency == "JPY") {
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_0";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "EURJPY");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_1";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "USDJPY");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_2";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "GBPJPY");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_3";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "AUDJPY");
      g_indice[0] = EURJPY;
      g_indice[1] = USDJPY;
      g_indice[2] = GBPJPY;
      g_indice[3] = AUDJPY;
   } else if(currency == "AUD") {
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_0";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "EURAUD");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_1";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "AUDUSD");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_2";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "GBPAUD");
      object_id = OBJECT_PREFIX + "LABEL_PAIR_ID_3";
      ObjectSetString(0, object_id, OBJPROP_TEXT, "AUDJPY");
      g_indice[0] = EURAUD;
      g_indice[1] = AUDUSD;
      g_indice[2] = GBPAUD;
      g_indice[3] = AUDJPY;
   }
}
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
//---
   if(id==CHARTEVENT_OBJECT_CLICK) {
      if(StringFind(sparam, "BUTTON_CUR_SUM_") >=0) {
         string currency = StringSubstr(ObjectGetString(0, sparam, OBJPROP_TEXT), 0, 3);
         for(int i = 0; i < 5; i++) {
            ObjectSetInteger(0, OBJECT_PREFIX + "BUTTON_CUR_SUM_"+ IntegerToString(i),
                             OBJPROP_STATE, false);
         }
         ObjectSetInteger(0, sparam, OBJPROP_STATE, true);
         ObjectSetString(0, OBJECT_PREFIX + "PAIR_LABEL", OBJPROP_TEXT, "▼通貨ぺア(" + currency +"基軸)");
         ChangeCurrency(currency);
      } else if(sparam == OBJECT_PREFIX + "RESET_BUTTON") {
         ResetValues();
         ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      }
   }
   if(id==CHARTEVENT_KEYDOWN) {
      Print("Key Pressed");
   }

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar(int index) {
//--- memorize the time of opening of the last bar in the static variable

//--- current time
   datetime last_bar_time=(int)SeriesInfoInteger(SYMBOLS[index],PERIOD_CURRENT,SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(g_last_time[index]==0) {
      //--- set the time and exit
      g_last_time[index]=last_bar_time;
      return false;
   }

//--- if the time differs
   if(g_last_time[index]!=last_bar_time) {
      //--- memorize the time and return true
      g_last_time[index]=last_bar_time;
      return true;
   }
//--- if we passed to this line, then the bar is not new; return false
   return false;
}

//+------------------------------------------------------------------+
