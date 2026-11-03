package com.junkbyte.console
{
   import com.junkbyte.console.text.StyleSheet;
   import flash.Boot;
   
   public class ConsoleStyle
   {
      
      public var traceFontSize:int;
      
      public var traceFont:String;
      
      public var topMenu:Boolean;
      
      public var showCommandLineScope:Boolean;
      
      public var roundBorder:int;
      
      public var priorityC2:uint;
      
      public var priorityC1:uint;
      
      public var priority9:uint;
      
      public var priority8:uint;
      
      public var priority7:uint;
      
      public var priority6:uint;
      
      public var priority5:uint;
      
      public var priority4:uint;
      
      public var priority3:uint;
      
      public var priority2:uint;
      
      public var priority10:uint;
      
      public var priority1:uint;
      
      public var priority0:uint;
      
      public var panelSnapping:int;
      
      public var menuHighlightColor:uint;
      
      public var menuFontSize:int;
      
      public var menuFont:String;
      
      public var menuColor:uint;
      
      public var maxChannelsInMenu:int;
      
      public var lowColor:uint;
      
      public var logHeaderColor:uint;
      
      public var highColor:uint;
      
      public var controlSize:uint;
      
      public var controlColor:uint;
      
      public var commandLineColor:uint;
      
      public var channelsColor:uint;
      
      public var channelColor:uint;
      
      public var backgroundColor:uint;
      
      public var backgroundAlpha:Number;
      
      public var _css:StyleSheet;
      
      public function ConsoleStyle()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         roundBorder = 10;
         panelSnapping = 3;
         maxChannelsInMenu = 7;
         showCommandLineScope = true;
         topMenu = true;
         priorityC2 = 16746496;
         priorityC1 = 39372;
         priority10 = 16720418;
         priority9 = 16720418;
         priority8 = 16742263;
         priority7 = 16755370;
         priority6 = 16768477;
         priority5 = 15329769;
         priority4 = 14085846;
         priority3 = 10539168;
         priority2 = 7846775;
         priority1 = 4495684;
         priority0 = 3831610;
         channelColor = 39372;
         channelsColor = 16777215;
         menuHighlightColor = 14505216;
         menuColor = 16746496;
         logHeaderColor = 12632256;
         lowColor = 12632256;
         highColor = 16777215;
         commandLineColor = 1092096;
         controlSize = 5;
         controlColor = 10027008;
         backgroundAlpha = 0.9;
         backgroundColor = 0;
         traceFontSize = 11;
         traceFont = "Verdana";
         menuFontSize = 12;
         menuFont = "Arial";
         _css = new StyleSheet();
      }
      
      public function whiteBase() : void
      {
         backgroundColor = 16777215;
         controlColor = 16724787;
         commandLineColor = 6736896;
         highColor = 0;
         lowColor = 3355443;
         logHeaderColor = 4473924;
         menuColor = 13373696;
         menuHighlightColor = 8917248;
         channelsColor = 0;
         channelColor = 26282;
         priority0 = 4497476;
         priority1 = 3379251;
         priority2 = 2258722;
         priority3 = 1135889;
         priority4 = 13056;
         priority5 = 0;
         priority6 = 6684672;
         priority7 = 10027008;
         priority8 = 12255232;
         priority9 = 14483456;
         priority10 = 14483456;
         priorityC1 = 39372;
         priorityC2 = 16737792;
      }
      
      public function updateStyleSheet() : void
      {
         _css.setStyle("high",{
            "color":hesh(highColor),
            "fontFamily":menuFont,
            "fontSize":menuFontSize,
            "display":"inline"
         });
         _css.setStyle("low",{
            "color":hesh(lowColor),
            "fontFamily":menuFont,
            "fontSize":menuFontSize - 2,
            "display":"inline"
         });
         _css.setStyle("menu",{
            "color":hesh(menuColor),
            "display":"inline"
         });
         _css.setStyle("menuHi",{
            "color":hesh(menuHighlightColor),
            "display":"inline"
         });
         _css.setStyle("chs",{
            "color":hesh(channelsColor),
            "fontSize":menuFontSize,
            "leading":"2",
            "display":"inline"
         });
         _css.setStyle("ch",{
            "color":hesh(channelColor),
            "display":"inline"
         });
         _css.setStyle("tt",{
            "color":hesh(menuColor),
            "fontFamily":menuFont,
            "fontSize":menuFontSize,
            "textAlign":"center"
         });
         _css.setStyle("r",{
            "textAlign":"right",
            "display":"inline"
         });
         _css.setStyle("p",{
            "fontFamily":traceFont,
            "fontSize":traceFontSize
         });
         _css.setStyle("p0",{
            "color":hesh(priority0),
            "display":"inline"
         });
         _css.setStyle("p1",{
            "color":hesh(priority1),
            "display":"inline"
         });
         _css.setStyle("p2",{
            "color":hesh(priority2),
            "display":"inline"
         });
         _css.setStyle("p3",{
            "color":hesh(priority3),
            "display":"inline"
         });
         _css.setStyle("p4",{
            "color":hesh(priority4),
            "display":"inline"
         });
         _css.setStyle("p5",{
            "color":hesh(priority5),
            "display":"inline"
         });
         _css.setStyle("p6",{
            "color":hesh(priority6),
            "display":"inline"
         });
         _css.setStyle("p7",{
            "color":hesh(priority7),
            "display":"inline"
         });
         _css.setStyle("p8",{
            "color":hesh(priority8),
            "display":"inline"
         });
         _css.setStyle("p9",{
            "color":hesh(priority9),
            "display":"inline"
         });
         _css.setStyle("p10",{
            "color":hesh(priority10),
            "fontWeight":"bold",
            "display":"inline"
         });
         _css.setStyle("p-1",{
            "color":hesh(priorityC1),
            "display":"inline"
         });
         _css.setStyle("p-2",{
            "color":hesh(priorityC2),
            "display":"inline"
         });
         _css.setStyle("logs",{
            "color":hesh(logHeaderColor),
            "display":"inline"
         });
      }
      
      public function hesh(n:uint) : String
      {
         return "#" + StringTools.hex(n);
      }
      
      public function get_styleSheet() : StyleSheet
      {
         return _css;
      }
      
      public function get styleSheet() : StyleSheet
      {
         return get_styleSheet();
      }
      
      public function big() : void
      {
         traceFontSize = 13;
         menuFontSize = 14;
      }
   }
}

