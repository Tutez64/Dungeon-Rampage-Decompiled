package Effects
{
   import Actor.ActorGameObject;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.Clock.GameClock;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.SceneGraph.SceneGraphManager;
   import Brain.Sound.SoundAsset;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Collections.IMapIterator;
   import Collections.Map;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import Sound.DBSoundComponent;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   public class EffectManager
   {
      
      private static const OUT_OF_MANA_DISPLAY_TIME:Number = 2;
      
      private var mDBFacade:DBFacade;
      
      private var mManagedEffects:Map;
      
      private var mOutstandingEffects:Dictionary = new Dictionary();
      
      private var mSoundComponent:DBSoundComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mNotEnoughManaDisplayTask:Task;
      
      public function EffectManager(facade:DBFacade)
      {
         super();
         mDBFacade = facade;
         mManagedEffects = new Map();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"EffectManager");
         mSoundComponent = new DBSoundComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"EffectManager");
      }
      
      private static function createPooledEffectRelease(effect:EffectGameObject, pool:EffectPool, outstanding:Dictionary) : Function
      {
         var release:Function = function():void
         {
            if(outstanding[effect] !== release)
            {
               return;
            }
            delete outstanding[effect];
            if(!EffectView(effect.view).isArtLoaded)
            {
               effect.destroy();
            }
            else
            {
               pool.checkin(effect);
            }
         };
         outstanding[effect] = release;
         return release;
      }
      
      public function playLerpedEffect(swfPath:String, className:String, positionOffset:Vector3D, parentObject:FloorObject = null, lerpToActor:ActorGameObject = null, lerpSpeed:Number = 1, lerpGlowColor:uint = 13369344, behindAvatar:Boolean = false, scale:Number = 1, rotation:Number = 0, rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0, loop:Boolean = false, layerName:String = "sorted", isManaged:Boolean = false, playRate:Number = 1, assetLoadedCallback:Function = null) : void
      {
         if(parentObject == null || !parentObject.hasPosition)
         {
            return;
         }
         var _loc19_:LerpEffectGameObject = new LerpEffectGameObject(mDBFacade,swfPath,className,playRate,0,assetLoadedCallback,lerpToActor,lerpSpeed,lerpGlowColor);
         MemoryTracker.track(_loc19_,"LerpEffectGameObject \'" + swfPath + ":" + className + "\' - created in EffectManager.playLerpedEffect()","pool");
         _loc19_.view.root.scaleX = _loc19_.view.root.scaleY = _loc19_.view.root.scaleZ = scale;
         _loc19_.position = parentObject.position.add(positionOffset);
         _loc19_.layer = SceneGraphManager.getLayerFromName(layerName);
         _loc19_.view.addToStage();
         EffectView(_loc19_.view).play(true,null);
      }
      
      public function playEffect(swfPath:String, className:String, position:Vector3D, parentObject:FloorObject = null, behindAvatar:Boolean = false, scale:Number = 1, rotation:Number = 0, rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0, loop:Boolean = false, layerName:String = "sorted", isManaged:Boolean = false, playRate:Number = 1, assetLoadedCallback:Function = null, iconInsert:EffectIconInsert = null, fallbackCategory:String = null) : uint
      {
         var _loc18_:EffectGameObject = null;
         var _loc19_:Function = null;
         if(isManaged)
         {
            _loc18_ = new EffectGameObject(mDBFacade,swfPath,className,playRate,0,assetLoadedCallback,iconInsert,fallbackCategory);
            MemoryTracker.track(_loc18_,"EffectGameObject \'" + swfPath + ":" + className + "\' - created in EffectManager.playEffect()","pool");
         }
         else
         {
            _loc18_ = mDBFacade.effectPool.checkout(mDBFacade,swfPath,className,assetLoadedCallback,iconInsert,playRate) as EffectGameObject;
            _loc19_ = createPooledEffectRelease(_loc18_,mDBFacade.effectPool,mOutstandingEffects);
         }
         _loc18_.view.root.scaleX = _loc18_.view.root.scaleY = _loc18_.view.root.scaleZ = scale;
         _loc18_.rotation = rotation;
         _loc18_.view.rotationX = rotationX;
         _loc18_.view.rotationY = rotationY;
         _loc18_.view.rotationZ = rotationZ;
         _loc18_.position = position;
         if(parentObject)
         {
            EffectView(_loc18_.view).attachToParent(parentObject.view.root,behindAvatar);
         }
         else
         {
            _loc18_.layer = SceneGraphManager.getLayerFromName(layerName);
            _loc18_.view.addToStage();
         }
         EffectView(_loc18_.view).play(loop,_loc19_);
         if(isManaged)
         {
            mManagedEffects.add(_loc18_.id,_loc18_);
         }
         return _loc18_.id;
      }
      
      public function playSoundEffect(soundSwfPath:String, soundName:String) : void
      {
         mAssetLoadingComponent.getSoundAsset(soundSwfPath,soundName,function(param1:SoundAsset):void
         {
            mSoundComponent.playSfxOneShot(param1,null);
         });
      }
      
      public function endManagedEffect(effectID:uint) : void
      {
         var _loc2_:EffectGameObject = mManagedEffects.itemFor(effectID);
         if(_loc2_)
         {
            mManagedEffects.remove(_loc2_);
            _loc2_.destroy();
         }
      }
      
      public function managedEffectView(effectID:uint) : EffectView
      {
         var _loc2_:EffectGameObject = mManagedEffects != null ? mManagedEffects.itemFor(effectID) : null;
         return _loc2_ != null ? _loc2_.view as EffectView : null;
      }
      
      public function playNotEnoughManaEffects() : void
      {
         if(mNotEnoughManaDisplayTask == null)
         {
            playSoundEffect(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH),"OutOfMana");
            mDBFacade.hud.showNotEnoughMana();
            mNotEnoughManaDisplayTask = mLogicalWorkComponent.doLater(2,function(param1:GameClock):void
            {
               mNotEnoughManaDisplayTask = null;
               mDBFacade.hud.hideNotEnoughMana();
            });
         }
      }
      
      public function destroy() : void
      {
         var _loc5_:Array = null;
         var _loc4_:IMapIterator = null;
         var _loc3_:EffectGameObject = null;
         if(mOutstandingEffects)
         {
            _loc5_ = [];
            for each(var _loc2_:Function in mOutstandingEffects)
            {
               _loc5_.push(_loc2_);
            }
            for each(var _loc1_:Function in _loc5_)
            {
               _loc1_();
            }
            mOutstandingEffects = null;
         }
         mDBFacade = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mSoundComponent.destroy();
         mSoundComponent = null;
         if(mManagedEffects)
         {
            _loc4_ = mManagedEffects.iterator() as IMapIterator;
            while(_loc4_.hasNext())
            {
               _loc3_ = _loc4_.next();
               _loc3_.destroy();
            }
            mManagedEffects.clear();
            mManagedEffects = null;
         }
         if(mNotEnoughManaDisplayTask)
         {
            mNotEnoughManaDisplayTask.destroy();
            mNotEnoughManaDisplayTask = null;
         }
         if(mSceneGraphComponent)
         {
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
      }
   }
}

