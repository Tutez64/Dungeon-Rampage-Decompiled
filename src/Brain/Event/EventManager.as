package Brain.Event
{
   import Brain.Facade.Facade;
   import flash.display.Sprite;
   
   public class EventManager extends Sprite
   {
      
      public function EventManager(facade:Facade)
      {
         super();
         facade.addRootDisplayObject(this);
      }
   }
}

