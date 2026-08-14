package Actor
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.Sound.SoundAsset;
   import Brain.Utils.ColorMatrix;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.PreRenderWorkComponent;
   import Combat.Weapon.WeaponView;
   import DistributedObjects.HeroGameObject;
   import DistributedObjects.NPCGameObject;
   import Effects.EffectGameObject;
   import Effects.EffectView;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import Floor.FloorView;
   import GameMasterDictionary.GMAttack;
   import GeneratedCode.CombatResult;
   import Sound.DBSoundComponent;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filters.GlowFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Vector3D;
   
   public class ActorView extends FloorView
   {
      
      public static var BODY_Y_OFFSET:Number = -45;
      
      protected static var mMouseOverEffect:GlowFilter = new GlowFilter(16633879,1,16,16,5);
      
      protected static var mMouseSelectedEffect:GlowFilter = new GlowFilter(16711680,1,16,16,5);
      
      protected var mBody:Sprite;
      
      protected var mEffect:Sprite;
      
      protected var mParentActorObject:ActorGameObject;
      
      protected var mEventComponent:EventComponent;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mPreRenderWorkComponent:PreRenderWorkComponent;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mSoundComponent:DBSoundComponent;
      
      protected var mVelocity:Vector3D;
      
      protected var mBodyAnimRenderer:ActorRenderer;
      
      protected var mAnimName:String = "idle";
      
      protected var mHeading:Number = 0;
      
      protected var mWantNametag:Boolean = false;
      
      protected var mNametag:ActorNametag;
      
      protected var mCurrentWeaponView:WeaponView;
      
      protected var mCurrentWeaponAnimRenderer:ActorRenderer;
      
      protected var mBodyFilters:Array;
      
      protected var mDeathSoundEffect:SoundAsset;
      
      protected var mDeathSoundVolume:Number;
      
      private var specialVFXObject_Back:EffectGameObject;
      
      private var specialVFXObject_Front:EffectGameObject;
      
      public function ActorView(facade:DBFacade, actorGameObject:ActorGameObject)
      {
         super(facade,actorGameObject);
         mParentActorObject = actorGameObject;
         mBodyFilters = [];
         mVelocity = new Vector3D(0,0,0);
         mEventComponent = new EventComponent(mFacade);
         mPreRenderWorkComponent = new PreRenderWorkComponent(mFacade,"ActorView");
         mLogicalWorkComponent = new LogicalWorkComponent(mFacade,"ActorView");
         mSoundComponent = new DBSoundComponent(facade);
         mRoot.name = "ActorView.mRoot_" + actorGameObject.id;
         mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
         mBody = new Sprite();
         mBody.name = "ActorView.mBody";
         mRoot.addChild(mBody);
         mEffect = new Sprite();
         mEffect.name = "ActorView.mEffect";
         mRoot.addChild(mEffect);
      }
      
      protected function applyColor(node:DisplayObject) : void
      {
         var _loc3_:Number = mParentActorObject.actorData.brightness;
         var _loc5_:Number = mParentActorObject.actorData.hue;
         var _loc2_:Number = mParentActorObject.actorData.saturation;
         var _loc4_:ColorMatrix = new ColorMatrix();
         if(_loc3_ != 0)
         {
            _loc4_.adjustBrightness(_loc3_);
         }
         if(_loc5_ != 0)
         {
            _loc4_.adjustHue(_loc5_);
         }
         if(_loc2_ != 0)
         {
            _loc4_.adjustSaturation(_loc2_);
         }
         node.filters = [_loc4_.filter];
      }
      
      public function get bodyAnimRenderer() : ActorRenderer
      {
         return mBodyAnimRenderer;
      }
      
      public function get currentWeapon() : WeaponView
      {
         return mCurrentWeaponView;
      }
      
      public function set currentWeapon(value:WeaponView) : void
      {
         if(mCurrentWeaponView == value)
         {
            return;
         }
         mCurrentWeaponView = value;
         if(mCurrentWeaponAnimRenderer)
         {
            mCurrentWeaponAnimRenderer.stop();
         }
         mCurrentWeaponAnimRenderer = mCurrentWeaponView.weaponRenderer;
         if(mCurrentWeaponAnimRenderer)
         {
            if(mCurrentWeaponAnimRenderer.hasAnim(mAnimName))
            {
               this.bodyAnimRenderer.forceFrame(0);
               mCurrentWeaponAnimRenderer.heading = this.heading;
               mCurrentWeaponAnimRenderer.play(mAnimName,this.bodyAnimRenderer.currentFrame,this.bodyAnimRenderer.loop);
               mBody.addChild(mCurrentWeaponAnimRenderer);
            }
            else
            {
               mCurrentWeaponAnimRenderer.stop();
            }
         }
      }
      
      public function get nametag() : ActorNametag
      {
         return mNametag;
      }
      
      public function disableMouse() : void
      {
         mRoot.mouseChildren = false;
         mRoot.mouseEnabled = false;
      }
      
      public function enableMouse() : void
      {
         mRoot.mouseChildren = true;
         mRoot.mouseEnabled = true;
      }
      
      public function actionsForDeadState() : void
      {
         this.mouseOverUnhighlight();
         this.mouseSelectedUnhighlight();
         disableMouse();
         if(mDeathSoundEffect)
         {
            mSoundComponent.playSfxOneShot(mDeathSoundEffect,worldCenter,0,mDeathSoundVolume);
         }
         velocity = new Vector3D(0,0);
         hideSpecialEffect();
      }
      
      public function actionsForExitDeadState() : void
      {
         enableMouse();
         showSpecialEffect();
      }
      
      protected function buildNametag() : void
      {
         if(mWantNametag)
         {
            mNametag = new ActorNametag(mFacade,mAssetLoadingComponent,mLogicalWorkComponent,mParentActorObject.actorData.gMActor.NametagY);
            mNametag.cacheAsBitmap = true;
            mNametag.hpBar.scaleX = mParentActorObject.actorData.gMActor.HealthbarScale / root.scaleX;
            mNametag.hpBar.scaleY = mParentActorObject.actorData.gMActor.HealthbarScale / root.scaleY;
            mRoot.addChild(mNametag);
            mNametag.AFK = this.mParentActorObject.AFK;
            mNametag.screenName = this.mParentActorObject.screenName;
            mNametag.setHp(mParentActorObject.hitPoints,mParentActorObject.maxHitPoints);
         }
      }
      
      public function get body() : Sprite
      {
         return mBody;
      }
      
      public function buildBuff(buff:MovieClip, sortLayer:String) : void
      {
         if(buff == null)
         {
            return;
         }
         if(mRoot.contains(buff))
         {
            Logger.warn("buff already is a child of mRoot");
            return;
         }
         if(sortLayer == "foreground")
         {
            mRoot.addChild(buff);
         }
         else
         {
            mRoot.addChildAt(buff,0);
         }
      }
      
      public function destroyBuff(buff:MovieClip) : void
      {
         if(buff == null)
         {
            return;
         }
         if(mRoot.contains(buff))
         {
            mRoot.removeChild(buff);
         }
      }
      
      override public function init() : void
      {
         super.init();
         mBodyAnimRenderer = new ActorRenderer(mDBFacade,mParentActorObject,true);
         mBodyAnimRenderer.loadAssets();
         if(mParentActorObject.actorData.assetType == "SPRITE_SHEET")
         {
            mBody.scaleX = mBody.scaleY = mParentActorObject.actorData.scale3DModel;
         }
         mBody.addChild(mBodyAnimRenderer);
         applyColor(mBodyAnimRenderer);
         buildNametag();
         if(mParentActorObject.actorData.deathSound)
         {
            mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mParentActorObject.actorData.deathSound,function(param1:SoundAsset):void
            {
               mDeathSoundEffect = param1;
               mDeathSoundVolume = mParentActorObject.actorData.deathVolume;
            });
         }
         if(mParentActorObject.gmSkin && mParentActorObject.gmSkin.doesSpecialFXBackExist())
         {
            addSpecialBackEffect(mParentActorObject.gmSkin.specialFXSwfPath_Back,mParentActorObject.gmSkin.specialFXName_Back);
         }
         if(mParentActorObject.gmSkin && mParentActorObject.gmSkin.doesSpecialFXFrontExist())
         {
            addSpecialFrontEffect(mParentActorObject.gmSkin.specialFXSwfPath_Front,mParentActorObject.gmSkin.specialFXName_Front);
         }
      }
      
      public function addSpecialBackEffect(swfPath:String, className:String) : void
      {
         specialVFXObject_Back = new EffectGameObject(mDBFacade,DBFacade.buildFullDownloadPath(swfPath),className,1);
         MemoryTracker.track(specialVFXObject_Back,"EffectGameObject \'" + swfPath + ":" + className + "\' - created in ActorView.addSpecialBackEffect()");
         root.addChildAt(specialVFXObject_Back.view.root,0);
         EffectView(specialVFXObject_Back.view).play(true,function():void
         {
         });
      }
      
      public function addSpecialFrontEffect(swfPath:String, className:String) : void
      {
         specialVFXObject_Front = new EffectGameObject(mDBFacade,DBFacade.buildFullDownloadPath(swfPath),className,1);
         MemoryTracker.track(specialVFXObject_Front,"EffectGameObject \'" + swfPath + ":" + className + "\' - created in ActorView.addSpecialFrontEffect()");
         root.addChild(specialVFXObject_Front.view.root);
         EffectView(specialVFXObject_Front.view).play(true,function():void
         {
         });
      }
      
      public function showSpecialEffect() : void
      {
         if(specialVFXObject_Back)
         {
            specialVFXObject_Back.view.root.visible = true;
         }
         if(specialVFXObject_Front)
         {
            specialVFXObject_Front.view.root.visible = true;
         }
      }
      
      public function hideSpecialEffect() : void
      {
         if(specialVFXObject_Back)
         {
            specialVFXObject_Back.view.root.visible = false;
         }
         if(specialVFXObject_Front)
         {
            specialVFXObject_Front.view.root.visible = false;
         }
      }
      
      public function hasAnim(animName:String) : Boolean
      {
         return this.bodyAnimRenderer.hasAnim(animName);
      }
      
      public function getAnimDurationInSeconds(animName:String) : Number
      {
         return this.bodyAnimRenderer.getAnimDurationInSeconds(animName);
      }
      
      public function playAnim(animName:String, startingFrame:int = 0, restart:Boolean = false, loop:Boolean = true, playRate:Number = 1) : Boolean
      {
         mAnimName = animName;
         if(this.bodyAnimRenderer)
         {
            this.bodyAnimRenderer.heading = this.heading;
            this.bodyAnimRenderer.play(animName,startingFrame,restart,loop,playRate);
         }
         if(mCurrentWeaponAnimRenderer)
         {
            if(mCurrentWeaponAnimRenderer.hasAnim(animName))
            {
               mCurrentWeaponAnimRenderer.heading = this.heading;
               mCurrentWeaponAnimRenderer.play(animName,startingFrame,restart,loop,playRate);
            }
            else
            {
               mCurrentWeaponAnimRenderer.stop();
            }
         }
         return true;
      }
      
      public function get currentAnim() : String
      {
         return mAnimName;
      }
      
      public function setAnimAt(animName:String, frameNumber:uint) : Boolean
      {
         this.bodyAnimRenderer.heading = this.heading;
         this.bodyAnimRenderer.setFrame(animName,frameNumber);
         if(mCurrentWeaponAnimRenderer)
         {
            if(mCurrentWeaponAnimRenderer.hasAnim(animName))
            {
               mCurrentWeaponAnimRenderer.heading = this.heading;
               mCurrentWeaponAnimRenderer.setFrame(animName,frameNumber);
            }
            else
            {
               mCurrentWeaponAnimRenderer.stop();
            }
         }
         return true;
      }
      
      public function stopAnim() : void
      {
         this.bodyAnimRenderer.stop();
         if(mCurrentWeaponAnimRenderer)
         {
            mCurrentWeaponAnimRenderer.stop();
         }
      }
      
      public function setHp(hp:uint, maxHp:uint) : void
      {
         if(mNametag)
         {
            mNametag.setHp(hp,maxHp);
         }
      }
      
      public function set screenName(value:String) : void
      {
         if(mNametag)
         {
            mNametag.screenName = value;
         }
      }
      
      public function setChat(message:String) : void
      {
         if(mNametag)
         {
            mNametag.setChat(message);
         }
      }
      
      public function get velocity() : Vector3D
      {
         return mVelocity;
      }
      
      public function set velocity(vel:Vector3D) : void
      {
         mVelocity = vel;
      }
      
      public function set heading(angle:Number) : void
      {
         mHeading = angle;
         if(this.bodyAnimRenderer)
         {
            this.bodyAnimRenderer.heading = angle;
         }
         if(mCurrentWeaponAnimRenderer)
         {
            mCurrentWeaponAnimRenderer.heading = angle;
         }
      }
      
      public function get heading() : Number
      {
         return mHeading;
      }
      
      override public function destroy() : void
      {
         if(mNametag)
         {
            mNametag.destroy();
            mNametag = null;
         }
         if(mDeathSoundEffect)
         {
            mDeathSoundEffect = null;
         }
         mEventComponent.destroy();
         mEventComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mPreRenderWorkComponent.destroy();
         mPreRenderWorkComponent = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mSoundComponent.destroy();
         mSoundComponent = null;
         if(mBodyAnimRenderer)
         {
            mBodyAnimRenderer.destroy();
            mBodyAnimRenderer = null;
         }
         mCurrentWeaponView = null;
         mCurrentWeaponAnimRenderer = null;
         mBodyFilters = null;
         mBody = null;
         mEffect = null;
         mParentActorObject = null;
         super.destroy();
      }
      
      public function set body(value:Sprite) : void
      {
         if(mBody != null && mBody.parent)
         {
            mBody.parent.removeChild(mBody);
         }
         mBody = value;
         mRoot.addChild(mBody);
      }
      
      public function mouseOverHighlight() : void
      {
         addEffect(mMouseOverEffect);
      }
      
      public function mouseOverUnhighlight() : void
      {
         removeEffect(mMouseOverEffect);
      }
      
      public function mouseSelectedHighlight() : void
      {
         addEffect(mMouseSelectedEffect);
      }
      
      public function mouseSelectedUnhighlight() : void
      {
         removeEffect(mMouseSelectedEffect);
      }
      
      public function reviveHighlight() : void
      {
         var _loc1_:ColorTransform = new ColorTransform();
         _loc1_.color = 16777215;
         mBody.transform.colorTransform = _loc1_;
      }
      
      public function reviveUnhighlight() : void
      {
         mBody.transform.colorTransform = new ColorTransform();
      }
      
      private function addEffect(effect:GlowFilter) : void
      {
         if(mBodyFilters.indexOf(effect) < 0)
         {
            mBodyFilters.push(effect);
            mBody.filters = mBodyFilters;
         }
      }
      
      private function removeEffect(effect:GlowFilter) : void
      {
         var _loc2_:int = mBodyFilters.indexOf(effect);
         if(_loc2_ >= 0)
         {
            mBodyFilters.splice(_loc2_,1);
            mBody.filters = mBodyFilters;
         }
      }
      
      protected function playHitEffect(gmAttack:GMAttack, isAttackeeHero:Boolean) : void
      {
         var _loc5_:String = DBFacade.buildFullDownloadPath(gmAttack.HitEffectFilepath);
         var _loc3_:String = mParentActorObject is HeroGameObject ? "db_fx_hitRed" : gmAttack.HitEffect;
         if(isAttackeeHero)
         {
            _loc3_ = gmAttack.HitEffect;
         }
         var _loc4_:Vector3D = new Vector3D(0,mParentActorObject.actorData.gMActor.ProjEmitOffset);
         var _loc6_:Number = 1 / mRoot.scaleX;
         var _loc7_:Number = gmAttack.HitEffectStopRotation ? 0 : Math.random() * 360;
         if(_loc3_)
         {
            mParentActorObject.distributedDungeonFloor.effectManager.playEffect(_loc5_,_loc3_,_loc4_,mParentActorObject,gmAttack.HitEffectBehindAvatar,_loc6_,_loc7_);
         }
      }
      
      protected function playHitEffectToLerpToAttacker(gmAttack:GMAttack, lerpActor:ActorGameObject) : void
      {
         var swfPath:String;
         var hitEffectName:String;
         var lerpedFunc:Function;
         var i:int;
         if(gmAttack.HitEffectToLerpToAttacker)
         {
            swfPath = DBFacade.buildFullDownloadPath(gmAttack.HitEffectLerpFilepath);
            hitEffectName = gmAttack.HitEffectToLerpToAttacker;
            if(hitEffectName)
            {
               lerpedFunc = function():void
               {
                  playLerpedEffect(swfPath,hitEffectName,mParentActorObject,lerpActor,gmAttack.HitEffectToLerpSpeed,gmAttack.HitEffectToLerpGlowColor);
               };
               i = 0;
               while(i < 5)
               {
                  mLogicalWorkComponent.doLater(Math.random() / 100 * i,lerpedFunc);
                  i = i + 1;
               }
            }
         }
      }
      
      protected function playHitEffectToLerpFromAttacker(gmAttack:GMAttack, lerpActor:ActorGameObject) : void
      {
         var swfPath:String;
         var hitEffectName:String;
         var lerpedFunc:Function;
         var i:int;
         if(gmAttack.HitEffectToLerpFromAttacker)
         {
            swfPath = DBFacade.buildFullDownloadPath(gmAttack.HitEffectLerpFilepath);
            hitEffectName = gmAttack.HitEffectToLerpFromAttacker;
            if(hitEffectName)
            {
               lerpedFunc = function():void
               {
                  playLerpedEffect(swfPath,hitEffectName,lerpActor,mParentActorObject,gmAttack.HitEffectToLerpSpeed,gmAttack.HitEffectToLerpGlowColor);
               };
               i = 0;
               while(i < 5)
               {
                  mLogicalWorkComponent.doLater(Math.random() / 100 * i,lerpedFunc);
                  i = i + 1;
               }
            }
         }
      }
      
      private function playLerpedEffect(swfPath:String, className:String, parentObject:FloorObject = null, lerpToActor:ActorGameObject = null, lerpSpeed:Number = 1, lerpGlowColor:uint = 13369344) : void
      {
         var _loc7_:Vector3D = new Vector3D(0,0);
         var _loc8_:Number = 0.5 + Math.random();
         mParentActorObject.distributedDungeonFloor.effectManager.playLerpedEffect(swfPath,className,_loc7_,parentObject,lerpToActor,lerpSpeed,lerpGlowColor,false,_loc8_);
      }
      
      protected function playHealEffect() : void
      {
         var _loc2_:String = DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf");
         var _loc5_:String = "db_fx_heal";
         var _loc1_:Vector3D = mParentActorObject.projectileLaunchOffset;
         var _loc3_:Number = 1 / mRoot.scaleX;
         var _loc4_:Number = 0;
         mParentActorObject.distributedDungeonFloor.effectManager.playEffect(_loc2_,_loc5_,_loc1_,mParentActorObject,false,_loc3_,_loc4_);
      }
      
      private function isThisIdTheOwner(id:uint) : Boolean
      {
         var _loc2_:ActorGameObject = mDBFacade.gameObjectManager.getReferenceFromId(id) as ActorGameObject;
         return _loc2_.isOwner;
      }
      
      private function isThisIdAnOwnersPet(id:uint) : Boolean
      {
         var _loc3_:NPCGameObject = null;
         var _loc2_:ActorGameObject = mDBFacade.gameObjectManager.getReferenceFromId(id) as ActorGameObject;
         if(_loc2_)
         {
            _loc3_ = _loc2_ as NPCGameObject;
            if(_loc3_ == null)
            {
               return false;
            }
            if(_loc3_.masterIsUser())
            {
               return true;
            }
         }
         return false;
      }
      
      private function isThisAProp(id:uint) : Boolean
      {
         var _loc2_:ActorGameObject = mDBFacade.gameObjectManager.getReferenceFromId(id) as ActorGameObject;
         if(_loc2_ && _loc2_.actorData.gMActor.CharType == "PROP")
         {
            return true;
         }
         return false;
      }
      
      private function doesCombatResultInvolveUserOrPetOfUser(combatResult:CombatResult) : Boolean
      {
         if(isThisIdUserOrPetOfUser(combatResult.attacker) || isThisIdUserOrPetOfUser(combatResult.attackee))
         {
            return true;
         }
         return false;
      }
      
      private function doesCombatResultHaveShowHealFlag(combatResult:CombatResult) : Boolean
      {
         var _loc2_:ActorGameObject = mDBFacade.gameObjectManager.getReferenceFromId(combatResult.attackee) as ActorGameObject;
         if(_loc2_.hasShowHealNumbers)
         {
            return true;
         }
         return false;
      }
      
      private function isThisIdUserOrPetOfUser(id:uint) : Boolean
      {
         if(isThisIdTheOwner(id))
         {
            return true;
         }
         return isThisIdAnOwnersPet(id);
      }
      
      public function localCombatHit(combatResult:CombatResult) : void
      {
         var _loc2_:GMAttack = null;
         var _loc3_:ActorGameObject = mDBFacade.gameObjectManager.getReferenceFromId(combatResult.attacker) as ActorGameObject;
         if(!_loc3_)
         {
            return;
         }
         if(_loc3_.isOwner)
         {
            _loc2_ = mDBFacade.gameMaster.attackById.itemFor(combatResult.attack.attackType);
            playHitEffect(_loc2_,_loc3_.isHeroType);
            playHitEffectToLerpToAttacker(_loc2_,_loc3_);
            playHitEffectToLerpFromAttacker(_loc2_,_loc3_);
         }
      }
      
      public function receiveDamage(combatResult:CombatResult, gmAttack:GMAttack) : void
      {
         var impactSound:String;
         var attackerGameObject:ActorGameObject = mDBFacade.gameObjectManager.getReferenceFromId(combatResult.attacker) as ActorGameObject;
         if(attackerGameObject != null)
         {
            if(!attackerGameObject.isOwner)
            {
               playHitEffect(gmAttack,attackerGameObject.isHeroType);
            }
            if(combatResult.damage != 0)
            {
               if(doesCombatResultInvolveUserOrPetOfUser(combatResult) && !isThisAProp(combatResult.attackee))
               {
                  spawnDamageFloater(Boolean(combatResult.criticalHit),combatResult.damage,isThisIdTheOwner(combatResult.attacker),isThisIdTheOwner(combatResult.attackee),combatResult.effectiveness);
               }
            }
            if(mParentActorObject.actorData.hitSound)
            {
               this.mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mParentActorObject.actorData.hitSound,function(param1:SoundAsset):void
               {
                  mSoundComponent.playSfxOneShot(param1,worldCenter,0,mParentActorObject.actorData.hitVolume);
               });
            }
         }
         if(gmAttack && gmAttack.ImpactSound)
         {
            impactSound = gmAttack.ImpactSound;
            if(combatResult.effectiveness < 0)
            {
               impactSound = "WeakAttack";
            }
            else if(combatResult.effectiveness > 0)
            {
               impactSound = "StrongHit";
            }
            this.mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),impactSound,function(param1:SoundAsset):void
            {
               mSoundComponent.playSfxOneShot(param1,worldCenter,0,gmAttack.ImpactVolume);
            });
         }
      }
      
      public function receiveHeal(combatResult:CombatResult, gmAttack:GMAttack) : void
      {
         var _loc3_:Boolean = false;
         if(combatResult.damage != 0)
         {
            if(doesCombatResultInvolveUserOrPetOfUser(combatResult) || doesCombatResultHaveShowHealFlag(combatResult))
            {
               _loc3_ = isThisIdTheOwner(combatResult.attacker) || isThisIdTheOwner(combatResult.attackee);
               spawnHealFloater(combatResult.damage,isThisIdTheOwner(combatResult.attacker),isThisIdTheOwner(combatResult.attackee),combatResult.effectiveness);
            }
         }
      }
      
      public function spawnDamageFloater(isCriticalHit:Boolean, delta:int, attackerIsOwner:Boolean, attackeeIsOwner:Boolean, effectiveness:int, type:uint = 0, floaterType:String = "DAMAGE_MOVEMENT_TYPE") : void
      {
         var _loc8_:DamageFloater = null;
         if(mDBFacade.featureFlags.getFlagValue("want-damage-floaters"))
         {
            _loc8_ = new DamageFloater(mDBFacade,delta,mParentActorObject,0,24,0.9,90,null,attackerIsOwner,attackeeIsOwner,true,isCriticalHit,effectiveness,type,floaterType);
         }
      }
      
      public function spawnHealFloater(delta:int, attackerIsOwner:Boolean, attackeeIsOwner:Boolean, effectiveness:int, type:uint = 0, floaterType:String = "DAMAGE_MOVEMENT_TYPE") : void
      {
         var _loc7_:DamageFloater = null;
         if(mDBFacade.featureFlags.getFlagValue("want-damage-floaters"))
         {
            _loc7_ = new DamageFloater(mDBFacade,delta,mParentActorObject,4,24,0.9,90,null,attackerIsOwner,attackeeIsOwner,true,false,effectiveness,type,floaterType);
         }
      }
      
      public function hasAnimationRenderer() : Boolean
      {
         if(bodyAnimRenderer)
         {
            return true;
         }
         return false;
      }
      
      public function set AFK(value:Boolean) : void
      {
         if(mNametag)
         {
            mNametag.AFK = value;
         }
      }
   }
}

