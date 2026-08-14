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
   import Facade.DBFacade;
   import Floor.FloorObject;
   import Sound.DBSoundComponent;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class EffectManager
   {
      
      private static const OUT_OF_MANA_DISPLAY_TIME:Number = 2;
      
      private var mDBFacade:DBFacade;
      
      private var mManagedEffects:Map;
      
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
      
      public function playLerpedEffect(swfPath:String, className:String, positionOffset:Vector3D, parentObject:FloorObject = null, lerpToActor:ActorGameObject = null, lerpSpeed:Number = 1, lerpGlowColor:uint = 13369344, behindAvatar:Boolean = false, scale:Number = 1, rotation:Number = 0, rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0, loop:Boolean = false, layerName:String = "sorted", isManaged:Boolean = false, playRate:Number = 1, assetLoadedCallback:Function = null) : void
      {
         var _loc19_:LerpEffectGameObject = new LerpEffectGameObject(mDBFacade,swfPath,className,playRate,0,assetLoadedCallback,lerpToActor,lerpSpeed,lerpGlowColor);
         MemoryTracker.track(_loc19_,"LerpEffectGameObject \'" + swfPath + ":" + className + "\' - created in EffectManager.playLerpedEffect()","pool");
         _loc19_.view.root.scaleX = _loc19_.view.root.scaleY = _loc19_.view.root.scaleZ = scale;
         _loc19_.position = parentObject.position.add(positionOffset);
         _loc19_.layer = SceneGraphManager.getLayerFromName(layerName);
         _loc19_.view.addToStage();
      }
      
      public function playEffect(swfPath:String, className:String, position:Vector3D, parentObject:FloorObject = null, behindAvatar:Boolean = false, scale:Number = 1, rotation:Number = 0, rotationX:Number = 0, rotationY:Number = 0, rotationZ:Number = 0, loop:Boolean = false, layerName:String = "sorted", isManaged:Boolean = false, playRate:Number = 1, assetLoadedCallback:Function = null) : uint
      {
         var effectGameObject:EffectGameObject;
         var pool:EffectPool;
         if(isManaged)
         {
            effectGameObject = new EffectGameObject(mDBFacade,swfPath,className,playRate,0,assetLoadedCallback);
            MemoryTracker.track(effectGameObject,"EffectGameObject \'" + swfPath + ":" + className + "\' - created in EffectManager.playEffect()","pool");
         }
         else
         {
            effectGameObject = mDBFacade.effectPool.checkout(mDBFacade,swfPath,className,assetLoadedCallback) as EffectGameObject;
         }
         effectGameObject.view.root.scaleX = effectGameObject.view.root.scaleY = effectGameObject.view.root.scaleZ = scale;
         effectGameObject.rotation = rotation;
         effectGameObject.view.rotationX = rotationX;
         effectGameObject.view.rotationY = rotationY;
         effectGameObject.view.rotationZ = rotationZ;
         effectGameObject.position = position;
         if(parentObject)
         {
            if(behindAvatar)
            {
               parentObject.view.root.addChildAt(effectGameObject.view.root,0);
            }
            else
            {
               parentObject.view.root.addChild(effectGameObject.view.root);
            }
         }
         else
         {
            effectGameObject.layer = SceneGraphManager.getLayerFromName(layerName);
            effectGameObject.view.addToStage();
         }
         pool = mDBFacade.effectPool;
         EffectView(effectGameObject.view).play(loop,function():void
         {
            if(!isManaged)
            {
               pool.checkin(effectGameObject);
            }
         });
         if(isManaged)
         {
            mManagedEffects.add(effectGameObject.id,effectGameObject);
         }
         return effectGameObject.id;
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
      
      public function playNotEnoughManaEffects() : void
      {
         if(mNotEnoughManaDisplayTask == null)
         {
            playSoundEffect(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"OutOfMana");
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
         var _loc2_:IMapIterator = null;
         var _loc1_:EffectGameObject = null;
         mDBFacade = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mSoundComponent.destroy();
         mSoundComponent = null;
         if(mManagedEffects)
         {
            _loc2_ = mManagedEffects.iterator() as IMapIterator;
            while(_loc2_.hasNext())
            {
               _loc1_ = _loc2_.next();
               _loc1_.destroy();
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

