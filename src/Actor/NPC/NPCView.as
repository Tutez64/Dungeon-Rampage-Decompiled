package Actor.NPC
{
   import Actor.ActorRenderer;
   import Actor.ActorView;
   import Brain.Sound.SoundAsset;
   import DistributedObjects.NPCGameObject;
   import Facade.DBFacade;
   import flash.display.Sprite;
   import flash.geom.Vector3D;
   
   public class NPCView extends ActorView
   {
      
      public static var HIT_AREA_HALF_WIDTH:Number;
      
      public static var HIT_AREA_HALF_HEIGHT:Number;
      
      public static var HIT_AREA_Y_OFFSET:Number;
      
      protected var mParentNPCObject:NPCGameObject;
      
      protected var mBodyOffAnimRenderer:ActorRenderer;
      
      protected var mActivateSoundEffect:SoundAsset;
      
      protected var mDeactivateSoundEffect:SoundAsset;
      
      public function NPCView(facade:DBFacade, npcGameObject:NPCGameObject)
      {
         super(facade,npcGameObject);
         mParentNPCObject = npcGameObject;
         HIT_AREA_HALF_WIDTH = mDBFacade.dbConfigManager.getConfigNumber("enemy_hit_area_half_width",100);
         HIT_AREA_HALF_HEIGHT = mDBFacade.dbConfigManager.getConfigNumber("enemy_hit_area_half_height",100);
         HIT_AREA_Y_OFFSET = mDBFacade.dbConfigManager.getConfigNumber("enemy_hit_area_y_offset",10);
      }
      
      override public function init() : void
      {
         var hitSprite:Sprite;
         mWantNametag = mParentNPCObject.gmNpc.HasHealthbar;
         super.init();
         if(!mParentNPCObject.isAttackable)
         {
            mRoot.mouseEnabled = false;
            mRoot.mouseChildren = false;
         }
         if(mParentNPCObject.gmNpc.IsMover)
         {
            hitSprite = new Sprite();
            hitSprite.mouseEnabled = false;
            hitSprite.graphics.beginFill(0,0);
            hitSprite.graphics.drawRect(-HIT_AREA_HALF_WIDTH,-HIT_AREA_HALF_HEIGHT + BODY_Y_OFFSET + HIT_AREA_Y_OFFSET,HIT_AREA_HALF_WIDTH * 2,HIT_AREA_HALF_HEIGHT * 2);
            hitSprite.graphics.endFill();
            hitSprite.name = "NPCViewRoot.hitArea";
            root.mouseChildren = false;
            root.hitArea = hitSprite;
            root.addChild(root.hitArea);
         }
         if(mParentNPCObject.gmNpc.ActivateSound)
         {
            mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mParentNPCObject.gmNpc.ActivateSound,function(param1:SoundAsset):void
            {
               mActivateSoundEffect = param1;
            });
         }
         if(mParentNPCObject.gmNpc.DeactivateSound)
         {
            mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mParentNPCObject.gmNpc.DeactivateSound,function(param1:SoundAsset):void
            {
               mDeactivateSoundEffect = param1;
            });
         }
      }
      
      protected function initOffRenderer() : void
      {
         if(mNametag)
         {
            mNametag.visible = false;
         }
         if(mBodyOffAnimRenderer == null && mParentNPCObject.isInitialized)
         {
            mBodyOffAnimRenderer = new ActorRenderer(mDBFacade,mParentNPCObject,false);
            mBodyOffAnimRenderer.loadAssets();
            mBody.addChild(mBodyOffAnimRenderer);
            applyColor(mBodyOffAnimRenderer);
            mBodyOffAnimRenderer.heading = mParentNPCObject.heading;
         }
      }
      
      override public function destroy() : void
      {
         if(mBodyOffAnimRenderer)
         {
            mBodyOffAnimRenderer.destroy();
            mBodyOffAnimRenderer = null;
         }
         mParentNPCObject = null;
         root.hitArea = null;
         super.destroy();
      }
      
      override public function actionsForDeadState() : void
      {
         super.actionsForDeadState();
         if(mNametag)
         {
            mNametag.visible = false;
         }
         if(mParentNPCObject.gmNpc.ViolentDeathClassName && mParentNPCObject.gmNpc.ViolentDeathFilePath && mParentNPCObject.distributedDungeonFloor)
         {
            mParentNPCObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(mParentNPCObject.gmNpc.ViolentDeathFilePath),mParentNPCObject.gmNpc.ViolentDeathClassName,new Vector3D(0,BODY_Y_OFFSET),mParentNPCObject,false);
         }
      }
      
      override public function set heading(angle:Number) : void
      {
         super.heading = angle;
         if(mBodyOffAnimRenderer)
         {
            mBodyOffAnimRenderer.heading = angle;
         }
         if(mBodyAnimRenderer)
         {
            mBodyAnimRenderer.heading = angle;
         }
      }
      
      override public function get bodyAnimRenderer() : ActorRenderer
      {
         if(mParentNPCObject.triggerState)
         {
            return mBodyAnimRenderer;
         }
         return mBodyOffAnimRenderer;
      }
      
      public function set triggerState(value:Boolean) : void
      {
         var _loc2_:Boolean = mParentNPCObject.triggerState != value;
         if(value)
         {
            if(_loc2_ && mActivateSoundEffect)
            {
               mSoundComponent.playSfxOneShot(mActivateSoundEffect,worldCenter,0,mParentNPCObject ? mParentNPCObject.gmNpc.ActivateVolume : 1);
            }
            if(mBodyOffAnimRenderer)
            {
               mBodyOffAnimRenderer.stop();
            }
            if(mBodyAnimRenderer)
            {
               mBodyAnimRenderer.play(mAnimName,0,true);
            }
         }
         else
         {
            initOffRenderer();
            if(_loc2_)
            {
               if(mDeactivateSoundEffect)
               {
                  mSoundComponent.playSfxOneShot(mDeactivateSoundEffect,worldCenter,0,mParentNPCObject ? mParentNPCObject.gmNpc.DeactivateVolume : 1);
               }
               else if(mDeathSoundEffect && mParentNPCObject.gmNpc.PermCorpse)
               {
                  mSoundComponent.playSfxOneShot(mDeathSoundEffect,worldCenter,0,mParentNPCObject ? mParentNPCObject.gmNpc.DeathVolume : 1);
               }
            }
            if(mBodyAnimRenderer)
            {
               mBodyAnimRenderer.stop();
            }
            if(mBodyOffAnimRenderer)
            {
               mBodyOffAnimRenderer.play(mAnimName,0,true);
            }
            if(_loc2_)
            {
               mouseOverUnhighlight();
               disableMouse();
            }
         }
      }
   }
}

