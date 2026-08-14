package Actor.Player
{
   import Actor.DamageFloater;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Sound.SoundAsset;
   import Brain.Sound.SoundHandle;
   import Brain.WorkLoop.Task;
   import DistributedObjects.HeroGameObject;
   import Dungeon.Tile;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import org.as3commons.collections.framework.IIterator;
   
   public class HeroOwnerView extends HeroView
   {
      
      public static var HIT_AREA_HALF_WIDTH:Number = 15;
      
      public static var HIT_AREA_HALF_HEIGHT:Number = 25;
      
      public static var HIT_AREA_Y_OFFSET:Number = 10;
      
      public static var ACTIVATE_HEARTBEAT_AT_HEALTH_LEVEL:Number = 0.25;
      
      public var wantMouseEnabled:Boolean = false;
      
      private var mVisibilityTask:Task;
      
      protected var mNotEnoughManaSoundEffect:SoundAsset;
      
      protected var mFootRing:MovieClip;
      
      protected var mHeartbeatSoundEffect:SoundAsset;
      
      protected var mHeartbeatSoundHandle:SoundHandle;
      
      public function HeroOwnerView(dbFacade:DBFacade, heroGameObject:HeroGameObject)
      {
         super(dbFacade,heroGameObject);
      }
      
      private function fadeOccludingObjects(gameClock:GameClock) : void
      {
         var _loc9_:FloorObject = null;
         var _loc6_:Point = null;
         var _loc10_:* = null;
         var _loc7_:* = null;
         var _loc3_:IIterator = null;
         var _loc5_:* = null;
         if(mHeroPlayerObject.tile == null)
         {
            Logger.warn("mHeroPlayerObject.tile is null.");
            return;
         }
         var _loc4_:Point = new Point();
         var _loc8_:Number = 4;
         var _loc2_:Vector.<Tile> = mHeroPlayerObject.distributedDungeonFloor.GetTilesAroundAvatar(_loc8_);
         for each(_loc5_ in _loc2_)
         {
            _loc3_ = _loc5_.floorObjects.iterator();
            while(_loc3_.hasNext())
            {
               _loc9_ = _loc3_.next();
               if(_loc9_.archwayAlpha && _loc9_.view.root.hitTestObject(mBody))
               {
                  _loc4_.x = mBody.x;
                  _loc4_.y = mBody.y;
                  _loc6_ = mBody.localToGlobal(_loc4_);
                  if(_loc9_.view.root.hitTestPoint(_loc6_.x,_loc6_.y,false))
                  {
                     _loc9_.view.doFade();
                  }
               }
            }
         }
      }
      
      override public function init() : void
      {
         var hitSprite:Sprite;
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
            hitSprite = new Sprite();
            hitSprite.mouseEnabled = false;
            hitSprite.graphics.beginFill(0,0);
            hitSprite.graphics.drawRect(-HIT_AREA_HALF_WIDTH,-HIT_AREA_HALF_HEIGHT + BODY_Y_OFFSET + HIT_AREA_Y_OFFSET,HIT_AREA_HALF_WIDTH * 2,HIT_AREA_HALF_HEIGHT * 2);
            hitSprite.graphics.endFill();
            root.mouseChildren = false;
            root.mouseEnabled = true;
            root.hitArea = hitSprite;
            root.addChild(root.hitArea);
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass("db_fx_player_ring");
            if(_loc2_)
            {
               mFootRing = new _loc2_();
               mFootRing.scaleX = mFootRing.scaleY = 0.75 * (1 / mParentActorObject.actorData.scale3DModel);
               mBody.addChildAt(mFootRing,0);
            }
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"TEMP_Heartbeat1",function(param1:SoundAsset):void
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
         mRoot.x = pos.x;
         mRoot.y = pos.y;
      }
      
      public function get outOfManaSoundEffect() : SoundAsset
      {
         return mNotEnoughManaSoundEffect;
      }
      
      override public function spawnDamageFloater(isCriticalHit:Boolean, delta:int, attackerIsOwner:Boolean, attackeeIsOwner:Boolean, effectiveness:int, type:uint = 0, floaterType:String = "DAMAGE_MOVEMENT_TYPE") : void
      {
         var _loc8_:DamageFloater = null;
         if(mDBFacade.featureFlags.getFlagValue("want-damage-floaters"))
         {
            _loc8_ = new DamageFloater(mDBFacade,delta,mParentActorObject,0,24,1.2,90,null,attackerIsOwner,attackeeIsOwner,true,isCriticalHit,effectiveness,type,floaterType);
         }
      }
      
      override public function destroy() : void
      {
         mNotEnoughManaSoundEffect = null;
         mVisibilityTask.destroy();
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

