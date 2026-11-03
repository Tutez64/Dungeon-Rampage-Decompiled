package Metrics
{
   import Facade.DBFacade;
   import com.junkbyte.console.Cc;
   
   public class GpuMemoryGraph
   {
      
      private static const MENU_NAME:String = "VM";
      
      private static const PANEL_NAME:String = "VRAM";
      
      private static const LINE_COLOR:Number = 1624575;
      
      private static const B_TO_MB:Number = 9.5367431640625e-7;
      
      private var mDBFacade:DBFacade;
      
      private var mPeakMb:Number = 0;
      
      public function GpuMemoryGraph(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         Cc.addMenu("VM",show,null,"Show the VRAM graph (Stage3D texture/buffer memory, MB)");
      }
      
      public function show() : void
      {
         var _loc1_:Object = starlingContext();
         if(_loc1_ == null)
         {
            Cc.log("VRAM graph: the Starling context is not ready yet.");
            return;
         }
         if(!("totalGPUMemory" in _loc1_))
         {
            Cc.log("VRAM graph: this runtime has no Context3D.totalGPUMemory (needs AIR 24 or later).");
            return;
         }
         mPeakMb = 0;
         Cc.addGraph("VRAM",this,"vramMb",1624575);
      }
      
      public function get vramMb() : Number
      {
         var _loc1_:Number = readVramMb();
         if(_loc1_ > mPeakMb)
         {
            mPeakMb = _loc1_;
         }
         Cc.fixGraphRange("VRAM",0,mPeakMb);
         return _loc1_;
      }
      
      private function readVramMb() : Number
      {
         var _loc1_:Object = starlingContext();
         if(_loc1_ == null)
         {
            return 0;
         }
         try
         {
            if("totalGPUMemory" in _loc1_)
            {
               return Math.round(Number(_loc1_["totalGPUMemory"]) * 9.5367431640625e-7 * 10) / 10;
            }
         }
         catch(e:Error)
         {
         }
         return 0;
      }
      
      private function starlingContext() : Object
      {
         if(mDBFacade == null || mDBFacade.starlingLayerManager == null || mDBFacade.starlingLayerManager.starlingInstance == null)
         {
            return null;
         }
         return mDBFacade.starlingLayerManager.starlingInstance.context;
      }
   }
}

