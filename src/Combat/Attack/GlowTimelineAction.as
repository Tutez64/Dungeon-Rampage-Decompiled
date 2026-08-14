package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   import com.greensock.TweenMax;
   
   public class GlowTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "glow";
      
      private var mDuration:Number;
      
      private var mGlowColor:String;
      
      private var mBlurX:uint;
      
      private var mBlurY:uint;
      
      private var mGlowStrength:Number;
      
      private var mAlpha:Number;
      
      public function GlowTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, duration:Number, color:String, blurX:uint, blurY:uint, strength:uint, alpha:Number)
      {
         mDuration = duration;
         mGlowColor = color;
         mBlurX = blurX;
         mBlurY = blurY;
         mGlowStrength = strength;
         mAlpha = alpha;
         super(actorGameObject,actorView,dbFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : GlowTimelineAction
      {
         var _loc5_:Number = Number(actionObj.duration);
         var _loc6_:String = actionObj.color;
         var _loc9_:uint = uint(actionObj.blurX);
         var _loc8_:uint = uint(actionObj.blurY);
         var _loc7_:uint = uint(actionObj.strength);
         var _loc10_:Number = Number(actionObj.alpha);
         return new GlowTimelineAction(actorGameObject,actorView,dbFacade,_loc5_,_loc6_,_loc9_,_loc8_,_loc7_,_loc10_);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         TweenMax.to(mActorView.body,mDuration,{"glowFilter":{
            "color":mGlowColor,
            "blurX":mBlurX,
            "blurY":mBlurY,
            "strength":mGlowStrength,
            "alpha":mAlpha,
            "quality":3,
            "remove":true
         }});
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
   }
}

