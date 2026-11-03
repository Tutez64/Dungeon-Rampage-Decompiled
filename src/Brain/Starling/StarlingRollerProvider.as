package Brain.Starling
{
   import com.junkbyte.console.view.RollerPanel;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getQualifiedClassName;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.MovieClip;
   import starling.display.Stage;
   
   public class StarlingRollerProvider
   {
      
      private static var sLayerManager:StarlingLayerManager;
      
      public function StarlingRollerProvider()
      {
         super();
      }
      
      public static function install(layerManager:StarlingLayerManager) : void
      {
         sLayerManager = layerManager;
         RollerPanel.customContentProvider = getContent;
      }
      
      public static function uninstall() : void
      {
         if(RollerPanel.customContentProvider == getContent)
         {
            RollerPanel.customContentProvider = null;
         }
         sLayerManager = null;
      }
      
      private static function getContent(mouseX:Number, mouseY:Number, dolink:Boolean) : String
      {
         var _loc7_:int = 0;
         var _loc11_:StarlingLayer = null;
         var _loc8_:int = 0;
         var _loc23_:DisplayObject = null;
         var _loc19_:Rectangle = null;
         var _loc20_:String = null;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc17_:String = null;
         var _loc21_:DisplayObjectContainer = null;
         var _loc10_:int = 0;
         var _loc4_:DisplayObject = null;
         if(sLayerManager == null)
         {
            return "";
         }
         var _loc22_:Stage = sLayerManager.starlingStage;
         var _loc5_:Rectangle = sLayerManager.viewPort;
         if(_loc22_ == null || _loc5_ == null)
         {
            return "";
         }
         var _loc16_:Number = (mouseX - _loc5_.x) / _loc5_.width * _loc22_.stageWidth;
         var _loc15_:Number = (mouseY - _loc5_.y) / _loc5_.height * _loc22_.stageHeight;
         var _loc9_:Point = new Point(_loc16_,_loc15_);
         var _loc18_:Vector.<StarlingLayer> = sLayerManager.layers;
         var _loc12_:String = "";
         var _loc6_:int = 0;
         _loc7_ = 0;
         while(_loc7_ < _loc18_.length)
         {
            _loc11_ = _loc18_[_loc7_];
            _loc8_ = 0;
            while(_loc8_ < _loc11_.numChildren)
            {
               _loc23_ = _loc11_.getChildAt(_loc8_);
               _loc19_ = _loc23_.getBounds(_loc22_);
               if(_loc19_.containsPoint(_loc9_))
               {
                  _loc6_++;
                  _loc20_ = _loc23_.name ? _loc23_.name : "(unnamed)";
                  _loc13_ = _loc23_.x;
                  _loc14_ = _loc23_.y;
                  _loc17_ = _loc23_.alpha.toFixed(1);
                  _loc12_ += "<p2><i> ∟ [" + _loc11_.name + "] \"" + _loc20_ + "\" (" + _loc13_ + "," + _loc14_ + ") a=" + _loc17_ + "</i></p2><br/>";
                  if(_loc23_ is DisplayObjectContainer)
                  {
                     _loc21_ = _loc23_ as DisplayObjectContainer;
                     _loc10_ = 0;
                     while(_loc10_ < _loc21_.numChildren)
                     {
                        _loc4_ = _loc21_.getChildAt(_loc10_);
                        if(_loc4_.visible)
                        {
                           _loc12_ += "<p5> - " + describeChild(_loc4_) + "</p5><br/>";
                        }
                        _loc10_++;
                     }
                  }
               }
               _loc8_++;
            }
            _loc7_++;
         }
         if(_loc6_ == 0)
         {
            return "";
         }
         return "<p9>--- Starling GPU [" + int(_loc16_) + "," + int(_loc15_) + "] ---</p9><br/>" + _loc12_;
      }
      
      private static function describeChild(child:DisplayObject) : String
      {
         var _loc3_:MovieClip = null;
         var _loc2_:Image = null;
         var _loc5_:String = null;
         var _loc4_:String = child.name ? child.name : "(unnamed)";
         if(child is MovieClip)
         {
            _loc3_ = child as MovieClip;
            return "MovieClip \"" + _loc4_ + "\" " + int(_loc3_.width) + "x" + int(_loc3_.height) + " f=" + (_loc3_.currentFrame + 1) + "/" + _loc3_.numFrames;
         }
         if(child is Image)
         {
            _loc2_ = child as Image;
            _loc5_ = "";
            if(_loc2_.texture != null)
            {
               _loc5_ = " tex=" + _loc2_.texture.root.nativeWidth + "x" + _loc2_.texture.root.nativeHeight;
            }
            return "Image \"" + _loc4_ + "\" " + int(_loc2_.width) + "x" + int(_loc2_.height) + _loc5_;
         }
         return shortClassName(child) + " \"" + _loc4_ + "\" " + int(child.width) + "x" + int(child.height);
      }
      
      private static function shortClassName(obj:Object) : String
      {
         var _loc2_:String = getQualifiedClassName(obj);
         var _loc3_:int = _loc2_.lastIndexOf("::");
         return _loc3_ >= 0 ? _loc2_.substr(_loc3_ + 2) : _loc2_;
      }
   }
}

