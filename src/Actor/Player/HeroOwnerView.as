package Actor.Player
{
   import Actor.DamageFloater;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Sound.SoundAsset;
   import Brain.Sound.SoundHandle;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.Task;
   import DBGlobals.DBGlobal;
   import DistributedObjects.HeroGameObject;
   import Dungeon.Tile;
   import Effects.EffectGameObject;
   import Effects.EffectView;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   
   public class HeroOwnerView extends HeroView
   {
      
      public static var HIT_AREA_HALF_WIDTH:Number = 15;
      
      public static var HIT_AREA_HALF_HEIGHT:Number = 25;
      
      public static var HIT_AREA_Y_OFFSET:Number = 10;
      
      public static var ACTIVATE_HEARTBEAT_AT_HEALTH_LEVEL:Number = 0.25;
      
      public var wantMouseEnabled:Boolean = false;
      
      private var mVisibilityTask:Task;
      
      protected var mNotEnoughManaSoundEffect:SoundAsset;
      
      protected var mFootRing:EffectGameObject;
      
      protected var mHeartbeatSoundEffect:SoundAsset;
      
      protected var mHeartbeatSoundHandle:SoundHandle;
      
      public function HeroOwnerView(dbFacade:DBFacade, heroGameObject:HeroGameObject)
      {
         super(dbFacade,heroGameObject);
      }
      
      private function fadeOccludingObjects(gameClock:GameClock) : void
      {
         var _loc11_:FloorObject = null;
         var _loc7_:Point = null;
         var _loc12_:* = null;
         var _loc8_:* = null;
         var _loc2_:Array = null;
         var _loc5_:int = 0;
         var _loc9_:int = 0;
         var _loc6_:Tile = null;
         if(mHeroPlayerObject.tile == null)
         {
            Logger.warn("mHeroPlayerObject.tile is null.");
            return;
         }
         var _loc4_:Point = new Point();
         var _loc10_:Number = 4;
         var _loc3_:Vector.<Tile> = mHeroPlayerObject.distributedDungeonFloor.GetTilesAroundAvatar(_loc10_);
         for each(_loc6_ in _loc3_)
         {
            _loc2_ = _loc6_.floorObjectsSnapshot;
            _loc5_ = int(_loc2_.length);
            _loc9_ = 0;
            while(_loc9_ < _loc5_)
            {
               _loc11_ = _loc2_[_loc9_];
               if(_loc11_.archwayAlpha && _loc11_.view.root.hitTestObject(mBody))
               {
                  _loc4_.x = mBody.x;
                  _loc4_.y = mBody.y;
                  _loc7_ = mDBFacade.designLocalToGlobal(mBody,_loc4_);
                  if(_loc11_.view.root.hitTestPoint(_loc7_.x,_loc7_.y,false))
                  {
                     _loc11_.view.doFade();
                  }
               }
               _loc9_++;
            }
         }
      }
      
      override public function init() : void
      {
         super.init();
         this.nametag.hpBarVisible = false;
         mVisibilityTask = mLogicalWorkComponent.doEveryFrame(fadeOccludingObjects);
         if(!wantMouseEnabled)
         {
            root.mouseEnabled = false;
            root.mouseChildren = false;
         }
         else
         {
            setFixedMouseHitRect(-HIT_AREA_HALF_WIDTH,-HIT_AREA_HALF_HEIGHT + BODY_Y_OFFSET + HIT_AREA_Y_OFFSET,HIT_AREA_HALF_WIDTH * 2,HIT_AREA_HALF_HEIGHT * 2);
            root.mouseChildren = false;
         }
         mFootRing = new EffectGameObject(mDBFacade,DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),"db_fx_player_ring",1);
         MemoryTracker.track(mFootRing,"EffectGameObject \'db_fx_player_ring\' - created in HeroOwnerView.init()","pool");
         mFootRing.view.root.scaleX = mFootRing.view.root.scaleY = 0.75;
         EffectView(mFootRing.view).attachToParent(mBody,true);
         EffectView(mFootRing.view).play(true,function():void
         {
         });
         registerStatusTintAttachment(EffectView(mFootRing.view));
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH),"TEMP_Heartbeat1",function(param1:SoundAsset):void
         {
            mHeartbeatSoundEffect = param1;
         });
      }
      
      override public function setHp(hp:uint, maxHp:uint) : void
      {
         super.setHp(hp,maxHp);
         if(hp <= maxHp * ACTIVATE_HEARTBEAT_AT_HEALTH_LEVEL)
         {
            if(mHeartbeatSoundHandle)
            {
               return;
            }
            if(mHeartbeatSoundEffect)
            {
               mHeartbeatSoundHandle = mSoundComponent.playSfxManaged(mHeartbeatSoundEffect);
               mHeartbeatSoundHandle.play(2147483647);
            }
         }
         else
         {
            stopHeartbeatSound();
         }
      }
      
      public function stopHeartbeatSound() : void
      {
         if(!mHeartbeatSoundHandle)
         {
            return;
         }
         mHeartbeatSoundHandle.stop();
         mHeartbeatSoundHandle.destroy();
         mHeartbeatSoundHandle = null;
      }
      
      override public function set position(pos:Vector3D) : void
      {
         if(isNaN(mPrevPosX))
         {
            mPrevPosX = pos.x;
            mPrevPosY = pos.y;
         }
         mTickPosX = pos.x;
         mTickPosY = pos.y;
         mRoot.x = pos.x;
         mRoot.y = pos.y;
      }
      
      public function get outOfManaSoundEffect() : SoundAsset
      {
         return mNotEnoughManaSoundEffect;
      }
      
      override public function spawnDamageFloater(isCriticalHit:Boolean, delta:int, attackerIsOwner:Boolean, attackeeIsOwner:Boolean, effectiveness:int, inType:uint = 0, floaterType:String = "DAMAGE_MOVEMENT_TYPE") : void
      {
         if(wantDamageFloaters)
         {
            DamageFloater.spawn(mDBFacade,delta,mParentActorObject,0,24,1.2,90,attackerIsOwner,attackeeIsOwner,isCriticalHit,effectiveness,inType,floaterType);
         }
      }
      
      override public function destroy() : void
      {
         mNotEnoughManaSoundEffect = null;
         mVisibilityTask.destroy();
         if(mFootRing)
         {
            unregisterStatusTintAttachment(EffectView(mFootRing.view));
            mFootRing.destroy();
            mFootRing = null;
         }
         if(mHeartbeatSoundEffect)
         {
            mHeartbeatSoundEffect = null;
         }
         if(mHeartbeatSoundHandle)
         {
            mHeartbeatSoundHandle.destroy();
            mHeartbeatSoundHandle = null;
         }
         super.destroy();
      }
   }
}

