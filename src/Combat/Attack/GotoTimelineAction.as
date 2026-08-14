package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   
   public class GotoTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "goto";
      
      private var mGotoFrame:int;
      
      private var mGotoFunction:Function;
      
      public function GotoTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object, gotoFunction:Function)
      {
         super(actorGameObject,actorView,dbFacade);
         mGotoFrame = actionObj.gotoFrame;
         mGotoFunction = gotoFunction;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object, gotoFunction:Function) : GotoTimelineAction
      {
         return new GotoTimelineAction(actorGameObject,actorView,dbFacade,actionObj,gotoFunction);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mGotoFunction(mGotoFrame);
      }
   }
}

