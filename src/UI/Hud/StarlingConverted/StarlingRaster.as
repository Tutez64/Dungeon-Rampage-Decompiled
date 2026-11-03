package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedPicture;
   import Brain.Starling.SwfConverter.FlashBaker;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   
   public class StarlingRaster
   {
      
      public static const MAX_SIDE:int = 1024;
      
      public static const BORDER:int = 1;
      
      public function StarlingRaster()
      {
         super();
      }
      
      internal static function requestedScale(bake:BakedPicture) : Number
      {
         return isNaN(bake.requestedScale) ? bake.pixelScale : bake.requestedScale;
      }
      
      internal static function limit(bake:BakedPicture, requested:Number = NaN) : void
      {
         var _loc5_:Number = NaN;
         var _loc4_:BitmapData = null;
         if(isNaN(requested))
         {
            requested = requestedScale(bake);
         }
         var _loc3_:int = Math.max(bake.bitmap.width,bake.bitmap.height);
         if(_loc3_ > 1024)
         {
            _loc5_ = 1024 / _loc3_;
            _loc4_ = new BitmapData(Math.max(1,Math.floor(bake.bitmap.width * _loc5_)),Math.max(1,Math.floor(bake.bitmap.height * _loc5_)),true,0);
            _loc4_.draw(bake.bitmap,new Matrix(_loc5_,0,0,_loc5_),null,null,null,true);
            bake.bitmap.dispose();
            bake.bitmap = _loc4_;
            bake.originX = Math.round(bake.originX * _loc5_);
            bake.originY = Math.round(bake.originY * _loc5_);
            bake.pixelScale *= _loc5_;
         }
         bake.requestedScale = requested;
      }
      
      public static function bake(source:DisplayObject, pixelScale:Number, hide:Vector.<DisplayObject> = null, ownFilters:Boolean = true) : BakedPicture
      {
         var _loc5_:BakedPicture = null;
         try
         {
            _loc5_ = FlashBaker.bake(source,pixelScale,hide,ownFilters,true,true);
            if(_loc5_ != null)
            {
               limit(_loc5_,pixelScale);
            }
            return _loc5_;
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
         return null;
      }
   }
}

