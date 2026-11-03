package Dungeon
{
   import Brain.Logger.Logger;
   import Brain.Render.RendererFactorySelector;
   import Brain.Utils.MemoryTracker;
   import Collections.Map;
   import DistributedObjects.DistributedDungeonFloor;
   import Events.LEClientEvent;
   import Facade.DBFacade;
   import GeneratedCode.DungeonTileUsage;
   import Starling.StarlingViewFactory;
   import Starling.SwfFallbackDebug;
   import flash.geom.Vector3D;
   
   public class TileFactory
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mFactoriesReady:Function;
      
      protected var mPropFactoryReady:Boolean = false;
      
      protected var mTileFactoryReady:Boolean = false;
      
      protected var mPropFactory:PropFactory;
      
      protected var mStarlingViewFactory:StarlingViewFactory;
      
      protected var mTileMap:Map = new Map();
      
      public var mFillerTiles:Array = [];
      
      protected var mLocalProximityTriggers:Array;
      
      private var mTriggerToTriggerable:Map = new Map();
      
      private var mTriggerableEventsById:Map = new Map();
      
      protected var mTileLibraryJson:Object;
      
      protected var mNpcForceFlashByTilePosition:Map;
      
      public function TileFactory(facade:DBFacade, libraryJson:Array, tileLibraryJson:Object)
      {
         super();
         mDBFacade = facade;
         mTileLibraryJson = tileLibraryJson;
         mNpcForceFlashByTilePosition = new Map();
         loadTileLibrary();
         loadTileTriggersAndTriggerables();
         mPropFactory = new PropFactory(mDBFacade,libraryJson);
         mStarlingViewFactory = new StarlingViewFactory(mDBFacade);
         MemoryTracker.track(mPropFactory,"PropFactory - created in TileFactory.constructor()");
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         mPropFactory.destroy();
         mPropFactory = null;
         mStarlingViewFactory.destroy();
         mStarlingViewFactory = null;
         mFactoriesReady = null;
         mNpcForceFlashByTilePosition = null;
         mTriggerToTriggerable.clear();
         mTriggerToTriggerable = null;
         mTriggerableEventsById.clear();
         mTriggerableEventsById = null;
      }
      
      public function get propFactory() : PropFactory
      {
         return mPropFactory;
      }
      
      public function get starlingViewFactory() : StarlingViewFactory
      {
         return mStarlingViewFactory;
      }
      
      protected function propFactoryReady() : void
      {
         mPropFactoryReady = true;
         checkIfReady();
      }
      
      protected function checkIfReady() : void
      {
         if(mPropFactoryReady && mTileFactoryReady)
         {
            mFactoriesReady();
         }
      }
      
      protected function loadTileLibrary() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = mTileLibraryJson.LETiles as Array;
         var _loc1_:uint = _loc3_.length;
         while(_loc2_ < _loc1_)
         {
            mTileMap.add(_loc3_[_loc2_].id,_loc3_[_loc2_]);
            if(_loc3_[_loc2_].category == "FILLER_TILE")
            {
               mFillerTiles.push(_loc3_[_loc2_]);
            }
            _loc2_++;
         }
         mTileFactoryReady = true;
         checkIfReady();
      }
      
      protected function loadTileTriggersAndTriggerables() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Array = mTileLibraryJson.LETriggers as Array;
         var _loc1_:uint = _loc3_.length;
         while(_loc2_ < _loc1_)
         {
            mTriggerToTriggerable.add(_loc3_[_loc2_].triggerId,_loc3_[_loc2_].triggerableId);
            _loc2_++;
         }
      }
      
      public function buildTile(tileNetworkComponent:DungeonTileUsage, addToGrid:Function, tileInitialized:Function, distributedDungeonFloor:DistributedDungeonFloor, isGeneratedFiller:Boolean = false) : void
      {
         var _loc6_:Object = null;
         mLocalProximityTriggers = [];
         var _loc7_:Object = mTileMap.itemFor(tileNetworkComponent.tileId);
         if(_loc7_ == null)
         {
            Logger.warn("Could not find tileId: " + tileNetworkComponent.tileId + " in mTileMap");
            return;
         }
         var _loc8_:Tile = new Tile(mDBFacade,_loc7_.LEObjects.length,_loc7_.category == "FILLER_TILE");
         MemoryTracker.track(_loc8_,"Tile - created in TileFactory.buildTile()");
         _loc8_.position = new Vector3D(tileNetworkComponent.x,tileNetworkComponent.y);
         _loc8_.isGeneratedFiller = isGeneratedFiller;
         addToGrid(_loc8_);
         tileInitialized(_loc8_);
         buildBackground(_loc7_.LEBackground,_loc8_,distributedDungeonFloor);
         for each(_loc6_ in _loc7_.LEObjects)
         {
            buildingProp(_loc6_,_loc8_,distributedDungeonFloor);
         }
         for each(_loc6_ in _loc7_.LETriggers)
         {
            buildingProp(_loc6_,_loc8_,distributedDungeonFloor);
         }
         for each(_loc6_ in mLocalProximityTriggers)
         {
            analyzeLocalProximityTrigger(_loc6_,_loc8_,distributedDungeonFloor);
         }
         _loc8_.addExitBackstops(_loc7_,distributedDungeonFloor.box2DWorld);
      }
      
      protected function buildingProp(propJsonObj:Object, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) : void
      {
         switch(propJsonObj.type)
         {
            case "LEProp":
               buildProp(propJsonObj,tile,distributedDungeonFloor);
               break;
            case "LEHeroSpawnProp":
            case "LENPCGenerator":
            case "LECollectable":
            case "LETriggerGate":
            case "LETriggerableCamera":
            case "LENPCGeneratorWithAllSpawnsDeadTrigger":
               tile.ignoredAProp();
               break;
            case "LENPC":
               recordNpcForceFlash(propJsonObj,tile.position);
               tile.ignoredAProp();
               break;
            case "LETriggerable":
               if(propJsonObj.constant == "SEND_LOCAL_CLIENT_EVENT")
               {
                  mTriggerableEventsById.add(uint(propJsonObj.id),new TriggerableEvent(propJsonObj.id,propJsonObj.textKey));
               }
               break;
            case "LETrigger":
               if(propJsonObj.constant == "PROXIMITY_LOCAL_HERO")
               {
                  mLocalProximityTriggers.push(propJsonObj);
               }
               break;
            default:
               Logger.debug("Do not know how to handle type: " + propJsonObj.type.toString() + " Ignoring.");
               tile.ignoredAProp();
         }
      }
      
      protected function buildProp(propJsonObj:Object, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) : void
      {
         var _loc4_:Boolean = Prop.validatePropConstant(propJsonObj,mDBFacade);
         if(!_loc4_)
         {
            Logger.warn("invalid prop constant: " + propJsonObj.constant);
            return;
         }
         var _loc5_:Prop = Prop.parseFromTileJson(propJsonObj,tile,mDBFacade);
         _loc5_.distributedDungeonFloor = distributedDungeonFloor;
      }
      
      protected function analyzeLocalProximityTrigger(propJsonObj:Object, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) : void
      {
         var triggerableEvent:TriggerableEvent;
         var triggerableId:uint = mTriggerToTriggerable.itemFor(propJsonObj.id);
         if(triggerableId)
         {
            triggerableEvent = mTriggerableEventsById.itemFor(triggerableId);
            if(triggerableEvent)
            {
               tile.createLocalEventCollision(distributedDungeonFloor,propJsonObj.x,propJsonObj.y,propJsonObj.radius,propJsonObj.triggerOnce,function():void
               {
                  mDBFacade.eventManager.dispatchEvent(new LEClientEvent(triggerableEvent.eventName));
               });
            }
         }
      }
      
      protected function recordNpcForceFlash(npcJsonObj:Object, tilePosition:Vector3D) : void
      {
         var _loc4_:String = tilePosition.x + "," + tilePosition.y;
         var _loc3_:Array = mNpcForceFlashByTilePosition.itemFor(_loc4_) as Array;
         if(_loc3_ == null)
         {
            _loc3_ = [];
            mNpcForceFlashByTilePosition.add(_loc4_,_loc3_);
         }
         _loc3_.push({
            "constant":npcJsonObj.constant,
            "x":npcJsonObj.x,
            "y":npcJsonObj.y,
            "forceFlash":npcJsonObj.forceFlash == true
         });
      }
      
      public function getForceFlashForNpc(constant:String, tilePosition:Vector3D, localX:Number, localY:Number) : Boolean
      {
         var _loc7_:String = tilePosition.x + "," + tilePosition.y;
         var _loc6_:Array = mNpcForceFlashByTilePosition.itemFor(_loc7_) as Array;
         if(_loc6_ == null)
         {
            return false;
         }
         for each(var _loc5_:Object in _loc6_)
         {
            if(_loc5_.constant == constant && Math.abs(_loc5_.x - localX) < 0.5 && Math.abs(_loc5_.y - localY) < 0.5)
            {
               return _loc5_.forceFlash == true;
            }
         }
         return false;
      }
      
      protected function buildBackground(propJsonObj:Object, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) : void
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Prop = null;
         var _loc4_:Boolean = Prop.validatePropConstant(propJsonObj,mDBFacade);
         if(!_loc4_)
         {
            Logger.warn("invalid background constant: " + propJsonObj.constant);
            return;
         }
         var _loc12_:RendererFactorySelector = mDBFacade.rendererFactorySelector;
         var _loc7_:String = _loc12_.getLayerBackend(5);
         if(_loc7_ == "starling" && _loc12_.starlingFactory != null && _loc12_.starlingFactory.backend.isReady)
         {
            _loc10_ = tile.position.x + (propJsonObj.x ?? 0);
            _loc11_ = tile.position.y + (propJsonObj.y ?? 0);
            _loc5_ = 1.0022222222222221;
            var _loc6_:Number = 1.0022222222222221;
            _loc8_ = 0;
            if(propJsonObj.flip)
            {
               _loc5_ = -_loc5_;
            }
            if(propJsonObj.rotation)
            {
               _loc8_ = Number(propJsonObj.rotation);
            }
            starlingViewFactory.buildViewFromAsset(propJsonObj.constant,_loc10_,_loc11_,_loc5_,_loc6_,_loc8_,tile.isOnStage,tile.isFiller());
            tile.addBackgroundNavCollisions(propJsonObj,mPropFactory.getNavCollisionJson(propJsonObj.constant),distributedDungeonFloor.box2DWorld);
         }
         else
         {
            SwfFallbackDebug.report(mDBFacade,"TILE",propJsonObj.constant,null,"ground layer backend is \'" + _loc7_ + "\'" + (_loc12_.starlingFactory == null ? " (no Starling factory)" : (!_loc12_.starlingFactory.backend.isReady ? " (Starling backend not ready)" : "")));
            _loc9_ = Prop.parseFromTileJson(propJsonObj,tile,mDBFacade);
            _loc9_.view.root.scaleX = _loc9_.view.root.scaleY = 1.0022222222222221;
            _loc9_.layer = 5;
            _loc9_.distributedDungeonFloor = distributedDungeonFloor;
            tile.background = _loc9_;
         }
      }
   }
}

