package Brain.Sound
{
   import Brain.Component.Component;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.ISetIterator;
   
   public class SoundComponent extends Component
   {
      
      protected var mSoundHandles:Set;
      
      public function SoundComponent(facade:Facade)
      {
         super(facade);
         mSoundHandles = new Set();
      }
      
      public function playOneShot(soundAsset:SoundAsset, category:String, loopCount:int = 0, volume:Number = 1, panning:Number = 0, startPosition:Number = 0) : void
      {
         var _loc7_:SoundHandle = new SoundHandle(mFacade.soundManager,mFacade,soundAsset.sound,category,null,false,volume,panning);
         MemoryTracker.track(_loc7_,"SoundHandle - one-shot, category: " + category,"brain");
         _loc7_.play(loopCount,startPosition);
      }
      
      public function playManagedSound(soundAsset:SoundAsset, category:String, volume:Number = 1, panning:Number = 0) : SoundHandle
      {
         var soundHandle:SoundHandle = new SoundHandle(mFacade.soundManager,mFacade,soundAsset.sound,category,function(param1:SoundHandle):void
         {
            unregisterSoundHandle(param1);
         },true,volume,panning);
         MemoryTracker.track(soundHandle,"SoundHandle - managed, category: " + category,"brain");
         mSoundHandles.add(soundHandle);
         return soundHandle;
      }
      
      protected function unregisterSoundHandle(soundHandle:SoundHandle) : void
      {
         if(!mSoundHandles.has(soundHandle))
         {
            Logger.warn("Trying to unregister soundHandle which does not exist in SoundComponent\'s set.");
            return;
         }
         mSoundHandles.remove(soundHandle);
      }
      
      override public function destroy() : void
      {
         var _loc1_:SoundHandle = null;
         var _loc2_:ISetIterator = mSoundHandles.iterator() as ISetIterator;
         while(_loc2_.hasNext())
         {
            _loc1_ = _loc2_.next();
            _loc1_.destroy();
         }
         mSoundHandles.clear();
         mSoundHandles = null;
      }
   }
}

