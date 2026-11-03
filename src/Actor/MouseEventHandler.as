package Actor
{
   import Actor.Player.HeroOwnerView;
   import Actor.Player.Input.DBMouseEvents.MouseDownOnActorEvent;
   import Actor.Player.Input.DBMouseEvents.MouseOutOnActorEvent;
   import Actor.Player.Input.DBMouseEvents.MouseOverOnActorEvent;
   import Actor.Player.Input.DBMouseEvents.MouseUpOnActorEvent;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Facade.DBFacade;
   import Floor.FloorView;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class MouseEventHandler
   {
      
      private var mDBFacade:DBFacade;
      
      private var mActorGameObject:ActorGameObject;
      
      private var mEventComponent:EventComponent;
      
      private var mWantsClicks:Boolean;
      
      public function MouseEventHandler(actorGameObject:ActorGameObject, dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mActorGameObject = actorGameObject;
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      public function destroy() : void
      {
         removeListeners();
         mEventComponent.destroy();
         mEventComponent = null;
         mDBFacade = null;
         mActorGameObject = null;
      }
      
      public function Init() : void
      {
         addListeners();
      }
      
      public function get actorView() : ActorView
      {
         return mActorGameObject.actorView;
      }
      
      public function get floorView() : FloorView
      {
         return mActorGameObject.view;
      }
      
      public function get heroOwnerView() : HeroOwnerView
      {
         return mActorGameObject.actorView as HeroOwnerView;
      }
      
      private function addListeners() : void
      {
         ActorMousePicker.unregister(this);
         mEventComponent.removeAllListeners();
         mActorGameObject.view.root.mouseEnabled = false;
         if(!mActorGameObject.isAttackable || mActorGameObject.isPet)
         {
            return;
         }
         if(mActorGameObject.navCollisions.length == 0)
         {
            return;
         }
         if(mActorGameObject.isHeroType && !mActorGameObject.isOwner)
         {
            return;
         }
         if(heroOwnerView && !heroOwnerView.wantMouseEnabled)
         {
            return;
         }
         mActorGameObject.view.root.mouseChildren = false;
         actorView.mousePickedCentrally = true;
         mWantsClicks = !mActorGameObject.isHeroType;
         ActorMousePicker.register(this,mDBFacade);
         EventListeners.add(actorView.root,"rollOver",onMouseOver);
         EventListeners.add(actorView.root,"rollOut",onMouseOut);
         if(mWantsClicks)
         {
            EventListeners.add(actorView.root,"mouseDown",onMouseDown);
            EventListeners.add(actorView.root,"mouseUp",onMouseUp);
         }
      }
      
      public function get wantsClicks() : Boolean
      {
         return mWantsClicks;
      }
      
      public function get actorId() : uint
      {
         return mActorGameObject ? mActorGameObject.id : 0;
      }
      
      private function removeListeners() : void
      {
         ActorMousePicker.unregister(this);
         mEventComponent.removeAllListeners();
         EventListeners.remove(actorView.root,"rollOver",onMouseOver);
         EventListeners.remove(actorView.root,"rollOut",onMouseOut);
         EventListeners.remove(actorView.root,"mouseDown",onMouseDown);
         EventListeners.remove(actorView.root,"mouseUp",onMouseUp);
      }
      
      public function onMouseOver(event:MouseEvent) : void
      {
         mEventComponent.dispatchEvent(new MouseOverOnActorEvent(mActorGameObject));
      }
      
      public function onMouseOut(event:MouseEvent) : void
      {
         mEventComponent.dispatchEvent(new MouseOutOnActorEvent(mActorGameObject));
      }
      
      public function onMouseDown(event:MouseEvent) : void
      {
         mEventComponent.dispatchEvent(new MouseDownOnActorEvent(mActorGameObject));
      }
      
      public function onMouseUp(event:MouseEvent) : void
      {
         mEventComponent.dispatchEvent(new MouseUpOnActorEvent(mActorGameObject));
      }
      
      public function sendGotHitEvent() : void
      {
         mEventComponent.dispatchEvent(new Event("GotHit_" + mActorGameObject.id));
      }
   }
}

