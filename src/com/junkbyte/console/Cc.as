package com.junkbyte.console
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.geom.Rectangle;
   
   public class Cc
   {
      
      public static var _console:Console;
      
      public static var _config:ConsoleConfig;
      
      public function Cc()
      {
      }
      
      public static function get config() : ConsoleConfig
      {
         return Cc.get_config();
      }
      
      public static function get_config() : ConsoleConfig
      {
         if(Cc._config == null)
         {
            Cc._config = new ConsoleConfig();
         }
         return Cc._config;
      }
      
      public static function start(container:DisplayObjectContainer, password:String = undefined) : void
      {
         if(password == null)
         {
            password = "";
         }
         if(Cc._console != null)
         {
            if(container != null && Cc._console.parent == null)
            {
               container.addChild(Cc._console);
            }
         }
         else
         {
            Cc._console = new Console(password,Cc.get_config());
            if(container != null)
            {
               container.addChild(Cc._console);
            }
         }
      }
      
      public static function startOnStage(display:DisplayObject = undefined, password:String = undefined) : void
      {
         if(password == null)
         {
            password = "";
         }
         if(Cc._console != null)
         {
            if(display != null && display.stage != null && Cc._console.parent != display.stage)
            {
               display.stage.addChild(Cc._console);
            }
         }
         else if(display != null && display.stage != null)
         {
            Cc.start(display.stage,password);
         }
         else
         {
            Cc._console = new Console(password,Cc.get_config());
            if(display != null)
            {
               display.addEventListener(Event.ADDED_TO_STAGE,Cc.addedToStageHandle);
            }
         }
      }
      
      public static function addedToStageHandle(e:Event) : void
      {
         var _loc2_:DisplayObject = DisplayObject(e.currentTarget);
         _loc2_.removeEventListener(Event.ADDED_TO_STAGE,Cc.addedToStageHandle);
         if(Cc._console != null && Cc._console.parent == null)
         {
            _loc2_.stage.addChild(Cc._console);
         }
      }
      
      public static function add(string:*, priority:int = 2, isRepeating:Boolean = false) : void
      {
         if(Cc._console != null)
         {
            Cc._console.add(string,priority,isRepeating);
         }
      }
      
      public static function ch(channel:*, string:*, priority:int = 2, isRepeating:Boolean = false) : void
      {
         if(Cc._console != null)
         {
            Cc._console.ch(channel,string,priority,isRepeating);
         }
      }
      
      public static function log(... rest) : void
      {
         if(Cc._console != null)
         {
            if(int(rest.length) == 0)
            {
               Cc._console.log();
            }
            else if(int(rest.length) == 1)
            {
               Cc._console.log(rest[0]);
            }
            else if(int(rest.length) == 2)
            {
               Cc._console.log(rest[0],rest[1]);
            }
            else if(int(rest.length) == 3)
            {
               Cc._console.log(rest[0],rest[1],rest[2]);
            }
            else if(int(rest.length) == 4)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3]);
            }
            else if(int(rest.length) == 5)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4]);
            }
            else if(int(rest.length) == 6)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
            }
            else if(int(rest.length) == 7)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
            }
            else if(int(rest.length) == 8)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
            }
            else if(int(rest.length) == 9)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
            }
            else if(int(rest.length) == 10)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
            }
            else if(int(rest.length) == 11)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
            }
            else if(int(rest.length) == 12)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
            }
            else if(int(rest.length) == 13)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
            }
            else if(int(rest.length) == 14)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
            }
            else if(int(rest.length) == 15)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
            }
            else if(int(rest.length) == 16)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
            }
            else if(int(rest.length) == 17)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
            }
            else if(int(rest.length) == 18)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
            }
            else if(int(rest.length) == 19)
            {
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
            }
            else
            {
               if(int(rest.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               Cc._console.log(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
            }
         }
      }
      
      public static function info(... rest) : void
      {
         if(Cc._console != null)
         {
            if(int(rest.length) == 0)
            {
               Cc._console.info();
            }
            else if(int(rest.length) == 1)
            {
               Cc._console.info(rest[0]);
            }
            else if(int(rest.length) == 2)
            {
               Cc._console.info(rest[0],rest[1]);
            }
            else if(int(rest.length) == 3)
            {
               Cc._console.info(rest[0],rest[1],rest[2]);
            }
            else if(int(rest.length) == 4)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3]);
            }
            else if(int(rest.length) == 5)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4]);
            }
            else if(int(rest.length) == 6)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
            }
            else if(int(rest.length) == 7)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
            }
            else if(int(rest.length) == 8)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
            }
            else if(int(rest.length) == 9)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
            }
            else if(int(rest.length) == 10)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
            }
            else if(int(rest.length) == 11)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
            }
            else if(int(rest.length) == 12)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
            }
            else if(int(rest.length) == 13)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
            }
            else if(int(rest.length) == 14)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
            }
            else if(int(rest.length) == 15)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
            }
            else if(int(rest.length) == 16)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
            }
            else if(int(rest.length) == 17)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
            }
            else if(int(rest.length) == 18)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
            }
            else if(int(rest.length) == 19)
            {
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
            }
            else
            {
               if(int(rest.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               Cc._console.info(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
            }
         }
      }
      
      public static function debug(... rest) : void
      {
         if(Cc._console != null)
         {
            if(int(rest.length) == 0)
            {
               Cc._console.debug();
            }
            else if(int(rest.length) == 1)
            {
               Cc._console.debug(rest[0]);
            }
            else if(int(rest.length) == 2)
            {
               Cc._console.debug(rest[0],rest[1]);
            }
            else if(int(rest.length) == 3)
            {
               Cc._console.debug(rest[0],rest[1],rest[2]);
            }
            else if(int(rest.length) == 4)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3]);
            }
            else if(int(rest.length) == 5)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4]);
            }
            else if(int(rest.length) == 6)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
            }
            else if(int(rest.length) == 7)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
            }
            else if(int(rest.length) == 8)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
            }
            else if(int(rest.length) == 9)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
            }
            else if(int(rest.length) == 10)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
            }
            else if(int(rest.length) == 11)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
            }
            else if(int(rest.length) == 12)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
            }
            else if(int(rest.length) == 13)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
            }
            else if(int(rest.length) == 14)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
            }
            else if(int(rest.length) == 15)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
            }
            else if(int(rest.length) == 16)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
            }
            else if(int(rest.length) == 17)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
            }
            else if(int(rest.length) == 18)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
            }
            else if(int(rest.length) == 19)
            {
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
            }
            else
            {
               if(int(rest.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               Cc._console.debug(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
            }
         }
      }
      
      public static function warn(... rest) : void
      {
         if(Cc._console != null)
         {
            if(int(rest.length) == 0)
            {
               Cc._console.warn();
            }
            else if(int(rest.length) == 1)
            {
               Cc._console.warn(rest[0]);
            }
            else if(int(rest.length) == 2)
            {
               Cc._console.warn(rest[0],rest[1]);
            }
            else if(int(rest.length) == 3)
            {
               Cc._console.warn(rest[0],rest[1],rest[2]);
            }
            else if(int(rest.length) == 4)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3]);
            }
            else if(int(rest.length) == 5)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4]);
            }
            else if(int(rest.length) == 6)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
            }
            else if(int(rest.length) == 7)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
            }
            else if(int(rest.length) == 8)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
            }
            else if(int(rest.length) == 9)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
            }
            else if(int(rest.length) == 10)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
            }
            else if(int(rest.length) == 11)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
            }
            else if(int(rest.length) == 12)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
            }
            else if(int(rest.length) == 13)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
            }
            else if(int(rest.length) == 14)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
            }
            else if(int(rest.length) == 15)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
            }
            else if(int(rest.length) == 16)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
            }
            else if(int(rest.length) == 17)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
            }
            else if(int(rest.length) == 18)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
            }
            else if(int(rest.length) == 19)
            {
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
            }
            else
            {
               if(int(rest.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               Cc._console.warn(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
            }
         }
      }
      
      public static function error(... rest) : void
      {
         if(Cc._console != null)
         {
            if(int(rest.length) == 0)
            {
               Cc._console.error();
            }
            else if(int(rest.length) == 1)
            {
               Cc._console.error(rest[0]);
            }
            else if(int(rest.length) == 2)
            {
               Cc._console.error(rest[0],rest[1]);
            }
            else if(int(rest.length) == 3)
            {
               Cc._console.error(rest[0],rest[1],rest[2]);
            }
            else if(int(rest.length) == 4)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3]);
            }
            else if(int(rest.length) == 5)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4]);
            }
            else if(int(rest.length) == 6)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
            }
            else if(int(rest.length) == 7)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
            }
            else if(int(rest.length) == 8)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
            }
            else if(int(rest.length) == 9)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
            }
            else if(int(rest.length) == 10)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
            }
            else if(int(rest.length) == 11)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
            }
            else if(int(rest.length) == 12)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
            }
            else if(int(rest.length) == 13)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
            }
            else if(int(rest.length) == 14)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
            }
            else if(int(rest.length) == 15)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
            }
            else if(int(rest.length) == 16)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
            }
            else if(int(rest.length) == 17)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
            }
            else if(int(rest.length) == 18)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
            }
            else if(int(rest.length) == 19)
            {
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
            }
            else
            {
               if(int(rest.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               Cc._console.error(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
            }
         }
      }
      
      public static function fatal(... rest) : void
      {
         if(Cc._console != null)
         {
            if(int(rest.length) == 0)
            {
               Cc._console.fatal();
            }
            else if(int(rest.length) == 1)
            {
               Cc._console.fatal(rest[0]);
            }
            else if(int(rest.length) == 2)
            {
               Cc._console.fatal(rest[0],rest[1]);
            }
            else if(int(rest.length) == 3)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2]);
            }
            else if(int(rest.length) == 4)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3]);
            }
            else if(int(rest.length) == 5)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4]);
            }
            else if(int(rest.length) == 6)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
            }
            else if(int(rest.length) == 7)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
            }
            else if(int(rest.length) == 8)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
            }
            else if(int(rest.length) == 9)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
            }
            else if(int(rest.length) == 10)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
            }
            else if(int(rest.length) == 11)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
            }
            else if(int(rest.length) == 12)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
            }
            else if(int(rest.length) == 13)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
            }
            else if(int(rest.length) == 14)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
            }
            else if(int(rest.length) == 15)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
            }
            else if(int(rest.length) == 16)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
            }
            else if(int(rest.length) == 17)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
            }
            else if(int(rest.length) == 18)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
            }
            else if(int(rest.length) == 19)
            {
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
            }
            else
            {
               if(int(rest.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               Cc._console.fatal(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
            }
         }
      }
      
      public static function logch(channel:*, ... rest) : void
      {
         if(Cc._console != null)
         {
            Cc._console.addCh(channel,rest.copy(),1);
         }
      }
      
      public static function infoch(channel:*, ... rest) : void
      {
         if(Cc._console != null)
         {
            Cc._console.addCh(channel,rest.copy(),3);
         }
      }
      
      public static function debugch(channel:*, ... rest) : void
      {
         if(Cc._console != null)
         {
            Cc._console.addCh(channel,rest.copy(),6);
         }
      }
      
      public static function warnch(channel:*, ... rest) : void
      {
         if(Cc._console != null)
         {
            Cc._console.addCh(channel,rest.copy(),8);
         }
      }
      
      public static function errorch(channel:*, ... rest) : void
      {
         if(Cc._console != null)
         {
            Cc._console.addCh(channel,rest.copy(),9);
         }
      }
      
      public static function fatalch(channel:*, ... rest) : void
      {
         if(Cc._console != null)
         {
            Cc._console.addCh(channel,rest.copy(),10);
         }
      }
      
      public static function stack(string:*, depth:int = -1, priority:int = 5) : void
      {
         if(Cc._console != null)
         {
            Cc._console.stack(string,depth,priority);
         }
      }
      
      public static function stackch(channel:*, string:*, depth:int = -1, priority:int = 5) : void
      {
         if(Cc._console != null)
         {
            Cc._console.stackch(channel,string,depth,priority);
         }
      }
      
      public static function inspect(obj:*, showInherit:Boolean = true) : void
      {
         if(Cc._console != null)
         {
            Cc._console.inspect(obj,showInherit);
         }
      }
      
      public static function inspectch(channel:*, obj:*, showInherit:Boolean = true) : void
      {
         if(Cc._console != null)
         {
            Cc._console.inspectch(channel,obj,showInherit);
         }
      }
      
      public static function explode(obj:*, depth:int = 3) : void
      {
         if(Cc._console != null)
         {
            Cc._console.explode(obj,depth);
         }
      }
      
      public static function explodech(channel:*, obj:*, depth:int = 3) : void
      {
         if(Cc._console != null)
         {
            Cc._console.explodech(channel,obj,depth);
         }
      }
      
      public static function addHTML(... rest) : void
      {
         if(Cc._console != null)
         {
            if(int(rest.length) == 0)
            {
               Cc._console.addHTML();
            }
            else if(int(rest.length) == 1)
            {
               Cc._console.addHTML(rest[0]);
            }
            else if(int(rest.length) == 2)
            {
               Cc._console.addHTML(rest[0],rest[1]);
            }
            else if(int(rest.length) == 3)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2]);
            }
            else if(int(rest.length) == 4)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3]);
            }
            else if(int(rest.length) == 5)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4]);
            }
            else if(int(rest.length) == 6)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
            }
            else if(int(rest.length) == 7)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
            }
            else if(int(rest.length) == 8)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
            }
            else if(int(rest.length) == 9)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
            }
            else if(int(rest.length) == 10)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
            }
            else if(int(rest.length) == 11)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
            }
            else if(int(rest.length) == 12)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
            }
            else if(int(rest.length) == 13)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
            }
            else if(int(rest.length) == 14)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
            }
            else if(int(rest.length) == 15)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
            }
            else if(int(rest.length) == 16)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
            }
            else if(int(rest.length) == 17)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
            }
            else if(int(rest.length) == 18)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
            }
            else if(int(rest.length) == 19)
            {
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
            }
            else
            {
               if(int(rest.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               Cc._console.addHTML(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
            }
         }
      }
      
      public static function addHTMLch(channel:*, priority:int, ... rest) : void
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc7_:* = null as Array;
         if(Cc._console != null)
         {
            _loc5_ = Cc._console;
            _loc6_ = Cc._console.addHTMLch;
            _loc7_ = [channel,priority].concat(rest.copy());
            _loc6_.apply(_loc5_,_loc7_);
         }
      }
      
      public static function map(container:DisplayObjectContainer, maxDepth:uint = 0) : void
      {
         if(Cc._console != null)
         {
            Cc._console.map(container,maxDepth);
         }
      }
      
      public static function mapch(channel:*, container:DisplayObjectContainer, maxDepth:uint = 0) : void
      {
         if(Cc._console != null)
         {
            Cc._console.mapch(channel,container,maxDepth);
         }
      }
      
      public static function clear(channel:String = undefined) : void
      {
         if(Cc._console != null)
         {
            Cc._console.clear(channel);
         }
      }
      
      public static function bindKey(key:KeyBind, callback:* = undefined, args:Array = undefined) : void
      {
         if(Cc._console != null)
         {
            Cc._console.bindKey(key,callback,args);
         }
      }
      
      public static function addMenu(key:String, callback:*, args:Array = undefined, rollover:String = undefined) : void
      {
         if(Cc._console != null)
         {
            Cc._console.addMenu(key,callback,args,rollover);
         }
      }
      
      public static function listenUncaughtErrors(loaderinfo:LoaderInfo) : void
      {
         if(Cc._console != null)
         {
            Cc._console.listenUncaughtErrors(loaderinfo);
         }
      }
      
      public static function store(name:String, obj:*, useStrong:Boolean = false) : void
      {
         if(Cc._console != null)
         {
            Cc._console.store(name,obj,useStrong);
         }
      }
      
      public static function addSlashCommand(name:String, callback:*, description:String = undefined, alwaysAvailable:Boolean = true, endOfArgsMarker:String = undefined) : void
      {
         if(description == null)
         {
            description = "";
         }
         if(endOfArgsMarker == null)
         {
            endOfArgsMarker = ";";
         }
         if(Cc._console != null)
         {
            Cc._console.addSlashCommand(name,callback,description,alwaysAvailable,endOfArgsMarker);
         }
      }
      
      public static function watch(obj:*, name:String = undefined) : String
      {
         if(Cc._console != null)
         {
            return Cc._console.watch(obj,name);
         }
         return null;
      }
      
      public static function unwatch(name:String) : void
      {
         if(Cc._console != null)
         {
            Cc._console.unwatch(name);
         }
      }
      
      public static function addGraph(panelName:String, obj:*, property:String, color:int = -1, idKey:String = undefined, rectArea:Rectangle = undefined, inverse:Boolean = false) : void
      {
         if(Cc._console != null)
         {
            Cc._console.addGraph(panelName,obj,property,color,idKey,rectArea,inverse);
         }
      }
      
      public static function fixGraphRange(panelName:String, min:Object = undefined, max:Object = undefined) : void
      {
         if(min == null)
         {
            min = Number(Number.NaN);
         }
         if(max == null)
         {
            max = Number(Number.NaN);
         }
         if(Cc._console != null)
         {
            Cc._console.fixGraphRange(panelName,min,max);
         }
      }
      
      public static function removeGraph(panelName:String, obj:* = undefined, property:String = undefined) : void
      {
         if(Cc._console != null)
         {
            Cc._console.removeGraph(panelName,obj,property);
         }
      }
      
      public static function setViewingChannels(... rest) : void
      {
         if(Cc._console != null)
         {
            if(int(rest.length) == 0)
            {
               Cc._console.setViewingChannels();
            }
            else if(int(rest.length) == 1)
            {
               Cc._console.setViewingChannels(rest[0]);
            }
            else if(int(rest.length) == 2)
            {
               Cc._console.setViewingChannels(rest[0],rest[1]);
            }
            else if(int(rest.length) == 3)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2]);
            }
            else if(int(rest.length) == 4)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3]);
            }
            else if(int(rest.length) == 5)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4]);
            }
            else if(int(rest.length) == 6)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
            }
            else if(int(rest.length) == 7)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
            }
            else if(int(rest.length) == 8)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
            }
            else if(int(rest.length) == 9)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
            }
            else if(int(rest.length) == 10)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
            }
            else if(int(rest.length) == 11)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
            }
            else if(int(rest.length) == 12)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
            }
            else if(int(rest.length) == 13)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
            }
            else if(int(rest.length) == 14)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
            }
            else if(int(rest.length) == 15)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
            }
            else if(int(rest.length) == 16)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
            }
            else if(int(rest.length) == 17)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
            }
            else if(int(rest.length) == 18)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
            }
            else if(int(rest.length) == 19)
            {
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
            }
            else
            {
               if(int(rest.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               Cc._console.setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
            }
         }
      }
      
      public static function setIgnoredChannels(... rest) : void
      {
         if(Cc._console != null)
         {
            if(int(rest.length) == 0)
            {
               Cc._console.setIgnoredChannels();
            }
            else if(int(rest.length) == 1)
            {
               Cc._console.setIgnoredChannels(rest[0]);
            }
            else if(int(rest.length) == 2)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1]);
            }
            else if(int(rest.length) == 3)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2]);
            }
            else if(int(rest.length) == 4)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3]);
            }
            else if(int(rest.length) == 5)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4]);
            }
            else if(int(rest.length) == 6)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
            }
            else if(int(rest.length) == 7)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
            }
            else if(int(rest.length) == 8)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
            }
            else if(int(rest.length) == 9)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
            }
            else if(int(rest.length) == 10)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
            }
            else if(int(rest.length) == 11)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
            }
            else if(int(rest.length) == 12)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
            }
            else if(int(rest.length) == 13)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
            }
            else if(int(rest.length) == 14)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
            }
            else if(int(rest.length) == 15)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
            }
            else if(int(rest.length) == 16)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
            }
            else if(int(rest.length) == 17)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
            }
            else if(int(rest.length) == 18)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
            }
            else if(int(rest.length) == 19)
            {
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
            }
            else
            {
               if(int(rest.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               Cc._console.setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
            }
         }
      }
      
      public static function set minimumPriority(value:uint) : void
      {
         Cc.set_minimumPriority(value);
      }
      
      public static function set_minimumPriority(level:uint) : uint
      {
         if(Cc._console != null)
         {
            Cc._console.set_minimumPriority(level);
         }
         return level;
      }
      
      public static function get width() : Number
      {
         return Cc.get_width();
      }
      
      public static function get_width() : Number
      {
         if(Cc._console != null)
         {
            return Cc._console.get_width();
         }
         return 0;
      }
      
      public static function set width(value:Number) : void
      {
         Cc.set_width(value);
      }
      
      public static function set_width(v:Number) : Number
      {
         if(Cc._console != null)
         {
            Cc._console.set_width(v);
         }
         return v;
      }
      
      public static function get height() : Number
      {
         return Cc.get_height();
      }
      
      public static function get_height() : Number
      {
         if(Cc._console != null)
         {
            return Cc._console.get_height();
         }
         return 0;
      }
      
      public static function set height(value:Number) : void
      {
         Cc.set_height(value);
      }
      
      public static function set_height(v:Number) : Number
      {
         if(Cc._console != null)
         {
            Cc._console.set_height(v);
         }
         return v;
      }
      
      public static function get x() : Number
      {
         return Cc.get_x();
      }
      
      public static function get_x() : Number
      {
         if(Cc._console != null)
         {
            return Cc._console.get_x();
         }
         return 0;
      }
      
      public static function set x(value:Number) : void
      {
         Cc.set_x(value);
      }
      
      public static function set_x(v:Number) : Number
      {
         if(Cc._console != null)
         {
            Cc._console.set_x(v);
         }
         return v;
      }
      
      public static function get y() : Number
      {
         return Cc.get_y();
      }
      
      public static function get_y() : Number
      {
         if(Cc._console != null)
         {
            return Cc._console.get_y();
         }
         return 0;
      }
      
      public static function set y(value:Number) : void
      {
         Cc.set_y(value);
      }
      
      public static function set_y(v:Number) : Number
      {
         if(Cc._console != null)
         {
            Cc._console.set_y(v);
         }
         return v;
      }
      
      public static function get visible() : Boolean
      {
         return Cc.get_visible();
      }
      
      public static function get_visible() : Boolean
      {
         if(Cc._console != null)
         {
            return Cc._console.visible;
         }
         return false;
      }
      
      public static function set visible(value:Boolean) : void
      {
         Cc.set_visible(value);
      }
      
      public static function set_visible(v:Boolean) : Boolean
      {
         if(Cc._console != null)
         {
            Cc._console.set_visible(v);
         }
         return v;
      }
      
      public static function get fpsMonitor() : Boolean
      {
         return Cc.get_fpsMonitor();
      }
      
      public static function get_fpsMonitor() : Boolean
      {
         if(Cc._console != null)
         {
            return Cc._console.get_fpsMonitor();
         }
         return false;
      }
      
      public static function set fpsMonitor(value:Boolean) : void
      {
         Cc.set_fpsMonitor(value);
      }
      
      public static function set_fpsMonitor(v:Boolean) : Boolean
      {
         if(Cc._console != null)
         {
            Cc._console.set_fpsMonitor(v);
         }
         return v;
      }
      
      public static function get memoryMonitor() : Boolean
      {
         return Cc.get_memoryMonitor();
      }
      
      public static function get_memoryMonitor() : Boolean
      {
         if(Cc._console != null)
         {
            return Cc._console.get_memoryMonitor();
         }
         return false;
      }
      
      public static function set memoryMonitor(value:Boolean) : void
      {
         Cc.set_memoryMonitor(value);
      }
      
      public static function set_memoryMonitor(v:Boolean) : Boolean
      {
         if(Cc._console != null)
         {
            Cc._console.set_memoryMonitor(v);
         }
         return v;
      }
      
      public static function get commandLine() : Boolean
      {
         return Cc.get_commandLine();
      }
      
      public static function get_commandLine() : Boolean
      {
         if(Cc._console != null)
         {
            return Cc._console.get_commandLine();
         }
         return false;
      }
      
      public static function set commandLine(value:Boolean) : void
      {
         Cc.set_commandLine(value);
      }
      
      public static function set_commandLine(v:Boolean) : Boolean
      {
         if(Cc._console != null)
         {
            Cc._console.set_commandLine(v);
         }
         return v;
      }
      
      public static function get displayRoller() : Boolean
      {
         return Cc.get_displayRoller();
      }
      
      public static function get_displayRoller() : Boolean
      {
         if(Cc._console != null)
         {
            return Cc._console.get_displayRoller();
         }
         return false;
      }
      
      public static function set displayRoller(value:Boolean) : void
      {
         Cc.set_displayRoller(value);
      }
      
      public static function set_displayRoller(v:Boolean) : Boolean
      {
         if(Cc._console != null)
         {
            Cc._console.set_displayRoller(v);
         }
         return v;
      }
      
      public static function setRollerCaptureKey(character:String, ctrl:Boolean = false, alt:Boolean = false, shift:Boolean = false) : void
      {
         if(Cc._console != null)
         {
            Cc._console.setRollerCaptureKey(character,shift,ctrl,alt);
         }
      }
      
      public static function get remoting() : Boolean
      {
         return Cc.get_remoting();
      }
      
      public static function get_remoting() : Boolean
      {
         if(Cc._console != null)
         {
            return Cc._console.get_remoting();
         }
         return false;
      }
      
      public static function set remoting(value:Boolean) : void
      {
         Cc.set_remoting(value);
      }
      
      public static function set_remoting(v:Boolean) : Boolean
      {
         if(Cc._console != null)
         {
            Cc._console.set_remoting(v);
         }
         return v;
      }
      
      public static function remotingSocket(host:String, port:int) : void
      {
         if(Cc._console != null)
         {
            Cc._console.remotingSocket(host,port);
         }
      }
      
      public static function remove() : void
      {
         if(Cc._console != null)
         {
            if(Cc._console.parent != null)
            {
               Cc._console.parent.removeChild(Cc._console);
            }
            Cc._console = null;
         }
      }
      
      public static function getAllLog(splitter:String = undefined) : String
      {
         if(splitter == null)
         {
            splitter = "\r\n";
         }
         if(Cc._console != null)
         {
            return Cc._console.getAllLog(splitter);
         }
         return "";
      }
      
      public static function get instance() : Console
      {
         return Cc.get_instance();
      }
      
      public static function get_instance() : Console
      {
         return Cc._console;
      }
   }
}

