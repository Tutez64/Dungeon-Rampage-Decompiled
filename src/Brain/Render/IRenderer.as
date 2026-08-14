package Brain.Render
{
   import flash.display.DisplayObject;
   
   public interface IRenderer
   {
      
      function get rendererType() : String;
      
      function play(startingFrame:uint = 0, loop:Boolean = true, finishedCallback:Function = null) : void;
      
      function stop() : void;
      
      function get currentFrame() : uint;
      
      function get loop() : Boolean;
      
      function setFrame(frameNumber:uint) : void;
      
      function get displayObject() : DisplayObject;
      
      function set heading(value:Number) : void;
      
      function destroy() : void;
      
      function get durationInSeconds() : Number;
      
      function get frameCount() : Number;
      
      function get playRate() : Number;
      
      function set playRate(value:Number) : void;
      
      function get isPlaying() : Boolean;
   }
}

