package Brain.Sound
{
   import Brain.Event.EventComponent;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.Set;
   
   public class SoundManager
   {
      
      private static const GLOBAL_VOLUME_DAMPENER:Number = 0.2040816;
      
      private static const DEFAULT_VOLUME:Number = 0.7;
      
      protected var mCategoryVolumeScale:Map;
      
      protected var mEventComponent:EventComponent;
      
      protected var mMaxConcurrentSounds:uint = 20;
      
      protected var mSoundsDictionary:Map;
      
      public function SoundManager(facade:Facade)
      {
         super();
         mCategoryVolumeScale = new Map();
         mSoundsDictionary = new Map();
         mEventComponent = new EventComponent(facade);
      }
      
      public function destroy() : void
      {
         mEventComponent.destroy();
         mEventComponent = null;
         mSoundsDictionary = null;
         mCategoryVolumeScale = null;
      }
      
      public function registerSoundPlaying(soundHandle:SoundHandle) : void
      {
         var _loc2_:Set = null;
         if(mSoundsDictionary.hasKey(soundHandle.category))
         {
            _loc2_ = mSoundsDictionary.itemFor(soundHandle.category) as Set;
            if(_loc2_.has(soundHandle))
            {
               Logger.warn("Trying to register a sound handle that already exists in the set.");
               return;
            }
            _loc2_.add(soundHandle);
         }
         else
         {
            _loc2_ = new Set();
            _loc2_.add(soundHandle);
            mSoundsDictionary.add(soundHandle.category,_loc2_);
         }
      }
      
      public function unregisterSoundPlaying(soundHandle:SoundHandle) : void
      {
         if(!mSoundsDictionary.hasKey(soundHandle.category))
         {
            Logger.error("Tryign to remove soundHandle from a category that does not exist in the dictionary. Category: " + soundHandle.category);
         }
         var _loc2_:Set = mSoundsDictionary.itemFor(soundHandle.category) as Set;
         if(_loc2_.has(soundHandle))
         {
            _loc2_.remove(soundHandle);
         }
         else
         {
            Logger.warn("Trying to remove a soundHandle from a soundCategory that does not have it in the set.");
         }
      }
      
      public function setVolumeScaleForCategory(category:String, volumeScale:Number) : void
      {
         if(mCategoryVolumeScale.hasKey(category))
         {
            mCategoryVolumeScale.replaceFor(category,volumeScale);
         }
         else
         {
            mCategoryVolumeScale.add(category,volumeScale);
         }
         mEventComponent.dispatchEvent(new SoundCategoryVoumeChangedEvent());
      }
      
      public function getDampenedVolumeScaleForCategory(category:String) : Number
      {
         return getVolumeScaleForCategory(category) * getVolumeScaleForCategory(category) * 0.2040816;
      }
      
      public function getVolumeScaleForCategory(category:String) : Number
      {
         if(mCategoryVolumeScale.hasKey(category))
         {
            return mCategoryVolumeScale.itemFor(category);
         }
         Logger.warn("No volume category found for category: " + category + "  Returning " + 0.7);
         return 0.7;
      }
   }
}

