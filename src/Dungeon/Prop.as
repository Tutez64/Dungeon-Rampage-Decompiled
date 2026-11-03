package Dungeon
{
   import Brain.SceneGraph.SceneGraphManager;
   import Brain.Utils.MemoryTracker;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import GameMasterDictionary.GMProp;
   import Starling.StarlingView;
   import Starling.StarlingViewFactory;
   import flash.display.MovieClip;
   import flash.geom.Vector3D;
   import starling.extensions.animate.Animation;
   import starling.textures.Texture;
   
   public class Prop extends FloorObject
   {
      
      protected var mPropView:PropView;
      
      private var mAssetClassName:String;
      
      private var mConstant:String;
      
      private var mDisposed:Boolean = false;
      
      public function Prop(dbFacade:DBFacade, remoteId:uint = 0)
      {
         super(dbFacade,remoteId);
         this.init();
      }
      
      public static function validatePropConstant(propJsonObj:Object, dbFacade:DBFacade) : Boolean
      {
         if(propJsonObj.constant == null)
         {
            return false;
         }
         var _loc3_:GMProp = dbFacade.gameMaster.propByConstant.itemFor(propJsonObj.constant);
         return _loc3_ != null;
      }
      
      public static function parseFromTileJson(propJsonObj:Object, tile:Tile, dbFacade:DBFacade) : Prop
      {
         var _loc6_:Number = tile.position.x + (propJsonObj.x ?? 0);
         var _loc7_:Number = tile.position.y + (propJsonObj.y ?? 0);
         var _loc8_:Vector3D = new Vector3D(_loc6_,_loc7_);
         var _loc5_:Prop = new Prop(dbFacade);
         _loc5_.tile = tile;
         tile.addOwnedFloorObject(_loc5_);
         _loc5_.constant = propJsonObj.constant;
         var _loc4_:GMProp = dbFacade.gameMaster.propByConstant.itemFor(_loc5_.constant);
         _loc5_.assetClassName = _loc4_.AssetClassName;
         _loc5_.position = _loc8_;
         _loc5_.mArchwayAlpha = _loc4_.ArchwayAlpha;
         if(propJsonObj.scale)
         {
            _loc5_.view.root.scaleX = _loc5_.view.root.scaleY = propJsonObj.scale;
         }
         if(propJsonObj.flip)
         {
            _loc5_.view.root.scaleX = -_loc5_.view.root.scaleX;
         }
         if(propJsonObj.rotation)
         {
            _loc5_.view.root.rotation = propJsonObj.rotation;
         }
         var _loc9_:String = propJsonObj.layer ?? "sorted";
         _loc5_.layer = SceneGraphManager.getLayerFromName(_loc9_);
         return _loc5_;
      }
      
      override public function set position(pos:Vector3D) : void
      {
         super.position = pos;
         this.mPropView.position = mPosition;
      }
      
      public function set constant(value:String) : void
      {
         mConstant = value;
      }
      
      public function get constant() : String
      {
         return mConstant;
      }
      
      public function set assetClassName(value:String) : void
      {
         mAssetClassName = value;
      }
      
      override public function set distributedDungeonFloor(value:DistributedDungeonFloor) : void
      {
         super.distributedDungeonFloor = value;
         this.distributedDungeonFloor.dungeonFloorFactory.tileFactory.propFactory.createProp(this.constant,assetLoaded,textureLoaded,animationLoaded);
      }
      
      override protected function updateTile() : void
      {
      }
      
      protected function textureLoaded(propTexture:Texture) : void
      {
         if(!checkValidCallback() || mDistributedDungeonFloor == null)
         {
            return;
         }
         var _loc2_:StarlingViewFactory = mDistributedDungeonFloor.dungeonFloorFactory.tileFactory.starlingViewFactory;
         var _loc4_:Number = this.view.root.rotation * 3.141592653589793 / 180;
         var _loc3_:String = this.layer == 5 ? "normal" : null;
         var _loc5_:StarlingView = _loc2_.onTextureAssetLoaded(propTexture,this.constant,mPosition.x,mPosition.y,this.view.root.scaleX,this.view.root.scaleY,_loc4_,mTile.isOnStage,this.layer,_loc3_);
         if(_loc5_ != null)
         {
            mPropView.starlingView = _loc5_;
            mTile.expandBoundsRect(_loc5_.getBounds(_loc5_.parent));
         }
         this.createNavCollisions(this.constant);
      }
      
      protected function animationLoaded(propAnimation:Animation) : void
      {
         if(!checkValidCallback() || mDistributedDungeonFloor == null)
         {
            return;
         }
         var _loc2_:StarlingViewFactory = mDistributedDungeonFloor.dungeonFloorFactory.tileFactory.starlingViewFactory;
         var _loc4_:Number = this.view.root.rotation * 3.141592653589793 / 180;
         var _loc3_:String = this.layer == 5 ? "normal" : null;
         var _loc5_:StarlingView = _loc2_.onAnimationLoaded(propAnimation,this.constant,mPosition.x,mPosition.y,this.view.root.scaleX,this.view.root.scaleY,_loc4_,mTile.isOnStage,this.layer,_loc3_);
         if(_loc5_ != null)
         {
            mPropView.starlingView = _loc5_;
            mTile.expandBoundsRect(_loc5_.getBounds(_loc5_.parent));
         }
         this.createNavCollisions(this.constant);
      }
      
      protected function assetLoaded(propMovieClip:MovieClip) : void
      {
         if(!checkValidCallback())
         {
            return;
         }
         mPropView.body = propMovieClip;
         mPropView.root.name = "PropView_" + this.constant + "_" + this.id;
         if(propMovieClip.totalFrames == 1 && !mDBFacade.featureFlags.getFlagValue("want-zoom"))
         {
            mPropView.root.cacheAsBitmap = true;
         }
         if(!mTile.isOnStage)
         {
            this.view.addToStage();
         }
         mTile.expandBounds(this);
         if(!mTile.isOnStage)
         {
            this.view.removeFromStage();
         }
         this.createNavCollisions(this.constant);
      }
      
      private function checkValidCallback() : Boolean
      {
         if(mDisposed || mPropView == null)
         {
            return false;
         }
         return true;
      }
      
      override protected function buildView() : void
      {
         mPropView = new PropView(mDBFacade,this);
         MemoryTracker.track(mPropView,"PropView - created in Prop.buildView()");
         view = mPropView;
      }
      
      override public function destroy() : void
      {
         mDisposed = true;
         mPropView = null;
         super.destroy();
      }
   }
}

