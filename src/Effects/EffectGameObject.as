package Effects
{
   import Brain.Utils.IPoolable;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import Floor.FloorView;
   import flash.geom.Vector3D;
   
   public class EffectGameObject extends FloorObject implements IPoolable
   {
      
      protected var mEffectView:EffectView;
      
      public var swfPath:String;
      
      public var className:String;
      
      public var iconInsert:EffectIconInsert;
      
      public var fallbackCategory:String;
      
      protected var mAssetLoadedCallback:Function;
      
      public function EffectGameObject(facade:DBFacade, swfPath:String, className:String, playRate:Number, remoteId:uint = 0, assetLoadedCallback:Function = null, iconInsert:EffectIconInsert = null, fallbackCategory:String = null)
      {
         this.swfPath = swfPath;
         this.className = className;
         this.iconInsert = iconInsert;
         this.fallbackCategory = fallbackCategory;
         mAssetLoadedCallback = assetLoadedCallback;
         super(facade,remoteId);
         this.layer = 20;
         this.init();
         mEffectView.setPlayRate(playRate);
      }
      
      public function setAssetLoadedCallback(callback:Function) : void
      {
         mAssetLoadedCallback = callback;
      }
      
      public function setIconInsert(iconInsert:EffectIconInsert) : void
      {
         this.iconInsert = iconInsert;
         if(mEffectView != null)
         {
            mEffectView.setIconInsert(iconInsert);
         }
      }
      
      public function postCheckout(isNewObject:Boolean) : void
      {
         if(!isNewObject && mAssetLoadedCallback != null && view.movieClipRenderer != null)
         {
            view.movieClipRenderer.clip.gotoAndStop(0);
            mAssetLoadedCallback(view.movieClipRenderer.clip);
         }
      }
      
      public function postCheckin() : void
      {
         mAssetLoadedCallback = null;
         setIconInsert(null);
         mEffectView.stop();
      }
      
      public function getPoolKey() : String
      {
         return swfPath + ":" + className;
      }
      
      override public function set position(pos:Vector3D) : void
      {
         super.position = pos;
         mEffectView.snapPosition(pos);
      }
      
      override protected function buildView() : void
      {
         mEffectView = new EffectView(mDBFacade,this,mAssetLoadedCallback);
         MemoryTracker.track(mEffectView,"EffectView \'" + swfPath + ":" + className + "\' - created in EffectGameObject.buildView()","pool");
         this.view = mEffectView as FloorView;
      }
      
      public function get rotation() : Number
      {
         return mFloorView.rotation;
      }
      
      public function set rotation(rot:Number) : void
      {
         this.view.rotation = rot;
      }
      
      override public function destroy() : void
      {
         mAssetLoadedCallback = null;
         mEffectView = null;
         super.destroy();
      }
   }
}

