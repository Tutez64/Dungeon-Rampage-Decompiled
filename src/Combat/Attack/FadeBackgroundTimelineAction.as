package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class FadeBackgroundTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "fadebackground";
      
      private var mDuration:uint;
      
      private var mTransitionDuration:Number;
      
      private var mColor:Vector3D;
      
      private var mOffset:Number;
      
      private var mAlpha:Number;
      
      public function FadeBackgroundTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, duration:uint, color:Vector3D, alpha:Number, transitionDur:Number)
      {
         mDuration = duration;
         mTransitionDuration = transitionDur;
         mColor = new Vector3D(color.x,color.y,color.z);
         mAlpha = alpha;
         mOffset = alpha / transitionDur;
         super(actorGameObject,actorView,dbFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : FadeBackgroundTimelineAction
      {
         var _loc5_:uint = uint(actionObj.duration);
         var _loc6_:Vector3D = new Vector3D(actionObj.color_r,actionObj.color_g,actionObj.color_b);
         var _loc8_:Number = Number(actionObj.alpha);
         var _loc7_:Number = Number(actionObj.transitionDur);
         return new FadeBackgroundTimelineAction(actorGameObject,actorView,dbFacade,_loc5_,_loc6_,_loc8_,_loc7_);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         if(!mActorGameObject.isOwner && !mDBFacade.camera.isPointOnScreen(mActorGameObject.position))
         {
            return;
         }
         super.execute(timeline);
         var _loc2_:Array = [];
         _loc2_.push(mActorView.root);
         mDBFacade.camera.fadeBackground(_loc2_,mDuration,mTransitionDuration,mColor,mAlpha);
      }
      
      override public function stop() : void
      {
         mDBFacade.camera.killBackgroundFader();
      }
   }
}

