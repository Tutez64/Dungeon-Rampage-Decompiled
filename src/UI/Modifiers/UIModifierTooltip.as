package UI.Modifiers
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import UI.Inventory.UIWeaponTooltip;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class UIModifierTooltip extends MovieClip
   {
      
      public var mRoot:MovieClip;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mFacade:DBFacade;
      
      private var mAnchor:MovieClip;
      
      public function UIModifierTooltip(facade:DBFacade, parentMC:MovieClip, swfAsset:SwfAsset, title:String, desc:String)
      {
         super();
         mFacade = facade;
         mAnchor = parentMC;
         var _loc6_:Class = swfAsset.getClass("modifier_tooltip");
         mRoot = new _loc6_() as MovieClip;
         mRoot.scaleX = mRoot.scaleY = UIWeaponTooltip.tooltipScale(mRoot.title_description,1.55);
         TextUtil.setText(mRoot.title_label,title.toUpperCase());
         TextUtil.setText(mRoot.title_description,desc);
         mRoot.mouseChildren = false;
         mRoot.mouseEnabled = false;
         mSceneGraphComponent = new SceneGraphComponent(facade,"UIModifierTooltip");
         mSceneGraphComponent.addChild(mRoot,107);
      }
      
      public function show() : void
      {
         if(mRoot == null || mAnchor == null)
         {
            return;
         }
         var _loc1_:Number = mAnchor.getBounds(mAnchor).top;
         var _loc2_:Point = mFacade.designLocalToGlobal(mAnchor,new Point(0,_loc1_));
         mRoot.x = _loc2_.x;
         mRoot.y = _loc2_.y;
         mRoot.visible = true;
      }
      
      public function hide() : void
      {
         if(mRoot != null)
         {
            mRoot.visible = false;
         }
      }
      
      public function destroy() : void
      {
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mRoot = null;
         mAnchor = null;
         mFacade = null;
      }
   }
}

