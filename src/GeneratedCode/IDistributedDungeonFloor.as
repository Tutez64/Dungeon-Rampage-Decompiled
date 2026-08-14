package GeneratedCode
{
   import Brain.GameObject.GameObject;
   
   public interface IDistributedDungeonFloor
   {
      
      function setNetworkComponentDistributedDungeonFloor(iface:DistributedDungeonFloorNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function set mapNodeId(val:uint) : void;
      
      function set coliseumTierConstant(val:String) : void;
      
      function tileLibrary(tileLibrary:String) : void;
      
      function tiles(tiles:Vector.<DungeonTileUsage>) : void;
      
      function set baseLining(val:uint) : void;
      
      function set introMovieSwfFilePath(val:String) : void;
      
      function set introMovieAssetClassName(val:String) : void;
      
      function set currentFloorNum(val:uint) : void;
      
      function set activeDungeonModifiers(val:Vector.<DungeonModifier>) : void;
      
      function show_text(textkey:String) : void;
      
      function play_sound(sound:String) : void;
      
      function trigger_camera_zoom(zoom:Number) : void;
      
      function trigger_camera_shake(shakeDuration:Number, shakeStrength:Number, shakeCount:uint) : void;
   }
}

