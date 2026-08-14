package UI.Modifiers
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.SceneGraph.SceneGraphComponent;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class UIModifierTooltip extends MovieClip
   {
      
      public var mRoot:MovieClip;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      public function UIModifierTooltip(facade:DBFacade, parentMC:MovieClip, swfAsset:SwfAsset, title:String, desc:String)
      {
         super();
         var _loc6_:Class = swfAsset.getClass("modifier_tooltip");
         mRoot = new _loc6_() as MovieClip;
         mRoot.title_label.text = title.toUpperCase();
         mRoot.title_description.text = desc;
         mRoot.mouseChildren = false;
         mRoot.mouseEnabled = false;
         parentMC.addChild(mRoot);
         var _loc7_:Point = parentMC.localToGlobal(new Point());
         mRoot.x = _loc7_.x;
         mRoot.y = _loc7_.y + 20;
         mSceneGraphComponent = new SceneGraphComponent(facade,"UIModifierTooltip");
         mSceneGraphComponent.addChild(mRoot,107);
      }
      
      public function show() : void
      {
         mRoot.visible = true;
      }
      
      public function hide() : void
      {
         mRoot.visible = false;
      }
      
      public function destroy() : void
      {
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mRoot = null;
      }
   }
}

