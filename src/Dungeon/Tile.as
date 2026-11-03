package Dungeon
{
   import Actor.ActorGameObject;
   import Box2D.Dynamics.b2FilterData;
   import Box2D.Dynamics.b2World;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Collections.IIterator;
   import Collections.Set;
   import Collision.LocalHeroProximitySensor;
   import DistributedObjects.DistributedDungeonFloor;
   import DistributedObjects.NPCGameObject;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import Projectile.ChainProjectileGameObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   
   public class Tile extends FloorObject
   {
      
      public static const TILE_WIDTH:uint = 900;
      
      public static const TILE_HEIGHT:uint = 900;
      
      private static const EXIT_BACKSTOP_DEPTH:Number = 60;
      
      private var mNumberOfProps:uint;
      
      private var mPropsAdded:uint = 0;
      
      private var mFloorObjects:Set = new Set();
      
      private var mFloorObjectsSnapshot:Array;
      
      private var mOwnedFloorObjects:Set = new Set();
      
      private var mActorGameObjects:Set = new Set();
      
      private var mNPCGameObjects:Set = new Set();
      
      private var mProjectileGameObjects:Set = new Set();
      
      private var mBounds:Rectangle;
      
      private var mBackground:Prop;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mOnStage:Boolean = false;
      
      private var mIsFiller:Boolean = false;
      
      private var mIsGeneratedFiller:Boolean = false;
      
      private var mLocalHeroProximitySensors:Vector.<LocalHeroProximitySensor>;
      
      public function Tile(facade:DBFacade, numberOfProps:uint, isFiller:Boolean)
      {
         super(facade);
         mIsFiller = isFiller;
         mBounds = new Rectangle(0,0,900,900);
         mSceneGraphComponent = new SceneGraphComponent(facade,"Tile");
         mNumberOfProps = numberOfProps + 1;
         mLocalHeroProximitySensors = new Vector.<LocalHeroProximitySensor>();
         checkIfFinished();
         this.init();
      }
      
      public function isFiller() : Boolean
      {
         return mIsFiller;
      }
      
      public function get isGeneratedFiller() : Boolean
      {
         return mIsGeneratedFiller;
      }
      
      public function set isGeneratedFiller(value:Boolean) : void
      {
         mIsGeneratedFiller = value;
      }
      
      public function addBackgroundNavCollisions(backgroundJson:Object, navCollisions:Array, box2DWorld:b2World) : void
      {
         var _loc15_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc6_:Vector3D = null;
         var _loc4_:Number = NaN;
         var _loc5_:NavCollider = null;
         var _loc10_:Number = Number(backgroundJson.scale ? backgroundJson.scale : 1);
         var _loc16_:Number = backgroundJson.flip ? -1 : 1;
         var _loc8_:Number = backgroundJson.rotation ? backgroundJson.rotation * 3.141592653589793 / 180 : 0;
         var _loc7_:Number = Number(backgroundJson.x ?? 0);
         var _loc9_:Number = Number(backgroundJson.y ?? 0);
         var _loc14_:Vector3D = new Vector3D(_loc10_,_loc10_,1);
         var _loc11_:b2FilterData = buildFilter();
         for each(var _loc13_:Object in navCollisions)
         {
            _loc15_ = (_loc13_.x ? _loc13_.x : 0) * _loc10_ * _loc16_;
            _loc12_ = (_loc13_.y ? _loc13_.y : 0) * _loc10_;
            _loc6_ = new Vector3D(_loc7_ + _loc15_ * Math.cos(_loc8_) - _loc12_ * Math.sin(_loc8_),_loc9_ + _loc15_ * Math.sin(_loc8_) + _loc12_ * Math.cos(_loc8_));
            _loc4_ = _loc13_.rotation ? _loc13_.rotation * 3.141592653589793 / 180 : 0;
            _loc5_ = NavCollider.buildNavColliderFromJson(mDBFacade,_loc13_,null,_loc6_,_loc8_ + _loc16_ * _loc4_,_loc14_,box2DWorld,_loc11_);
            if(_loc5_)
            {
               _loc5_.position = this.position;
               addNavCollision(_loc5_);
            }
         }
      }
      
      public function addExitBackstops(tileJson:Object, box2DWorld:b2World) : void
      {
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc5_:Array = null;
         var _loc3_:int = 0;
         var _loc9_:int = 0;
         var _loc11_:Boolean = false;
         var _loc15_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc10_:RectangleNavCollider = null;
         var _loc8_:Array = [];
         for each(var _loc12_:Object in tileJson.LEObjects)
         {
            if(_loc12_.constant == "JASONS_DUNGEON_EXIT")
            {
               _loc13_ = Number(_loc12_.x ?? 0);
               _loc14_ = Number(_loc12_.y ?? 0);
               _loc5_ = [_loc14_,900 - _loc13_,900 - _loc14_,_loc13_];
               _loc3_ = 0;
               _loc9_ = 1;
               while(_loc9_ < 4)
               {
                  if(_loc5_[_loc9_] < _loc5_[_loc3_])
                  {
                     _loc3_ = _loc9_;
                  }
                  _loc9_++;
               }
               if(!(_loc8_[_loc3_] || tileJson.exits && tileJson.exits[_loc3_] > 0))
               {
                  _loc8_[_loc3_] = true;
                  _loc11_ = _loc3_ == 0 || _loc3_ == 2;
                  _loc15_ = _loc11_ ? 900 * 0.5 : 60 * 0.5;
                  _loc7_ = _loc11_ ? 60 * 0.5 : 900 * 0.5;
                  _loc6_ = Number([900 * 0.5,900 + _loc15_,900 * 0.5,-_loc15_][_loc3_]);
                  _loc4_ = Number([-_loc7_,900 * 0.5,900 + _loc7_,900 * 0.5][_loc3_]);
                  _loc10_ = new RectangleNavCollider(mDBFacade,null,new Vector3D(_loc6_,_loc4_),0,box2DWorld,_loc15_,_loc7_,buildFilter());
                  _loc10_.position = this.position;
                  addNavCollision(_loc10_);
               }
            }
         }
      }
      
      public function addOwnedFloorObject(floorObject:FloorObject) : Boolean
      {
         return mOwnedFloorObjects.add(floorObject);
      }
      
      public function removeOwnedFloorObject(floorObject:FloorObject) : Boolean
      {
         return mOwnedFloorObjects.remove(floorObject);
      }
      
      public function hasOwnedFloorObject(floorObject:FloorObject) : Boolean
      {
         return mOwnedFloorObjects.has(floorObject);
      }
      
      override public function destroy() : void
      {
         var _loc2_:FloorObject = null;
         var _loc1_:IIterator = mOwnedFloorObjects.iterator();
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            _loc2_.destroy();
         }
         mOwnedFloorObjects.clear();
         mOwnedFloorObjects = null;
         _loc1_ = mProjectileGameObjects.iterator();
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            _loc2_.destroy();
         }
         mProjectileGameObjects = null;
         mFloorObjects.clear();
         mFloorObjects = null;
         mFloorObjectsSnapshot = null;
         mActorGameObjects.clear();
         mActorGameObjects = null;
         mNPCGameObjects.clear();
         mNPCGameObjects = null;
         mBackground = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         super.destroy();
      }
      
      override public function set position(value:Vector3D) : void
      {
         super.position = value;
         mBounds.x = this.position.x;
         mBounds.y = this.position.y;
      }
      
      public function get bounds() : Rectangle
      {
         return mBounds;
      }
      
      public function get isOnStage() : Boolean
      {
         return mOnStage;
      }
      
      public function contains(x:Number, y:Number) : Boolean
      {
         return mBounds.contains(x,y);
      }
      
      public function containsPoint(pos:Vector3D) : Boolean
      {
         return mBounds.containsPoint(new Point(pos.x,pos.y));
      }
      
      public function get floorObjects() : Set
      {
         return mFloorObjects;
      }
      
      public function get floorObjectsSnapshot() : Array
      {
         if(mFloorObjectsSnapshot == null)
         {
            mFloorObjectsSnapshot = mFloorObjects.toArray();
         }
         return mFloorObjectsSnapshot;
      }
      
      public function get actorGameObjects() : Set
      {
         return mActorGameObjects;
      }
      
      public function get NPCGameObjects() : Set
      {
         return mNPCGameObjects;
      }
      
      protected function checkIfFinished() : void
      {
         if(mPropsAdded == mNumberOfProps)
         {
         }
      }
      
      public function expandBounds(floorObject:FloorObject) : void
      {
         expandBoundsRect(floorObject.view.root.getBounds(mFacade.sceneGraphManager.worldTransformNode));
      }
      
      public function expandBoundsRect(rect:Rectangle) : void
      {
         mBounds = mBounds.union(rect);
      }
      
      public function addFloorObject(floorObject:FloorObject) : void
      {
         mFloorObjects.add(floorObject);
         mFloorObjectsSnapshot = null;
         if(floorObject is ActorGameObject)
         {
            mActorGameObjects.add(floorObject);
         }
         if(floorObject is NPCGameObject)
         {
            mNPCGameObjects.add(floorObject);
         }
         if(floorObject is ChainProjectileGameObject)
         {
            mProjectileGameObjects.add(floorObject);
         }
         mPropsAdded = mPropsAdded + 1;
         checkIfFinished();
         if(mOnStage)
         {
            floorObject.view.addToStage();
         }
         else
         {
            floorObject.view.removeFromStage();
         }
      }
      
      public function removeFloorObject(floorObject:FloorObject) : void
      {
         if(mFloorObjects)
         {
            mFloorObjects.remove(floorObject);
         }
         mFloorObjectsSnapshot = null;
         if(floorObject is ActorGameObject && mActorGameObjects)
         {
            mActorGameObjects.remove(floorObject);
         }
         if(floorObject is NPCGameObject && mNPCGameObjects)
         {
            mNPCGameObjects.remove(floorObject);
         }
         if(floorObject is ChainProjectileGameObject && mProjectileGameObjects)
         {
            mProjectileGameObjects.remove(floorObject);
         }
      }
      
      public function ignoredAProp() : void
      {
         mPropsAdded = mPropsAdded + 1;
         checkIfFinished();
      }
      
      public function set background(backgroundProp:Prop) : void
      {
         mBackground = backgroundProp;
         if(mOnStage)
         {
            mSceneGraphComponent.addChildAt(mBackground.view.root,5,0);
         }
         mPropsAdded = mPropsAdded + 1;
         checkIfFinished();
      }
      
      public function get background() : Prop
      {
         return mBackground;
      }
      
      public function addToStage() : void
      {
         var _loc2_:FloorObject = null;
         if(mOnStage)
         {
            return;
         }
         var _loc1_:IIterator = mFloorObjects.iterator();
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            if(_loc2_.view == null)
            {
               Logger.warn("floorObject with null view attempted addToStage id: " + _loc2_.id);
            }
            else
            {
               _loc2_.view.addToStage();
            }
         }
         if(mBackground)
         {
            mBackground.view.root.parent.setChildIndex(mBackground.view.root,0);
         }
         mOnStage = true;
      }
      
      public function removeFromStage() : void
      {
         var _loc2_:FloorObject = null;
         if(!mOnStage)
         {
            return;
         }
         var _loc1_:IIterator = mFloorObjects.iterator();
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            if(_loc2_.view == null)
            {
               Logger.warn("floorObject with null view attempted removeFromStage id: " + _loc2_.id);
            }
            else
            {
               _loc2_.view.removeFromStage();
            }
         }
         mOnStage = false;
      }
      
      public function createLocalEventCollision(distributedDungeonFloor:DistributedDungeonFloor, x:uint, y:uint, radius:uint, triggerOnce:Boolean, onCollisionCallback:Function) : void
      {
         mLocalHeroProximitySensors.push(new LocalHeroProximitySensor(mDBFacade,distributedDungeonFloor,this.position.x + x,this.position.y + y,radius,triggerOnce,onCollisionCallback));
      }
   }
}

