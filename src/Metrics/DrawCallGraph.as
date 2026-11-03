package Metrics
{
   import Facade.DBFacade;
   import com.junkbyte.console.Cc;
   import starling.core.Starling;
   
   public class DrawCallGraph
   {
      
      private static const MENU_NAME:String = "DC";
      
      private static const PANEL_NAME:String = "Draw calls";
      
      private static const LINE_COLOR:Number = 16756768;
      
      private var mDBFacade:DBFacade;
      
      private var mPeak:int = 0;
      
      public function DrawCallGraph(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         Cc.addMenu("DC",show,null,"Show the draw calls graph (Starling draw calls per frame)");
      }
      
      public function show() : void
      {
         if(currentStarling() == null)
         {
            Cc.log("Draw calls graph: Starling is not ready yet.");
            return;
         }
         mPeak = 0;
         Cc.addGraph("Draw calls",this,"drawCalls",16756768);
      }
      
      public function get drawCalls() : int
      {
         var _loc1_:Starling = currentStarling();
         var _loc2_:int = int(_loc1_ != null && _loc1_.painter != null ? _loc1_.painter.drawCount : 0);
         if(_loc2_ > mPeak)
         {
            mPeak = _loc2_;
         }
         Cc.fixGraphRange("Draw calls",0,mPeak);
         return _loc2_;
      }
      
      private function currentStarling() : Starling
      {
         if(mDBFacade == null || mDBFacade.starlingLayerManager == null)
         {
            return null;
         }
         return mDBFacade.starlingLayerManager.starlingInstance;
      }
   }
}

