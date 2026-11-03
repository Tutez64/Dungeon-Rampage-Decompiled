package Actor
{
   import Actor.StarlingConvertedOverlay.FloaterStyle;
   import Actor.StarlingConvertedOverlay.StarlingOverlays;
   import Facade.DBFacade;
   import GameMasterDictionary.GMBuffColorType;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   
   public class DamageFloater extends FloatingMessage
   {
      
      private static const FLOAT_HEIGHT:Number = 80;
      
      private static const DEFAULT_SCALE:Number = 1;
      
      private static const SFX_SWF:String = "Resources/Art2D/FX/db_fx_library.swf";
      
      private static const BEST_MC:String = "db_fx_hit_sweet";
      
      private static const BETTER_MC:String = "db_fx_hit_super";
      
      private static const NORMAL_MC:String = "db_fx_hit_bang";
      
      private static const WORSE_MC:String = "db_fx_hit_weak";
      
      private static const WORST_MC:String = "db_fx_hit_fail";
      
      private static const BEST_HEX_VALUE:uint = 16750592;
      
      private static const BETTER_HEX_VALUE:uint = 16737536;
      
      private static const NORMAL_HEX_VALUE:uint = 16777113;
      
      private static const CRITICAL_HEX_VALUE:uint = 16750848;
      
      private static const HEAL_HEX_VALUE:uint = 2293538;
      
      private static const MANA_HEX_VALUE:uint = 9065403;
      
      private static const WORSE_HEX_VALUE:uint = 15029422;
      
      private static const WORST_HEX_VALUE:uint = 11613062;
      
      private static const CRIT_FILTER:GlowFilter = FloaterStyle.CRIT_GLOW;
      
      private static const sStyle:FloaterStyle = new FloaterStyle();
      
      private var mActor:ActorGameObject;
      
      private var mFloaterText:MovieClip;
      
      private var mBmp:Bitmap;
      
      private var mBmpData:BitmapData;
      
      private var mType:uint;
      
      public function DamageFloater(dbFacade:DBFacade, delta:Number, actorGameObject:ActorGameObject, holdDuration:uint, totalDuration:uint, scaleDampening:Number, floatSpeed:Number, finishedCallback:Function, attackerIsOwner:Boolean, attackeeIsOwner:Boolean, blit:Boolean = true, isCriticalHit:Boolean = false, effectiveness:int = 0, inType:uint = 0, movementType:String = "DAMAGE_MOVEMENT_TYPE")
      {
         mActor = actorGameObject;
         mDBFacade = dbFacade;
         mType = inType;
         setup(isCriticalHit,delta,attackerIsOwner,attackeeIsOwner,blit,effectiveness);
         var _loc16_:DisplayObject = blit ? mBmp : mFloaterText;
         super(_loc16_,dbFacade,holdDuration,totalDuration,scaleDampening,floatSpeed,mFloatDirection,finishedCallback,movementType);
         mDBFacade.sceneGraphManager.addChild(mRoot,30);
      }
      
      public static function spawn(dbFacade:DBFacade, delta:Number, actorGameObject:ActorGameObject, holdDuration:uint, totalDuration:uint, scaleDampening:Number, floatSpeed:Number, attackerIsOwner:Boolean, attackeeIsOwner:Boolean, isCriticalHit:Boolean, effectiveness:int, inType:uint, movementType:String) : void
      {
         var _loc14_:DisplayObject = null;
         if(StarlingOverlays.drawsFloaters(dbFacade))
         {
            describe(dbFacade,delta,inType,isCriticalHit,attackerIsOwner,attackeeIsOwner,effectiveness,sStyle);
            _loc14_ = actorGameObject.view.root;
            if(StarlingOverlays.get(dbFacade).spawnFloater(sStyle,_loc14_.x,_loc14_.y - 80,holdDuration,totalDuration,scaleDampening,floatSpeed,movementType == "BUFF_DAMAGE_MOVEMENT_TYPE"))
            {
               if(effectiveness != 0)
               {
                  showEffectivenessFX(actorGameObject,effectiveness);
               }
               return;
            }
         }
         if(dbFacade.hud == null || dbFacade.hud.floaterTextClass == null)
         {
            return;
         }
         new DamageFloater(dbFacade,delta,actorGameObject,holdDuration,totalDuration,scaleDampening,floatSpeed,null,attackerIsOwner,attackeeIsOwner,true,isCriticalHit,effectiveness,inType,movementType);
      }
      
      private static function showEffectivenessFX(actor:ActorGameObject, effectiveness:int) : void
      {
         var _loc7_:String = null;
         if(actor.isHeroType || !actor.effectivenessShown)
         {
            actor.effectivenessShown = true;
            var _loc4_:String = DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf");
            switch(effectiveness - -2)
            {
               case 0:
                  _loc7_ = "db_fx_hit_fail";
                  break;
               case 1:
                  _loc7_ = "db_fx_hit_weak";
                  break;
               case 2:
                  _loc7_ = "db_fx_hit_bang";
                  break;
               case 3:
                  _loc7_ = "db_fx_hit_super";
                  break;
               case 4:
                  _loc7_ = "db_fx_hit_sweet";
            }
            var _loc3_:Vector3D = new Vector3D(actor.view.root.x,actor.view.root.y - 80,0);
            var _loc5_:Number = 1;
            var _loc6_:Number = 0;
            actor.distributedDungeonFloor.effectManager.playEffect(_loc4_,_loc7_,_loc3_,null,false,_loc5_,_loc6_,0,0,0,false,"foreground");
            return;
         }
      }
      
      private static function getEffectivenessTextColor(effectiveness:int) : uint
      {
         switch(effectiveness - -2)
         {
            case 0:
               return 11613062;
            case 1:
               return 15029422;
            case 2:
               return 16777113;
            case 3:
               return 16737536;
            case 4:
               return 16750592;
            default:
               return 16777113;
         }
      }
      
      public static function describe(dbFacade:DBFacade, delta:Number, type:uint, isCriticalHit:Boolean, attackerIsOwner:Boolean, attackeeIsOwner:Boolean, effectiveness:int, style:FloaterStyle) : void
      {
         var _loc10_:* = 0;
         var _loc15_:String = null;
         var _loc13_:GMBuffColorType = null;
         var _loc11_:Number = 1;
         var _loc12_:Number = 1;
         var _loc14_:Number = 0;
         if(delta < 0)
         {
            if(attackerIsOwner || attackeeIsOwner)
            {
               if(attackeeIsOwner)
               {
                  _loc11_ = _loc12_ = 1;
               }
               else
               {
                  _loc11_ = _loc12_ = isCriticalHit ? 1 * 1.8 : 1;
               }
            }
            if(isCriticalHit)
            {
               _loc15_ = delta.toString() + "!";
            }
            else
            {
               _loc15_ = delta.toString();
            }
            if(attackeeIsOwner)
            {
               _loc10_ = 16711680;
               switch(int(type) - 1)
               {
                  case 0:
                     _loc10_ = 65280;
                     break;
                  case 1:
                     _loc10_ = 9065403;
               }
            }
            else
            {
               _loc10_ = uint(isCriticalHit ? 16750848 : getEffectivenessTextColor(effectiveness));
            }
            if(type > 10)
            {
               _loc13_ = dbFacade.gameMaster.buffColorTypeById.itemFor(type);
               _loc10_ = _loc13_.ColorHex;
            }
            _loc14_ = (Math.random() - 0.5) * 0.5;
         }
         else
         {
            _loc15_ = "+" + delta.toString();
            _loc10_ = 9502608;
            if(attackeeIsOwner)
            {
               _loc11_ = _loc12_ = 1 * 1.1;
               _loc10_ = 2293538;
               switch(int(type) - 2)
               {
                  case 0:
                     _loc10_ = 9065403;
               }
            }
         }
         var _loc9_:Number = Math.sqrt(_loc14_ * _loc14_ + 1);
         style.text = _loc15_;
         style.color = _loc10_;
         style.scale = _loc11_;
         style.directionX = _loc14_ / _loc9_;
         style.directionY = -1 / _loc9_;
         style.rotation = Math.atan2(style.directionY,style.directionX) * 180 / 3.141592653589793 + 90;
         style.crit = isCriticalHit;
      }
      
      private function setup(isCriticalHit:Boolean, delta:Number, attackerIsOwner:Boolean, attackeeIsOwner:Boolean, blit:Boolean, effectiveness:int) : void
      {
         var _loc12_:Rectangle = null;
         var _loc7_:Matrix = null;
         mFloaterText = new mDBFacade.hud.floaterTextClass() as MovieClip;
         describe(mDBFacade,delta,mType,isCriticalHit,attackerIsOwner,attackeeIsOwner,effectiveness,sStyle);
         var _loc13_:String = sStyle.text;
         var _loc9_:uint = sStyle.color;
         var _loc10_:Number = sStyle.scale;
         var _loc11_:Number = sStyle.scale;
         mFloatDirection = new Vector3D(sStyle.directionX,sStyle.directionY,0);
         var _loc8_:Number = sStyle.rotation;
         if(effectiveness != 0)
         {
            showEffectivenessFX(mActor,effectiveness);
         }
         mFloaterText.label.text = _loc13_;
         mFloaterText.label.textColor = _loc9_;
         if(isCriticalHit)
         {
            mFloaterText.filters = [CRIT_FILTER];
         }
         if(blit)
         {
            mBmpData = new BitmapData(mFloaterText.width,mFloaterText.height,true,0);
            _loc12_ = mFloaterText.getBounds(mFloaterText);
            _loc7_ = new Matrix();
            _loc7_.translate(-_loc12_.x,-_loc12_.y);
            mBmpData.draw(mFloaterText,_loc7_);
            mBmp = new Bitmap(mBmpData,"auto",true);
            mBmp.scaleX = _loc10_;
            mBmp.scaleY = _loc11_;
            mBmp.x = mActor.view.root.x - mBmp.width * 0.5;
            mBmp.y = mActor.view.root.y - 80;
            mBmp.rotation = _loc8_;
         }
         else
         {
            mFloaterText.scaleX = _loc10_;
            mFloaterText.scaleY = _loc11_;
            mFloaterText.x = mActor.view.root.x + mFloatDirection.x * 100;
            mFloaterText.y = mActor.view.root.y - 80;
            mFloaterText.rotation = _loc8_;
         }
      }
      
      override public function destroy() : void
      {
         if(mActor.view)
         {
            mDBFacade.sceneGraphManager.removeChild(mRoot);
         }
         if(mBmpData)
         {
            mBmpData.dispose();
         }
         mBmpData = null;
         mBmp = null;
         mActor = null;
         mFloaterText = null;
         super.destroy();
      }
   }
}

