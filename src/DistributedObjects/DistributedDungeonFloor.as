package DistributedObjects
{
   import Actor.ActorGameObject;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Brain.Sound.SoundAsset;
   import Brain.Sound.SoundHandle;
   import Brain.Utils.MemoryTracker;
   import Doobers.DooberGameObject;
   import Dungeon.DungeonFloorFactory;
   import Dungeon.RectangleNavCollider;
   import Dungeon.Tile;
   import Dungeon.TileGrid;
   import Effects.EffectManager;
   import Events.ActorLifetimeEvent;
   import Facade.DBFacade;
   import Floor.FloorMessageView;
   import Floor.FloorObject;
   import GameMasterDictionary.GMColiseumTier;
   import GameMasterDictionary.GMMapNode;
   import GeneratedCode.DistributedDungeonFloorNetworkComponent;
   import GeneratedCode.DungeonTileUsage;
   import GeneratedCode.IDistributedDungeonFloor;
   import Pathfinding.Astar;
   import Sound.DBSoundComponent;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.IMapIterator;
   import org.as3commons.collections.framework.ISetIterator;
   
   public class DistributedDungeonFloor extends Floor implements IDistributedDungeonFloor
   {
      
      private static const MUSIC_BUFFER:Number = 1000;
      
      protected var mTileNetworkComponents:Vector.<DungeonTileUsage>;
      
      protected var mTileLibraryPath:String = "uninitialized";
      
      protected var mDungeonFloorFactory:DungeonFloorFactory;
      
      protected var mTileGrid:TileGrid;
      
      public var astarGrids:Astar = new Astar();
      
      private var mActiveOwnerAvatar:HeroGameObjectOwner;
      
      private var mRemoteHeroes:Map;
      
      private var mRemoteActors:Map;
      
      private var mDoobers:Dictionary;
      
      private var mBuildPropReady:Boolean = false;
      
      private var mPostGenerate:Boolean;
      
      private var mFloorObjectsAwaitingDungeonFloor:Set;
      
      private var mColiseumTierConstant:String;
      
      private var mCurrentMapNodeId:uint;
      
      private var mMapNode:GMMapNode;
      
      private var mEffectManager:EffectManager;
      
      private var mBaseLining:uint;
      
      private var mIntroMovieSwfFilePath:String;
      
      private var mIntroMovieAssetClassName:String;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mCurrentFloorNum:uint;
      
      protected var mDBSoundComponent:DBSoundComponent;
      
      private var mMusicTestSoundHandle:SoundHandle;
      
      private var mBgMusic:Sound;
      
      public function DistributedDungeonFloor(dbFacade:DBFacade, remoteId:uint)
      {
         Logger.debug("New  DistributedDungeonFloor******************************");
         mPostGenerate = false;
         super(dbFacade,remoteId);
         mRemoteHeroes = new Map();
         mRemoteActors = new Map();
         mDoobers = new Dictionary(true);
         mFloorObjectsAwaitingDungeonFloor = new Set();
         mEffectManager = new EffectManager(mDBFacade);
         MemoryTracker.track(mEffectManager,"EffectManager - created in DistributedDungeonFloor.constructor()");
         mBaseLining = 0;
         mDBSoundComponent = new DBSoundComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
      }
      
      public function set coliseumTierConstant(val:String) : void
      {
         mColiseumTierConstant = val;
      }
      
      public function set mapNodeId(val:uint) : void
      {
         mCurrentMapNodeId = val;
      }
      
      override public function get isInfiniteDungeon() : Boolean
      {
         return mMapNode.IsInfiniteDungeon;
      }
      
      public function getActor(id:uint) : ActorGameObject
      {
         if(mActiveOwnerAvatar && mActiveOwnerAvatar.id == id)
         {
            return mActiveOwnerAvatar;
         }
         var _loc2_:ActorGameObject = mRemoteActors.itemFor(id);
         if(_loc2_)
         {
            return _loc2_;
         }
         _loc2_ = mRemoteHeroes.itemFor(id);
         if(_loc2_)
         {
            return _loc2_;
         }
         return null;
      }
      
      public function get effectManager() : EffectManager
      {
         return mEffectManager;
      }
      
      public function get numHeroes() : uint
      {
         return 1 + mRemoteHeroes.size;
      }
      
      public function get remoteHeroes() : Map
      {
         return mRemoteHeroes;
      }
      
      public function get remoteActors() : Map
      {
         return mRemoteActors;
      }
      
      public function set remoteHeroes(value:Map) : void
      {
         mRemoteHeroes = value;
      }
      
      public function get activeOwnerAvatar() : HeroGameObjectOwner
      {
         return mActiveOwnerAvatar;
      }
      
      public function set activeOwnerAvatar(value:HeroGameObjectOwner) : void
      {
         mActiveOwnerAvatar = value;
      }
      
      override public function getCurrentFloorNum() : uint
      {
         return mCurrentFloorNum % 1000 + 1;
      }
      
      override public function getMaxFloorNum() : uint
      {
         return uint(mCurrentFloorNum / 1000);
      }
      
      public function get tileGrid() : TileGrid
      {
         return mTileGrid;
      }
      
      public function setNetworkComponentDistributedDungeonFloor(iface:DistributedDungeonFloorNetworkComponent) : void
      {
      }
      
      public function get dungeonFloorFactory() : DungeonFloorFactory
      {
         return mDungeonFloorFactory;
      }
      
      public function postGenerate() : void
      {
         mPostGenerate = true;
         mDungeonFloorFactory = new DungeonFloorFactory(this,initGridCallback,mDBFacade,mTileLibraryPath);
         MemoryTracker.track(mDungeonFloorFactory,"DungeonFloorFactory - created in DistributedDungeonFloor.postGenerate()");
         astarGrids.Init(this);
         mDungeonFloorFactory.buildDungeonFloor(mTileNetworkComponents,finishedBuildingTiles);
         mMapNode = mDBFacade.gameMaster.getMapNode(mCurrentMapNodeId);
         this.playIntroMovie();
         this.playMusic();
         buildFloorEndingGui();
      }
      
      override public function victory() : void
      {
         logDungeonCompletion();
         super.victory();
         if(mDBFacade.steamAchievementsManager)
         {
            mDBFacade.steamAchievementsManager.unlockFloorCompleted(mMapNode.Constant);
         }
      }
      
      override public function defeat() : void
      {
         logDungeonCompletion();
         var _loc1_:uint = getCurrentFloorNum();
         if(mDBFacade.steamAchievementsManager)
         {
            mDBFacade.steamAchievementsManager.setHighestFloorAchieved(mMapNode,_loc1_);
         }
         super.defeat();
      }
      
      private function formatHeroInfo(hero:HeroGameObject) : String
      {
         return "\"" + hero.screenName + "\" AccountId=" + hero.playerID + " Avatar=\"" + hero.gMHero.Name + "\" Skin=\"" + hero.gmSkin.Name + "\"";
      }
      
      private function formatFellowPlayers(prefix:String) : String
      {
         if(mRemoteHeroes.size == 0)
         {
            return "";
         }
         var _loc2_:String = prefix;
         var _loc3_:IIterator = mRemoteHeroes.iterator();
         var _loc4_:Boolean = true;
         while(_loc3_.hasNext())
         {
            if(!_loc4_)
            {
               _loc2_ += ", ";
            }
            _loc2_ += formatHeroInfo(_loc3_.next() as HeroGameObject);
            _loc4_ = false;
         }
         return _loc2_;
      }
      
      private function getFloorString() : String
      {
         var _loc1_:GMColiseumTier = mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mMapNode.TierRank);
         return "floor " + getCurrentFloorNum() + "/" + _loc1_.TotalFloors;
      }
      
      private function logWelcomeMessage() : void
      {
         if(!mActiveOwnerAvatar || !mMapNode)
         {
            return;
         }
         Logger.debugch("PlayerInfo","Welcome (" + mActiveOwnerAvatar.playerID + ") to the dungeon \"" + mMapNode.Name + "\" (" + mCurrentMapNodeId + ") " + getFloorString() + " SessionId=" + mDBFacade.sessionInfoString);
      }
      
      private function logPlayerJoined(hero:HeroGameObject) : void
      {
         Logger.debugch("PlayerInfo",formatHeroInfo(hero) + " joined floor " + getCurrentFloorNum() + ".");
      }
      
      private function logPlayerLeft(hero:HeroGameObject) : void
      {
         if(!isAlive())
         {
            return;
         }
         Logger.debugch("PlayerInfo",formatHeroInfo(hero) + " left floor " + getCurrentFloorNum() + ".");
      }
      
      private function logDungeonCompletion() : void
      {
         if(!mActiveOwnerAvatar || !mMapNode)
         {
            return;
         }
         Logger.debugch("PlayerInfo","You (" + mActiveOwnerAvatar.playerID + ") finished the dungeon \"" + mMapNode.Name + "\" (" + mCurrentMapNodeId + ") " + getFloorString() + " SessionId=" + mDBFacade.sessionInfoString + formatFellowPlayers(", you were playing with "));
      }
      
      private function playMusic() : void
      {
         var _loc3_:URLRequest = null;
         var _loc2_:SoundLoaderContext = null;
         var _loc1_:GMColiseumTier = mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mColiseumTierConstant);
         if(_loc1_ && _loc1_.MusicFilepath)
         {
            mBgMusic = new Sound();
            _loc3_ = new URLRequest(DBFacade.buildFullDownloadPath(_loc1_.MusicFilepath));
            _loc2_ = new SoundLoaderContext(1000,true);
            _loc2_.checkPolicyFile = true;
            mBgMusic.load(_loc3_,_loc2_);
            mBgMusic.addEventListener("complete",onBgMusicLoaded);
            mBgMusic.addEventListener("ioError",onBgMusicError);
            mBgMusic.addEventListener("securityError",onBgMusicError);
         }
      }
      
      private function onBgMusicLoaded(e:Event) : void
      {
         if(mDBSoundComponent)
         {
            mDBSoundComponent.playStreamingMusic(mBgMusic);
         }
      }
      
      private function onBgMusicError(evt:Event) : void
      {
         Logger.error("BgMusic load error: " + evt.toString());
      }
      
      public function get coliseumTier() : GMColiseumTier
      {
         return mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mColiseumTierConstant);
      }
      
      public function get completionXp() : uint
      {
         return mMapNode.CompletionXPBonus;
      }
      
      private function initGridCallback(tileGrid:TileGrid) : void
      {
         mTileGrid = tileGrid;
      }
      
      public function tileLibrary(tilegrp:String) : void
      {
         mTileLibraryPath = tilegrp;
      }
      
      public function set introMovieSwfFilePath(value:String) : void
      {
         Logger.debug("introMovie: swfFilePath: " + value);
         mIntroMovieSwfFilePath = value;
      }
      
      public function set introMovieAssetClassName(value:String) : void
      {
         Logger.debug("introMovie: assetClassName: " + value);
         mIntroMovieAssetClassName = value;
      }
      
      public function get currentFloorNum() : uint
      {
         return mCurrentFloorNum;
      }
      
      public function set currentFloorNum(value:uint) : void
      {
         Logger.debug("introMovie: assetClassName: " + value);
         mCurrentFloorNum = value;
      }
      
      private function playIntroMovie() : void
      {
         if(mIntroMovieSwfFilePath && mIntroMovieAssetClassName)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mIntroMovieSwfFilePath),function(param1:SwfAsset):void
            {
               var onKeyDown:Function;
               var asset:SwfAsset = param1;
               var movieClass:Class = asset.getClass(mIntroMovieAssetClassName);
               var movie:MovieClip = new movieClass();
               var stopMovie:Function = function(param1:Event = null):void
               {
                  if(movie.currentFrame == movie.totalFrames || param1 == null)
                  {
                     mDBFacade.stageRef.removeEventListener("keyDown",onKeyDown);
                     mDBFacade.removeRootDisplayObject(movie);
                     movie.removeEventListener("enterFrame",stopMovie);
                     mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_HERO"));
                     movie.stop();
                     mDBFacade.assetRepository.removeFromCache(asset);
                     movie = null;
                  }
               };
               mDBFacade.addRootDisplayObject(movie);
               movie.addEventListener("enterFrame",stopMovie);
               movie.gotoAndPlay(1);
               movie.x = 972.5;
               movie.y = 320;
               onKeyDown = function(param1:KeyboardEvent):void
               {
                  if(param1.keyCode == 27)
                  {
                     stopMovie();
                  }
               };
               mDBFacade.stageRef.addEventListener("keyDown",onKeyDown);
            });
         }
         else
         {
            mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_HERO"));
         }
      }
      
      public function show_text(textkey:String) : void
      {
         var _loc2_:FloorMessageView = new FloorMessageView(mDBFacade,textkey);
         MemoryTracker.track(_loc2_,"FloorMessageView - created in DistributedDungeonFloor.show_text()");
      }
      
      public function play_sound(sound:String) : void
      {
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),sound,function(param1:SoundAsset):void
         {
            mDBSoundComponent.playOneShot(param1,"sfx");
         });
      }
      
      public function trigger_camera_zoom(zoom:Number) : void
      {
         mDBFacade.camera.tweenZoom(1,zoom,true);
      }
      
      public function trigger_camera_shake(shakeDuration:Number, shakeStrength:Number, shakeCount:uint) : void
      {
         mDBFacade.camera.shakeY(shakeDuration / 24,shakeStrength,shakeCount);
      }
      
      public function tiles(tiles:Vector.<DungeonTileUsage>) : void
      {
         var _loc3_:* = undefined;
         var _loc4_:* = 0;
         var _loc2_:Boolean = false;
         var _loc5_:* = 0;
         if(mPostGenerate)
         {
            _loc3_ = new Vector.<DungeonTileUsage>();
            _loc4_ = 0;
            while(_loc4_ < tiles.length)
            {
               _loc2_ = false;
               _loc5_ = 0;
               while(_loc5_ < mTileNetworkComponents.length)
               {
                  if(tiles[_loc4_].x == mTileNetworkComponents[_loc5_].x && tiles[_loc4_].y == mTileNetworkComponents[_loc5_].y)
                  {
                     _loc2_ = true;
                  }
                  _loc5_++;
               }
               if(!_loc2_)
               {
                  _loc3_.push(tiles[_loc4_]);
               }
               _loc4_++;
            }
            mDungeonFloorFactory.buildDungeonFloor(_loc3_,finishedBuildingTiles);
         }
         mTileNetworkComponents = tiles;
      }
      
      protected function finishedBuildingTiles(tileGrid:TileGrid) : void
      {
         var _loc3_:FloorObject = null;
         mTileGrid = tileGrid;
         mBuildPropReady = true;
         var _loc2_:ISetIterator = mFloorObjectsAwaitingDungeonFloor.iterator() as ISetIterator;
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next() as FloorObject;
            _loc3_.distributedDungeonFloor = this;
         }
         mFloorObjectsAwaitingDungeonFloor.clear();
         fillInEmptyTilesWithCollisionVolumes();
      }
      
      private function fillInEmptyTilesWithCollisionVolumes() : void
      {
         var _loc9_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:Tile = null;
         var _loc2_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc7_:Vector3D = null;
         var _loc11_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Vector3D = null;
         var _loc10_:Number = NaN;
         var _loc8_:RectangleNavCollider = null;
         _loc9_ = 0;
         while(_loc9_ < 12)
         {
            _loc5_ = 0;
            while(_loc5_ < 12)
            {
               _loc6_ = mTileGrid.getTileAtIndex(_loc5_,_loc9_);
               if(_loc6_ == null)
               {
                  if(mTileGrid.getEmptyColliderAtIndex(_loc5_,_loc9_) == null)
                  {
                     _loc2_ = 0;
                     _loc1_ = 0;
                     _loc7_ = new Vector3D(_loc2_,_loc1_);
                     _loc11_ = 900 * _loc5_ - 900 * 0.5;
                     _loc3_ = 900 * _loc9_ - 900 * 0.5;
                     _loc4_ = new Vector3D(_loc11_,_loc3_);
                     _loc10_ = 0;
                     _loc8_ = new RectangleNavCollider(mDBFacade,_loc6_,_loc7_,_loc10_,mB2World,900 * 0.5,900 * 0.5);
                     _loc8_.position = _loc4_;
                     mTileGrid.SetEmptyColliderAtIndex(_loc5_,_loc9_,_loc8_);
                  }
               }
               _loc5_++;
            }
            _loc9_++;
         }
      }
      
      override public function destroy() : void
      {
         var _loc2_:DooberGameObject = null;
         Logger.debug("destroy DistributedDungeonFloor " + id.toString());
         mEventComponent.dispatchEvent(new Event("DUNGEON_FLOOR_DESTROY"));
         mActiveOwnerAvatar = null;
         if(mBgMusic)
         {
            mBgMusic.removeEventListener("complete",onBgMusicLoaded);
            mBgMusic.removeEventListener("ioError",onBgMusicError);
            mBgMusic.removeEventListener("securityError",onBgMusicError);
            try
            {
               mBgMusic.close();
            }
            catch(e:Error)
            {
            }
            mBgMusic = null;
         }
         if(mDBSoundComponent)
         {
            mDBSoundComponent.destroy();
            mDBSoundComponent = null;
         }
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         mDungeonFloorFactory.destroy();
         mDungeonFloorFactory = null;
         var _loc6_:Array = [];
         var _loc3_:IMapIterator = mRemoteHeroes.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc6_.push(_loc3_.next());
         }
         for each(var _loc7_:HeroGameObject in _loc6_)
         {
            if(_loc7_)
            {
               _loc7_.destroy();
            }
         }
         mRemoteHeroes.clear();
         mRemoteHeroes = null;
         var _loc5_:Array = [];
         var _loc4_:IMapIterator = mRemoteActors.iterator() as IMapIterator;
         while(_loc4_.hasNext())
         {
            _loc5_.push(_loc4_.next());
         }
         for each(var _loc1_:ActorGameObject in _loc5_)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         mRemoteActors.clear();
         mRemoteActors = null;
         for(var _loc8_:Object in mDoobers)
         {
            _loc2_ = _loc8_ as DooberGameObject;
            if(_loc2_ && !_loc2_.isDestroyed)
            {
               _loc2_.destroy();
            }
         }
         mDoobers = null;
         mFloorObjectsAwaitingDungeonFloor.clear();
         mFloorObjectsAwaitingDungeonFloor = null;
         mTileGrid.destroy();
         mTileGrid = null;
         mEffectManager.destroy();
         mEffectManager = null;
         astarGrids.destroy();
         astarGrids = null;
         super.destroy();
      }
      
      public function isAlive() : Boolean
      {
         return mTileGrid != null;
      }
      
      override public function newNetworkChild(child:GameObject) : void
      {
         var _loc2_:HeroGameObject = null;
         var _loc3_:FloorObject = null;
         if(child is HeroGameObjectOwner)
         {
            activeOwnerAvatar = child as HeroGameObjectOwner;
            logWelcomeMessage();
         }
         else if(child is HeroGameObject)
         {
            _loc2_ = child as HeroGameObject;
            remoteHeroes.add(child.id,_loc2_);
            logPlayerJoined(_loc2_);
         }
         else if(child is ActorGameObject)
         {
            remoteActors.add(child.id,child as ActorGameObject);
            mEventComponent.dispatchEvent(new ActorLifetimeEvent("ACTOR_CREATED",child.id));
         }
         else if(child is DooberGameObject)
         {
            mDoobers[child] = true;
         }
         if(child is FloorObject)
         {
            _loc3_ = child as FloorObject;
            if(mBuildPropReady)
            {
               _loc3_.distributedDungeonFloor = this;
            }
            else
            {
               mFloorObjectsAwaitingDungeonFloor.add(_loc3_);
            }
         }
      }
      
      public function RemoveNetworkChild(child:GameObject) : void
      {
         var _loc2_:HeroGameObject = null;
         var _loc3_:FloorObject = null;
         if(child is HeroGameObjectOwner)
         {
            activeOwnerAvatar = null;
         }
         else if(child is HeroGameObject)
         {
            _loc2_ = child as HeroGameObject;
            logPlayerLeft(_loc2_);
            remoteHeroes.removeKey(child.id);
         }
         else if(child is ActorGameObject)
         {
            mRemoteActors.removeKey(child.id);
            mEventComponent.dispatchEvent(new ActorLifetimeEvent("ACTOR_DESTROYED",child.id));
         }
         if(child is FloorObject)
         {
            _loc3_ = child as FloorObject;
            _loc3_.distributedDungeonFloor = null;
         }
      }
      
      public function GetTilesAroundAvatar(range:Number) : Vector.<Tile>
      {
         var _loc2_:Rectangle = null;
         if(mActiveOwnerAvatar)
         {
            _loc2_ = new Rectangle(mActiveOwnerAvatar.position.x - range,mActiveOwnerAvatar.position.y - range,range * 2,range * 2);
            return mActiveOwnerAvatar.distributedDungeonFloor.tileGrid.getVisibleTiles(_loc2_);
         }
         return new Vector.<Tile>();
      }
      
      public function GetTileIdWhichAvatarIsOn() : String
      {
         var _loc4_:* = 0;
         if(mTileNetworkComponents.length == 0)
         {
            Logger.error("Invalid tile location in getTileNetworkComponentAtLocation");
            return null;
         }
         var _loc2_:int = mActiveOwnerAvatar.position.x;
         var _loc3_:int = mActiveOwnerAvatar.position.y;
         var _loc5_:DungeonTileUsage = mTileNetworkComponents[0];
         var _loc1_:int = getDistanceFromTileUsage(_loc2_,_loc3_,_loc5_);
         var _loc6_:int = 0;
         _loc4_ = 1;
         while(_loc4_ < mTileNetworkComponents.length)
         {
            _loc6_ = getDistanceFromTileUsage(_loc2_,_loc3_,mTileNetworkComponents[_loc4_]);
            if(_loc6_ < _loc1_)
            {
               _loc1_ = _loc6_;
               _loc5_ = mTileNetworkComponents[_loc4_];
            }
            _loc4_++;
         }
         return _loc5_.tileId;
      }
      
      private function getDistanceFromTileUsage(x:int, y:int, dtu:DungeonTileUsage) : int
      {
         var _loc4_:Point = new Point(x,y);
         var _loc5_:Point = new Point(dtu.x + 450,dtu.y + 450);
         return Point.distance(_loc4_,_loc5_);
      }
      
      public function set baseLining(val:uint) : void
      {
         mBaseLining = val;
      }
      
      public function get baseLining() : uint
      {
         return mBaseLining;
      }
      
      override public function get gmMapNode() : GMMapNode
      {
         return mMapNode;
      }
      
      public function isTavern() : Boolean
      {
         return mMapNode.NodeType == "TAVERN";
      }
   }
}

