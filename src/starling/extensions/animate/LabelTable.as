package starling.extensions.animate
{
   import flash.display.FrameLabel;
   import flash.utils.Dictionary;
   
   internal class LabelTable
   {
      
      public var frameLabels:Array;
      
      public var numFrames:int;
      
      public var loopStart:int;
      
      private var _ranges:Dictionary = new Dictionary();
      
      private var _labelAtFrame:Vector.<String>;
      
      private var _layers:Array;
      
      public function LabelTable(data:Object)
      {
         var _loc4_:int = 0;
         var _loc6_:FrameLabel = null;
         var _loc7_:int = 0;
         super();
         var _loc2_:Array = data.timeline.layers;
         _layers = _loc2_;
         numFrames = countFrames(_loc2_);
         frameLabels = collectLabels(_loc2_);
         var _loc3_:int = int(frameLabels.length);
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc6_ = frameLabels[_loc4_];
            if(_ranges[_loc6_.name] as LabelRange == null)
            {
               _ranges[_loc6_.name] = new LabelRange(_loc6_.frame,_loc4_);
            }
            _loc4_++;
         }
         for each(var _loc5_:LabelRange in _ranges)
         {
            _loc5_.next = labelAfterFrame(_loc5_.start,_loc5_.index + 1);
            _loc7_ = getFrame(_loc5_.next);
            _loc5_.end = (_loc7_ > _loc5_.start ? _loc7_ : numFrames) - 1;
         }
         loopStart = getFrame("loop");
      }
      
      private static function countFrames(layers:Array) : int
      {
         var _loc7_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc8_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:int = int(layers.length);
         _loc7_ = 0;
         while(_loc7_ < _loc2_)
         {
            _loc4_ = layers[_loc7_].frames as Array;
            _loc5_ = int(_loc4_ ? _loc4_.length : 0);
            _loc6_ = int(_loc5_ ? _loc4_[0].index : 0);
            _loc8_ = 0;
            while(_loc8_ < _loc5_)
            {
               _loc6_ += _loc4_[_loc8_].duration;
               _loc8_++;
            }
            if(_loc6_ > _loc3_)
            {
               _loc3_ = _loc6_;
            }
            _loc7_++;
         }
         return _loc3_ || 1;
      }
      
      private static function collectLabels(layers:Array) : Array
      {
         var _loc6_:int = 0;
         var _loc4_:Array = null;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:Object = null;
         var _loc8_:Array = [];
         var _loc2_:int = int(layers.length);
         _loc6_ = 0;
         while(_loc6_ < _loc2_)
         {
            _loc4_ = layers[_loc6_].frames as Array;
            _loc5_ = int(_loc4_ ? _loc4_.length : 0);
            _loc7_ = 0;
            while(_loc7_ < _loc5_)
            {
               _loc3_ = _loc4_[_loc7_];
               if("name" in _loc3_)
               {
                  _loc8_[_loc8_.length] = new FrameLabel(_loc3_.name,_loc3_.index);
               }
               _loc7_++;
            }
            _loc6_++;
         }
         _loc8_.sortOn("frame",16);
         return _loc8_;
      }
      
      private static function collectKeyframes(layers:Array, start:int, end:int) : Vector.<int>
      {
         var _loc8_:int = 0;
         var _loc6_:Array = null;
         var _loc7_:int = 0;
         var _loc10_:int = 0;
         var _loc9_:int = 0;
         var _loc4_:Vector.<int> = new <int>[start];
         var _loc5_:int = int(layers.length);
         _loc8_ = 0;
         while(_loc8_ < _loc5_)
         {
            _loc6_ = layers[_loc8_].frames as Array;
            _loc7_ = int(_loc6_ ? _loc6_.length : 0);
            _loc10_ = 0;
            while(_loc10_ < _loc7_)
            {
               _loc9_ = int(_loc6_[_loc10_].index);
               if(_loc9_ > start && _loc9_ <= end && _loc4_.indexOf(_loc9_) < 0)
               {
                  _loc4_[_loc4_.length] = _loc9_;
               }
               _loc10_++;
            }
            _loc8_++;
         }
         _loc4_.sort(compareFrames);
         return _loc4_;
      }
      
      private static function compareFrames(a:int, b:int) : Number
      {
         return a - b;
      }
      
      public function getFrame(label:String) : int
      {
         if(label == null)
         {
            return -1;
         }
         var _loc2_:LabelRange = _ranges[label] as LabelRange;
         return _loc2_ ? _loc2_.start : -1;
      }
      
      public function getEnd(label:String) : int
      {
         if(label == null)
         {
            return -1;
         }
         var _loc2_:LabelRange = _ranges[label] as LabelRange;
         return _loc2_ ? _loc2_.end : -1;
      }
      
      public function getKeyframe(label:String, keyIndex:int) : int
      {
         var _loc3_:Vector.<int> = segmentKeyframes(label);
         if(_loc3_ == null)
         {
            return -1;
         }
         if(keyIndex < 0)
         {
            keyIndex = 0;
         }
         if(keyIndex >= _loc3_.length)
         {
            keyIndex = _loc3_.length - 1;
         }
         return _loc3_[keyIndex];
      }
      
      public function getKeyframeIndex(label:String, frame:int) : int
      {
         var _loc3_:Vector.<int> = segmentKeyframes(label);
         if(_loc3_ == null)
         {
            return -1;
         }
         var _loc4_:int = 0;
         while(_loc4_ + 1 < _loc3_.length && _loc3_[_loc4_ + 1] <= frame)
         {
            _loc4_++;
         }
         return _loc4_;
      }
      
      private function segmentKeyframes(label:String) : Vector.<int>
      {
         if(label == null)
         {
            return null;
         }
         var _loc2_:LabelRange = _ranges[label] as LabelRange;
         if(_loc2_ == null)
         {
            return null;
         }
         if(_loc2_.keyframes == null)
         {
            _loc2_.keyframes = collectKeyframes(_layers,_loc2_.start,_loc2_.end);
         }
         return _loc2_.keyframes;
      }
      
      public function getNextLabel(afterLabel:String, currentFrame:int) : String
      {
         var _loc3_:String = afterLabel || labelAt(currentFrame);
         var _loc4_:LabelRange = _loc3_ != null ? _ranges[_loc3_] as LabelRange : null;
         return _loc4_ ? _loc4_.next : labelAfterFrame(-1,0);
      }
      
      public function labelAt(frame:int) : String
      {
         var _loc2_:int = 0;
         if(frameLabels.length == 0)
         {
            return null;
         }
         if(frame < 0 || frame >= numFrames)
         {
            return scanLabelAt(frame);
         }
         if(_labelAtFrame == null)
         {
            _labelAtFrame = new Vector.<String>(numFrames,true);
            _loc2_ = 0;
            while(_loc2_ < numFrames)
            {
               _labelAtFrame[_loc2_] = scanLabelAt(_loc2_);
               _loc2_++;
            }
         }
         return _labelAtFrame[frame];
      }
      
      private function scanLabelAt(frame:int) : String
      {
         var _loc4_:int = 0;
         var _loc5_:FrameLabel = null;
         var _loc3_:int = int(frameLabels.length);
         var _loc2_:* = _loc3_ ? frameLabels[0] : null;
         _loc4_ = 1;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = frameLabels[_loc4_];
            if(_loc5_.frame > frame)
            {
               break;
            }
            _loc2_ = _loc5_;
            _loc4_++;
         }
         return _loc2_ ? _loc2_.name : null;
      }
      
      private function labelAfterFrame(frame:int, fromIndex:int) : String
      {
         var _loc4_:int = 0;
         var _loc5_:FrameLabel = null;
         var _loc3_:int = int(frameLabels.length);
         _loc4_ = fromIndex;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = frameLabels[_loc4_];
            if(_loc5_.frame > frame)
            {
               return _loc5_.name;
            }
            _loc4_++;
         }
         return _loc3_ ? frameLabels[0].name : null;
      }
   }
}

class LabelRange
{
   
   public var start:int;
   
   public var end:int;
   
   public var next:String;
   
   public var index:int;
   
   public var keyframes:Vector.<int>;
   
   public function LabelRange(start:int, index:int)
   {
      super();
      this.start = start;
      this.index = index;
   }
}
