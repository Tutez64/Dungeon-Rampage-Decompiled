package Dungeon
{
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import DistributedObjects.DistributedDungeonFloor;
   import Events.LEClientEvent;
   import Facade.DBFacade;
   import GeneratedCode.DungeonTileUsage;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Map;
   
   public class TileFactory
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mFactoriesReady:Function;
      
      protected var mPropFactoryReady:Boolean = false;
      
      protected var mTileFactoryReady:Boolean = false;
      
      protected var mPropFactory:PropFactory;
      
      protected var mTileMap:Map = new Map();
      
      public var mFillerTiles:Array = [];
      
      protected var mLocalProximityTriggers:Array;
      
      protected var mTileLibraryJson:Object;
      
      public function TileFactory(facade:DBFacade, libraryJson:Array, tileLibraryJson:Object)
      {
         super();
         mDBFacade = facade;
         mTileLibraryJson = tileLibraryJson;
         loadTileLibrary();
         loadTileTriggersAndTriggerables();
         mPropFactory = new PropFactory(mDBFacade,libraryJson);
         MemoryTracker.track(mPropFactory,"PropFactory - created in TileFactory.constructor()");
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         mPropFactory.destroy();
         mPropFactory = null;
         mFactoriesReady = null;
      }
      
      public function get propFactory() : PropFactory
      {
         return mPropFactory;
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
            mDBFacade.gameMaster.triggerToTriggerable.add(_loc3_[_loc2_].triggerId,_loc3_[_loc2_].triggerableId);
            _loc2_++;
         }
      }
      
      public function buildTile(tileNetworkComponent:DungeonTileUsage, addToGrid:Function, tileInitialized:Function, distributedDungeonFloor:DistributedDungeonFloor) : void
      {
         var _loc5_:* = null;
         mLocalProximityTriggers = [];
         var _loc6_:Object = mTileMap.itemFor(tileNetworkComponent.tileId);
         if(_loc6_ == null)
         {
            Logger.warn("Could not find tileId: " + tileNetworkComponent.tileId + " in mTileMap");
            return;
         }
         var _loc7_:Tile = new Tile(mDBFacade,_loc6_.LEObjects.length,_loc6_.category == "FILLER_TILE");
         MemoryTracker.track(_loc7_,"Tile - created in TileFactory.buildTile()");
         _loc7_.position = new Vector3D(tileNetworkComponent.x,tileNetworkComponent.y);
         addToGrid(_loc7_);
         tileInitialized(_loc7_);
         buildBackground(_loc6_.LEBackground,_loc7_,distributedDungeonFloor);
         for each(_loc5_ in _loc6_.LEObjects)
         {
            buildingProp(_loc5_,_loc7_,distributedDungeonFloor);
         }
         for each(_loc5_ in _loc6_.LETriggers)
         {
            buildingProp(_loc5_,_loc7_,distributedDungeonFloor);
         }
         for each(_loc5_ in mLocalProximityTriggers)
         {
            analyzeLocalProximityTrigger(_loc5_,_loc7_,distributedDungeonFloor);
         }
      }
      
      protected function buildingProp(propJsonObj:Object, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) : void
      {
         switch(propJsonObj.type)
         {
            case "LEProp":
               buildProp(propJsonObj,tile,distributedDungeonFloor);
               break;
            case "LEHeroSpawnProp":
            case "LENPC":
            case "LENPCGenerator":
            case "LECollectable":
            case "LETriggerGate":
            case "LETriggerableCamera":
            case "LENPCGeneratorWithAllSpawnsDeadTrigger":
               tile.ignoredAProp();
               break;
            case "LETriggerable":
               if(propJsonObj.constant == "SEND_LOCAL_CLIENT_EVENT")
               {
                  mDBFacade.gameMaster.TriggerableIdToTriggerableEvent.add(uint(propJsonObj.id),new TriggerableEvent(propJsonObj.id,propJsonObj.textKey));
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
         var triggerableId:uint = mDBFacade.gameMaster.triggerToTriggerable.itemFor(propJsonObj.id);
         if(triggerableId)
         {
            triggerableEvent = mDBFacade.gameMaster.TriggerableIdToTriggerableEvent.itemFor(triggerableId);
            if(triggerableEvent)
            {
               tile.createLocalEventCollision(distributedDungeonFloor,propJsonObj.x,propJsonObj.y,propJsonObj.radius,propJsonObj.triggerOnce,function():void
               {
                  mDBFacade.eventManager.dispatchEvent(new LEClientEvent(triggerableEvent.eventName));
               });
            }
         }
      }
      
      protected function buildBackground(propJsonObj:Object, tile:Tile, distributedDungeonFloor:DistributedDungeonFloor) : void
      {
         var _loc4_:Boolean = Prop.validatePropConstant(propJsonObj,mDBFacade);
         if(!_loc4_)
         {
            Logger.warn("invalid background constant: " + propJsonObj.constant);
            return;
         }
         var _loc5_:Prop = Prop.parseFromTileJson(propJsonObj,tile,mDBFacade);
         _loc5_.view.root.scaleX = _loc5_.view.root.scaleY = 1.0022222222222221;
         _loc5_.layer = 5;
         _loc5_.distributedDungeonFloor = distributedDungeonFloor;
         tile.background = _loc5_;
      }
   }
}

