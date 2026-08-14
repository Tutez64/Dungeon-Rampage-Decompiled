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
      
      protected var mAssetLoadedCallback:Function;
      
      public function EffectGameObject(facade:DBFacade, swfPath:String, className:String, playRate:Number, remoteId:uint = 0, assetLoadedCallback:Function = null)
      {
         this.swfPath = swfPath;
         this.className = className;
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
      
      public function postCheckout(isNewObject:Boolean) : void
      {
         if(!isNewObject && mAssetLoadedCallback != null)
         {
            view.movieClipRenderer.clip.gotoAndStop(0);
            mAssetLoadedCallback(view.movieClipRenderer.clip);
         }
      }
      
      public function postCheckin() : void
      {
         mEffectView.stop();
      }
      
      public function getPoolKey() : String
      {
         return swfPath + ":" + className;
      }
      
      override public function set position(pos:Vector3D) : void
      {
         super.position = pos;
         mEffectView.position = pos;
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
         mEffectView = null;
         super.destroy();
      }
   }
}

