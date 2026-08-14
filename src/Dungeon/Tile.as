package Dungeon
{
   import Actor.ActorGameObject;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Collision.LocalHeroProximitySensor;
   import DistributedObjects.DistributedDungeonFloor;
   import DistributedObjects.NPCGameObject;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import Projectile.ChainProjectileGameObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.IIterator;
   
   public class Tile extends FloorObject
   {
      
      public static const TILE_WIDTH:uint = 900;
      
      public static const TILE_HEIGHT:uint = 900;
      
      private var mNumberOfProps:uint;
      
      private var mPropsAdded:uint = 0;
      
      private var mFloorObjects:Set = new Set();
      
      private var mOwnedFloorObjects:Set = new Set();
      
      private var mActorGameObjects:Set = new Set();
      
      private var mNPCGameObjects:Set = new Set();
      
      private var mProjectileGameObjects:Set = new Set();
      
      private var mBounds:Rectangle;
      
      private var mBackground:Prop;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mOnStage:Boolean = false;
      
      private var mIsFiller:Boolean = false;
      
      private var mLocalHeroProximitySensors:Vector.<LocalHeroProximitySensor>;
      
      public function Tile(facade:DBFacade, numberOfProps:uint, isfiller:Boolean)
      {
         super(facade);
         mIsFiller = isfiller;
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
         mBounds = mBounds.union(floorObject.view.root.getBounds(mFacade.sceneGraphManager.worldTransformNode));
      }
      
      public function addFloorObject(floorObject:FloorObject) : void
      {
         mFloorObjects.add(floorObject);
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

