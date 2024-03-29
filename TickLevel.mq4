//+------------------------------------------------------------------+
//|                                                     RSILevel.mq4 |
//|                                           Copyright 2020,Jupiter |
//|                                          https://www.jupiter.com |
//+------------------------------------------------------------------+
#property copyright "10PipsScalpingAcademy"
#property link      "https://www.jupiter.com"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define OBJECT_PREFIX   "TICK_LEVEL_"

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

input    string   InpPrefix = "";
input    string   InpSuffix = "";

string   SYMBOLS[10] = {"EURUSD", "EURGBP", "EURJPY", "EURAUD", "GBPUSD", "GBPJPY", "GBPAUD","USDJPY","AUDUSD","AUDJPY"};
MqlTick  g_ticks[10];
int      g_diffs[10];
int g_selected_symbol_indice[10] = {GBPUSD, GBPJPY, GBPAUD, EURGBP, AUDUSD, AUDJPY};
int g_selected_index = -1;
color g_back_color = clrBlack;

int g_area_width = 100;


color    g_red_colors[6] = {C'255,255,255',C'255,215,215',C'250,180,180',C'250,120,120',C'250,80,80',C'250,0,0'};
color    g_blue_colors[6] = {C'255,255,255',C'210,250,210',C'180,250,180',C'120,250,120',C'80,250,80',C'0,250,0'};


string g_button_pair[6];
string g_button_options[10];

string g_label_price[6];
string g_label_timeframe[6];
string g_label_tick[6];
string g_label_level_tick[66];
string g_label_left[6];
string g_label_left_time[6];
string g_label_point[6];
string g_label_spear[6];


string g_rect_symbol[6];
string g_rect_level[6];
string g_rect_table[6];
string g_rect_pointer[6];
string g_rect_level_tick[66];

string g_reset_button;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   for(int i = 0; i < 10; i++) {
      g_diffs[i] = 0;
   }
   InitNames();
   DrawTemplate();
   EventSetMillisecondTimer(100);
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
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
//---

   if(id==CHARTEVENT_OBJECT_CLICK) {
      bool is_selected = false;
      for(int i = 0; i < 6; i++) {
         if(sparam == g_button_pair[i]) {
            ObjectSetInteger(0, g_button_pair[i], OBJPROP_STATE, false);
            DisplayOptions(i, true);
            is_selected = true;
         }

      }
      if(!is_selected)
         DisplayOptions(0, false);
      for(int i = 0; i < 10; i++) {
         if(sparam == g_button_options[i]) {
            if(g_selected_index >=0) {
               string button = g_button_pair[g_selected_index];
               ObjectSetString(0, button, OBJPROP_TEXT, SYMBOLS[i]);
               g_selected_symbol_indice[g_selected_index] = i;
            }
         }
      }

      if(sparam == g_reset_button) {
         ResetValues();
         ObjectSetInteger(0, g_reset_button, OBJPROP_STATE, false);
      }
   }

}

//+------------------------------------------------------------------+
//| Custom indicator timer function                                  |
//+------------------------------------------------------------------+
void OnTimer() {
   UpdateValues();
}

//+------------------------------------------------------------------+
//| On DeInit                                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   DeleteObjects();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitNames() {
   for(int i = 0; i < 6; i++) {
      g_button_pair[i] = OBJECT_PREFIX + "BUTTON_PAIR_" + IntegerToString(i);

      g_label_price[i] = OBJECT_PREFIX + "LABEL_PRICE_" + IntegerToString(i);
      g_label_timeframe[i] = OBJECT_PREFIX + "LABEL_TIMEFRAME_" + IntegerToString(i);
      g_label_tick[i] = OBJECT_PREFIX + "LABEL_TICK_" + IntegerToString(i);
      g_label_left[i] = OBJECT_PREFIX + "LABEL_LEFT_" + IntegerToString(i);
      g_label_left_time[i] = OBJECT_PREFIX + "LABEL_LEFT_TIME_" + IntegerToString(i);

      g_rect_symbol[i] = OBJECT_PREFIX + "RECT_SYMBOL_" + IntegerToString(i);
      g_rect_level[i] = OBJECT_PREFIX + "RECT_LEVEL_" + IntegerToString(i);
      g_rect_table[i] = OBJECT_PREFIX + "RECT_TABLE_" + IntegerToString(i);
      for(int j = 0; j < 11; j++) {
         g_label_level_tick[i*11 + j] = OBJECT_PREFIX + "LABEL_LEVEL_TICK_" + IntegerToString(i) + "_" + IntegerToString(j);
         g_rect_level_tick[i*11 + j] = OBJECT_PREFIX + "RECT_LEVEL_TICK_" + IntegerToString(i) + "_" + IntegerToString(j);
      }

      g_rect_pointer[i] = OBJECT_PREFIX + "RECT_POINTER_" + IntegerToString(i);

      g_label_spear[i] = OBJECT_PREFIX + "LABEL_SPEAR_" + IntegerToString(i);
      g_label_point[i] = OBJECT_PREFIX + "LABEL_POINT_" + IntegerToString(i);
   }
   for(int i = 0; i < 10; i++) {
      g_button_options[i] = OBJECT_PREFIX + "BUTTON_OPTIONS_" + IntegerToString(i);
   }
   g_reset_button = OBJECT_PREFIX + "RESET_BUTTON";
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetCurrentTimeFrame() {
   return IntegerToString(PeriodSeconds()/60) + "分足";
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetCurrentBid(string symbol) {
   return DoubleToString(MarketInfo(symbol, MODE_BID), (int)MarketInfo(symbol, MODE_DIGITS));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetCurrentLeftTime(string symbol) {
   datetime bar_time  = iTime(symbol, PERIOD_CURRENT, 0);
   datetime current_time = TimeCurrent();
   int left_seconds = (int)(PeriodSeconds() - (current_time - bar_time));
   if(left_seconds <0)
      return  "  分 秒";
   return IntegerToString(left_seconds/60) + "分 " +IntegerToString(left_seconds%60) + "秒";
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetValues() {
   for(int i = 0; i < 10; i++) {
      g_diffs[i] = 0;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateValues() {
   for(int i = 0; i < 10; i++) {
      MqlTick tick;
      string symbol = InpPrefix + SYMBOLS[i]+InpSuffix;
      SymbolInfoTick(symbol, tick);
      double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      if(g_ticks[i].bid != tick.bid) {
         if(g_ticks[i].bid !=0 && g_ticks[i].bid != EMPTY_VALUE) {
            g_diffs[i] += (int)((tick.bid-g_ticks[i].bid)/point);
         }
         g_ticks[i] = tick;
      }
   }

   int symbol_index;
   for(int i = 0; i < 6; i++) {
      symbol_index = g_selected_symbol_indice[i];
      MovePointer(i, g_diffs[symbol_index]);
      ObjectSetString(0, g_label_left_time[i], OBJPROP_TEXT, GetCurrentLeftTime(SYMBOLS[symbol_index]));
      ObjectSetString(0, g_label_price[i], OBJPROP_TEXT, GetCurrentBid(SYMBOLS[symbol_index]));
      if(g_diffs[symbol_index] >= 0) {
         ObjectSetInteger(0, g_label_price[i], OBJPROP_COLOR, clrRed);
      } else {
         ObjectSetInteger(0, g_label_price[i], OBJPROP_COLOR, clrGreen);
      }
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawTemplate() {

   CreateButton(g_reset_button, "リセット", clrBlack, clrGray);
   MoveObjects(g_reset_button, 20 + 6*g_area_width, 25, 70, 24);

   for(int i = 0; i < 6; i++) {
      CreateRectangleLabel(g_rect_symbol[i], BORDER_FLAT, clrGray, g_back_color);
      MoveObjects(g_rect_symbol[i], 20 + i*g_area_width, 20, 90, 70);
      CreateRectangleLabel(g_rect_level[i], BORDER_FLAT, clrGray, g_back_color);
      MoveObjects(g_rect_level[i], 20 + i*g_area_width, 90, 90, 250);

      CreateButton(g_button_pair[i], SYMBOLS[g_selected_symbol_indice[i]], clrWhite, clrDarkGray);
      MoveObjects(g_button_pair[i], 30 + i*g_area_width, 25, 70, 24);

      CreateLabel(g_label_timeframe[i], GetCurrentTimeFrame(), ANCHOR_CENTER, clrWhite);
      MoveObjects(g_label_timeframe[i], 30 + i*g_area_width + 35, 60, 60, 20);

      CreateLabel(g_label_price[i], GetCurrentBid(SYMBOLS[g_selected_symbol_indice[i]]), ANCHOR_CENTER, clrRed, 11);
      MoveObjects(g_label_price[i], 30 + i*g_area_width + 35, 75, 60, 20);

      CreateRectangleLabel(g_rect_table[i], BORDER_FLAT, clrGray, g_back_color);
      MoveObjects(g_rect_table[i], 43 + i*g_area_width, 98, 34, 179);

      for(int j = 0; j <11; j++) {
         CreateRectangleLabel(g_rect_level_tick[i*11+j], BORDER_FLAT, g_back_color, g_back_color);
         MoveObjects(g_rect_level_tick[i*11+j], 45 + i*g_area_width, 100 + 16*j, 30, 16);
         CreateLabel(g_label_level_tick[i*11+j], IntegerToString(200 - j*40),
                     ANCHOR_RIGHT_UPPER, clrGray,8);
         MoveObjects(g_label_level_tick[i*11+j], 42 + i*g_area_width, 103 + 16*j, 40, 16);
      }

      CreateLabel(g_label_left[i], "残リ", ANCHOR_LEFT, clrWhite, 11);
      MoveObjects(g_label_left[i], 30 + i*g_area_width, 290, 60, 20);

      CreateLabel(g_label_left_time[i], GetCurrentLeftTime(SYMBOLS[g_selected_symbol_indice[i]]), ANCHOR_CENTER, clrWhite, 11);
      MoveObjects(g_label_left_time[i], 30 + i*g_area_width + 35, 310, 60, 20);

      CreateRectangleLabel(g_rect_pointer[i], BORDER_FLAT, clrWhite, clrWhite);
      MoveObjects(g_rect_pointer[i], 88 + i*g_area_width, 180, 20, 16);

      CreateLabel(g_label_spear[i], "▲", ANCHOR_LEFT, clrWhite, 15);
      MoveObjects(g_label_spear[i], 75 + i*g_area_width, 182, 16, 16);
      ObjectSetDouble(0, g_label_spear[i], OBJPROP_ANGLE, -30);

      CreateLabel(g_label_point[i], "-9999", ANCHOR_RIGHT_UPPER, clrBlack, 9);
      MoveObjects(g_label_point[i], 108 + i*g_area_width, 182, 16, 16);
   }

   for(int i = 0; i < 10; i++) {
      CreateButton(g_button_options[i], SYMBOLS[i], clrWhite, clrDarkGray);
      MoveObjects(g_button_options[i], -100, -100, 60, 20);
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayOptions(int index, bool is_show) {
   for(int i = 0; i < 10; i++) {
      if(is_show) {
         MoveObjects(g_button_options[i], 35 + index*g_area_width, 50+i*20, 60, 20);
         ObjectSetInteger(0, g_button_options[i], OBJPROP_STATE, false);
         g_selected_index = index;
      } else
         MoveObjects(g_button_options[i], -100, -100, 60, 20);
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MovePointer(int index, int point) {
   int move_px = 0;
   int move = 0;
   move_px = point;
   move = point;
   if(MathAbs(move) > 200)
      move = point > 0 ? 200 : -200;
   if(MathAbs(move_px) > 220)
      move_px = point > 0 ? 200 : -200;

   ObjectSetString(0, g_label_point[index], OBJPROP_TEXT, IntegerToString(point));

   MoveObjects(g_rect_pointer[index], 88 + index*g_area_width, 180-(int)(((double)move_px/40)*16), 20, 16);
   MoveObjects(g_label_spear[index], 75 + index*g_area_width, 182-(int)(((double)move_px/40)*16), 16, 16);
   MoveObjects(g_label_point[index], 108 + index*g_area_width, 182-(int)(((double)move_px/40)*16), 16, 16);

   for(int i = 0; i < 11; i++) {
      ObjectSetInteger(0, g_rect_level_tick[index*11+i], OBJPROP_COLOR, g_back_color);
      ObjectSetInteger(0, g_rect_level_tick[index*11+i], OBJPROP_BGCOLOR, g_back_color);
   }


   if(point >=0) {
//      int count = (int)MathCeil((double)MathAbs(move)/20);
      int count = MathAbs(move+20)/40;
      for(int i = 0; i<= count; i++) {
         ObjectSetInteger(0, g_rect_level_tick[index*11+5-i], OBJPROP_COLOR, g_red_colors[i]);
         ObjectSetInteger(0, g_rect_level_tick[index*11+5-i], OBJPROP_BGCOLOR, g_red_colors[i]);
      }
      ObjectSetInteger(0, g_rect_pointer[index], OBJPROP_COLOR, g_red_colors[count]);
      ObjectSetInteger(0, g_rect_pointer[index], OBJPROP_BGCOLOR, g_red_colors[count]);
      ObjectSetInteger(0, g_label_spear[index], OBJPROP_COLOR, g_red_colors[count]);
   } else {
//      int count = (int)MathFloor((double)MathAbs(move)/20);
      int count = MathAbs(move-20)/40;
      for(int i = 0; i<= count; i++) {
         ObjectSetInteger(0, g_rect_level_tick[index*11+5+i], OBJPROP_COLOR, g_blue_colors[i]);
         ObjectSetInteger(0, g_rect_level_tick[index*11+5+i], OBJPROP_BGCOLOR, g_blue_colors[i]);
      }
      ObjectSetInteger(0, g_rect_pointer[index], OBJPROP_COLOR, g_blue_colors[count]);
      ObjectSetInteger(0, g_rect_pointer[index], OBJPROP_BGCOLOR, g_blue_colors[count]);
      ObjectSetInteger(0, g_label_spear[index], OBJPROP_COLOR, g_blue_colors[count]);
   }


//   if(point > 80)
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateRectangleLabel(string object_id,  int border_type, color border_color, color back_color) {
   if(ObjectFind(object_id)<0) {
      ObjectCreate(0,object_id, OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, object_id, OBJPROP_BGCOLOR, back_color);
      ObjectSetInteger(0, object_id, OBJPROP_BORDER_TYPE, border_type);
//      ObjectSetInteger(0, object_id, OBJPROP_BORDER_COLOR, border_color);
      ObjectSetInteger(0, object_id, OBJPROP_COLOR, border_color);
      ObjectSetInteger(0, object_id, OBJPROP_SELECTABLE, false);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string object_id,  string text, int anchor_type, color text_color, int font_size=10 ) {
   if(ObjectFind(object_id)<0) {
      ObjectCreate(0,object_id, OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, object_id, OBJPROP_COLOR, text_color);
      ObjectSetInteger(0, object_id, OBJPROP_ANCHOR, anchor_type);
      ObjectSetInteger(0, object_id, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, object_id, OBJPROP_FONT, "MeiryoKe_Gothic");
      ObjectSetString(0, object_id, OBJPROP_TEXT, text);
      ObjectSetInteger(0, object_id, OBJPROP_FONTSIZE, font_size);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateButton(string object_id,  string text, color text_color, color button_color ) {
   if(ObjectFind(object_id)<0) {
      ObjectCreate(0,object_id, OBJ_BUTTON, 0, 0, 0);
      ObjectSetInteger(0, object_id, OBJPROP_COLOR, text_color);
      ObjectSetInteger(0, object_id, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, object_id, OBJPROP_FONT, "MeiryoKe_Gothic");
      ObjectSetString(0, object_id, OBJPROP_TEXT, text);
      ObjectSetInteger(0, object_id, OBJPROP_BGCOLOR, button_color);
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
