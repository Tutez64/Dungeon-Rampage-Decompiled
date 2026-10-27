package UI
{
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class UIReconnectingIndicator
   {
      
      private static const DRAW_LAYER:Number = 1003;
      
      private static const TOP_OFFSET:Number = 40;
      
      private var mDBFacade:DBFacade;
      
      private var mField:TextField;
      
      public function UIReconnectingIndicator(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
      }
      
      public function show() : void
      {
         if(mField != null || mDBFacade == null)
         {
            return;
         }
         var _loc1_:TextField = new TextField();
         _loc1_.selectable = false;
         _loc1_.mouseEnabled = false;
         _loc1_.autoSize = "left";
         var _loc2_:TextFormat = new TextFormat();
         _loc2_.bold = true;
         _loc2_.font = "Verdana";
         _loc2_.color = 16767370;
         _loc2_.size = 22;
         _loc1_.defaultTextFormat = _loc2_;
         _loc1_.text = Locale.getString("RECONNECTING");
         _loc1_.background = true;
         _loc1_.backgroundColor = 0;
         _loc1_.cacheAsBitmap = true;
         _loc1_.name = "ReconnectingIndicator";
         _loc1_.y = 40;
         mField = _loc1_;
         centre();
         mDBFacade.addRootDisplayObject(_loc1_,1003);
      }
      
      public function update(attempt:int, elapsedMilliseconds:int, graceMilliseconds:int) : void
      {
         if(mField == null)
         {
            return;
         }
         mField.text = Locale.getString("RECONNECTING_DETAIL").replace("#ATTEMPT",attempt).replace("#ELAPSED",int(elapsedMilliseconds / 1000)).replace("#GRACE",int(graceMilliseconds / 1000));
         centre();
      }
      
      public function destroy() : void
      {
         var _loc1_:TextField = null;
         if(mField != null)
         {
            _loc1_ = mField;
            mField = null;
            try
            {
               mDBFacade.removeRootDisplayObject(_loc1_);
            }
            catch(error:Error)
            {
               Logger.warn("The reconnecting indicator was already gone: " + error.message);
            }
         }
         mDBFacade = null;
      }
      
      private function centre() : void
      {
         mField.x = Math.max(0,(mDBFacade.viewWidth - mField.width) * 0.5);
      }
   }
}

