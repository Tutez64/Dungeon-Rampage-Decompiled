package Events
{
   public class ExperienceEvent extends GameObjectEvent
   {
      
      public static const EXPERIENCE_UPDATE:String = "ExperienceEvent_EXPERIENCE_UPDATE";
      
      public var experience:uint;
      
      public function ExperienceEvent(experienceEventType:String, id:uint, experience:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.experience = experience;
         super(experienceEventType,id,bubbles,cancelable);
      }
   }
}

