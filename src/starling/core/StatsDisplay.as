package starling.core
{
   import flash.geom.Rectangle;
   import flash.system.System;
   import starling.display.DisplayObject;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.events.EnterFrameEvent;
   import starling.rendering.Painter;
   import starling.styles.MeshStyle;
   import starling.text.TextField;
   
   internal class StatsDisplay extends Sprite
   {
      
      private static const UPDATE_INTERVAL:Number = 0.5;
      
      private static const B_TO_MB:Number = 9.5367431640625e-7;
      
      private var _background:Quad;
      
      private var _labels:TextField;
      
      private var _values:TextField;
      
      private var _frameCount:int = 0;
      
      private var _totalTime:Number = 0;
      
      private var _fps:Number = 0;
      
      private var _memory:Number = 0;
      
      private var _gpuMemory:Number = 0;
      
      private var _drawCount:int = 0;
      
      private var _skipCount:int = 0;
      
      private var _showSkipped:Boolean = false;
      
      public function StatsDisplay()
      {
         var _loc1_:String = null;
         _loc1_ = "mini";
         var _loc3_:Number = NaN;
         _loc3_ = -1;
         var _loc4_:* = 0;
         _loc4_ = 16777215;
         var _loc2_:Number = NaN;
         _loc2_ = 90;
         var _loc5_:Number = NaN;
         _loc5_ = 45;
         super();
         _labels = new TextField(90,45);
         _labels.format.setTo("mini",-1,16777215,"left","top");
         _labels.batchable = true;
         _labels.x = 2;
         _values = new TextField(90 - 1,45,"");
         _values.format.setTo("mini",-1,16777215,"right","top");
         _values.batchable = true;
         _background = new Quad(90,45,0);
         updateLabels();
         if(_background.style.type != MeshStyle)
         {
            _background.style = new MeshStyle();
         }
         if(_labels.style.type != MeshStyle)
         {
            _labels.style = new MeshStyle();
         }
         if(_values.style.type != MeshStyle)
         {
            _values.style = new MeshStyle();
         }
         addChild(_background);
         addChild(_labels);
         addChild(_values);
         addEventListener("addedToStage",onAddedToStage);
         addEventListener("removedFromStage",onRemovedFromStage);
      }
      
      private function onAddedToStage() : void
      {
         addEventListener("enterFrame",onEnterFrame);
         Starling.current.addEventListener("skipFrame",onSkipFrame);
         _totalTime = _frameCount = _skipCount = 0;
         update();
      }
      
      private function onRemovedFromStage() : void
      {
         removeEventListener("enterFrame",onEnterFrame);
         Starling.current.removeEventListener("skipFrame",onSkipFrame);
      }
      
      private function onEnterFrame(event:EnterFrameEvent) : void
      {
         _totalTime += event.passedTime;
         _frameCount = _frameCount + 1;
         if(_totalTime > 0.5)
         {
            update();
            _frameCount = _skipCount = _totalTime = 0;
         }
      }
      
      private function onSkipFrame() : void
      {
         _skipCount += 1;
      }
      
      public function update() : void
      {
         _background.color = _skipCount > _frameCount / 2 ? 16128 : 0;
         _fps = _totalTime > 0 ? _frameCount / _totalTime : 0;
         _memory = System.totalMemory * 9.5367431640625e-7;
         _gpuMemory = supportsGpuMem ? Starling.context["totalGPUMemory"] * 9.5367431640625e-7 : -1;
         var _loc5_:Number = _totalTime > 0 ? _skipCount / _totalTime : 0;
         var _loc6_:String = _showSkipped ? _loc5_.toFixed(_loc5_ < 100 ? 1 : 0) : "";
         var _loc1_:String = _fps.toFixed(_fps < 100 ? 1 : 0);
         var _loc3_:String = _memory.toFixed(_memory < 100 ? 1 : 0);
         var _loc2_:String = _gpuMemory.toFixed(_gpuMemory < 100 ? 1 : 0);
         var _loc4_:String = (_totalTime > 0 ? _drawCount - 2 : _drawCount).toString();
         _values.text = _loc1_ + "\n" + (_showSkipped ? _loc6_ + "\n" : "") + _loc3_ + "\n" + (_gpuMemory >= 0 ? _loc2_ + "\n" : "") + _loc4_;
      }
      
      private function updateLabels() : void
      {
         var _loc1_:Array = ["frames/sec:"];
         if(_showSkipped)
         {
            _loc1_.insertAt(_loc1_.length,"skipped/sec:");
         }
         _loc1_.insertAt(_loc1_.length,"std memory:");
         if(supportsGpuMem)
         {
            _loc1_.insertAt(_loc1_.length,"gpu memory:");
         }
         _loc1_.insertAt(_loc1_.length,"draw calls:");
         _labels.text = _loc1_.join("\n");
         _background.height = _labels.textBounds.height + 4;
      }
      
      override public function render(painter:Painter) : void
      {
         painter.excludeFromCache(this);
         painter.finishMeshBatch();
         super.render(painter);
      }
      
      override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle
      {
         return _background.getBounds(targetSpace,out);
      }
      
      private function get supportsGpuMem() : Boolean
      {
         return "totalGPUMemory" in Starling.context;
      }
      
      public function get drawCount() : int
      {
         return _drawCount;
      }
      
      public function set drawCount(value:int) : void
      {
         _drawCount = value;
      }
      
      public function get fps() : Number
      {
         return _fps;
      }
      
      public function set fps(value:Number) : void
      {
         _fps = value;
      }
      
      public function get memory() : Number
      {
         return _memory;
      }
      
      public function set memory(value:Number) : void
      {
         _memory = value;
      }
      
      public function get gpuMemory() : Number
      {
         return _gpuMemory;
      }
      
      public function set gpuMemory(value:Number) : void
      {
         _gpuMemory = value;
      }
      
      public function get showSkipped() : Boolean
      {
         return _showSkipped;
      }
      
      public function set showSkipped(value:Boolean) : void
      {
         _showSkipped = value;
         updateLabels();
         update();
      }
   }
}

