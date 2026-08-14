package Collision
{
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Color;
   import Box2D.Dynamics.b2World;
   import Brain.Clock.GameClock;
   import Brain.Collision.Box2DVisualizer;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.WorkLoop.PreRenderWorkComponent;
   import DistributedObjects.Floor;
   import Facade.DBFacade;
   
   public class DBBox2DVisualizer extends Box2DVisualizer
   {
      
      private static const DEFAULT_LIFETIME:uint = 24;
      
      protected var mDBFacade:DBFacade;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mPreRenderWorkComponent:PreRenderWorkComponent;
      
      private var mFloor:Floor;
      
      private var mHeroCircleAttacks:Vector.<CircleAttackRecord>;
      
      private var mHeroPolyAttacks:Vector.<PolygonShapeRecord>;
      
      private var mRayCasts:Vector.<RayCastDraw>;
      
      private var mPolysToShow:Vector.<PolygonShapeRecord> = new Vector.<PolygonShapeRecord>();
      
      private var mCirclesToShow:Vector.<ShapeRecord> = new Vector.<ShapeRecord>();
      
      private var mAstarGridRects:Vector.<AstarGridRectangleDraw> = new Vector.<AstarGridRectangleDraw>();
      
      private var mAstarGridCircs:Vector.<AstarGridCircleDraw> = new Vector.<AstarGridCircleDraw>();
      
      public function DBBox2DVisualizer(dbFacade:DBFacade, box2dWorld:b2World, wantAllCollisions:Boolean = false, wantCombatCollisions:Boolean = false, wantNavigationCollisions:Boolean = false, wantAStarVisuals:Boolean = false)
      {
         super(box2dWorld,wantAllCollisions,wantCombatCollisions,wantNavigationCollisions,wantAStarVisuals);
         mDBFacade = dbFacade;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"DBBox2DVisualizer");
         mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade,"DBBox2DVisualizer");
         mSceneGraphComponent.addChild(rootSprite,30);
         mPreRenderWorkComponent.doEveryFrame(update);
         mDebugDraw.SetDrawScale(50);
         mHeroCircleAttacks = new Vector.<CircleAttackRecord>();
         mHeroPolyAttacks = new Vector.<PolygonShapeRecord>();
         mAstarGridCircs = new Vector.<AstarGridCircleDraw>();
         mAstarGridRects = new Vector.<AstarGridRectangleDraw>();
         mRayCasts = new Vector.<RayCastDraw>();
      }
      
      override public function update(gameClock:GameClock) : void
      {
         var _loc5_:b2PolygonShape = null;
         var _loc4_:PolygonShapeRecord = null;
         var _loc7_:* = 0;
         var _loc8_:* = 0;
         var _loc9_:b2CircleShape = null;
         var _loc2_:Number = NaN;
         super.update(gameClock);
         if(mWantAllCollisions || mWantCombatCollisions)
         {
            drawCombatCollisions();
         }
         if(mWantAllCollisions || mWantAStarVisuals)
         {
            drawAStarVisuals();
         }
         var _loc3_:Vector.<PolygonShapeRecord> = new Vector.<PolygonShapeRecord>();
         var _loc6_:b2Color = new b2Color(0,0,1);
         _loc7_ = 0;
         while(_loc7_ < mPolysToShow.length)
         {
            _loc4_ = mPolysToShow[_loc7_];
            _loc5_ = _loc4_.mShape as b2PolygonShape;
            mDebugDraw.DrawPolygon(_loc4_.mVerticies,_loc5_.GetVertexCount(),_loc6_);
            _loc4_.mLife--;
            if(_loc4_.mLife > 0)
            {
               _loc3_.push(_loc4_);
            }
            _loc7_++;
         }
         mPolysToShow = _loc3_;
         _loc8_ = 0;
         while(_loc8_ < mCirclesToShow.length)
         {
            _loc9_ = mCirclesToShow[_loc8_].mShape as b2CircleShape;
            _loc2_ = _loc9_.GetRadius();
            mDebugDraw.DrawCircle(mCirclesToShow[_loc8_].mTransform.position,_loc2_,_loc6_);
            _loc8_++;
         }
      }
      
      private function drawCombatCollisions() : void
      {
         var _loc10_:* = 0;
         var _loc9_:CircleAttackRecord = null;
         var _loc14_:b2CircleShape = null;
         var _loc7_:b2Vec2 = null;
         var _loc15_:Number = NaN;
         var _loc8_:b2Vec2 = null;
         var _loc4_:b2Color = null;
         var _loc5_:PolygonShapeRecord = null;
         var _loc6_:b2PolygonShape = null;
         var _loc2_:b2Color = null;
         var _loc3_:RayCastDraw = null;
         var _loc1_:Vector.<CircleAttackRecord> = new Vector.<CircleAttackRecord>();
         _loc10_ = 0;
         while(_loc10_ < mHeroCircleAttacks.length)
         {
            _loc9_ = mHeroCircleAttacks[_loc10_];
            _loc14_ = _loc9_.mCircle;
            _loc14_.GetLocalPosition();
            _loc7_ = b2Math.MulX(_loc9_.mTransform,_loc14_.GetLocalPosition());
            _loc15_ = _loc14_.GetRadius();
            _loc8_ = _loc9_.mTransform.R.col1;
            _loc4_ = new b2Color(1,1,1);
            _loc9_.mlife--;
            if(_loc9_.mlife > 0)
            {
               _loc1_.push(_loc9_);
            }
            mDebugDraw.DrawSolidCircle(_loc7_,_loc15_,_loc8_,_loc4_);
            _loc10_++;
         }
         mHeroCircleAttacks = _loc1_;
         var _loc12_:Vector.<PolygonShapeRecord> = new Vector.<PolygonShapeRecord>();
         _loc10_ = 0;
         while(_loc10_ < mHeroPolyAttacks.length)
         {
            _loc5_ = mHeroPolyAttacks[_loc10_];
            _loc5_.buildVerticies();
            _loc6_ = _loc5_.mShape as b2PolygonShape;
            _loc2_ = new b2Color(1,1,1);
            mDebugDraw.DrawSolidPolygon(_loc5_.mVerticiesAsVector,_loc6_.GetVertexCount(),_loc2_);
            _loc5_.mLife--;
            if(_loc5_.mLife > 0)
            {
               _loc12_.push(_loc5_);
            }
            _loc10_++;
         }
         mHeroPolyAttacks = _loc12_;
         var _loc11_:b2Color = new b2Color(1,0,0);
         var _loc13_:Vector.<RayCastDraw> = new Vector.<RayCastDraw>();
         _loc10_ = 0;
         while(_loc10_ < mRayCasts.length)
         {
            _loc3_ = mRayCasts[_loc10_];
            _loc3_.life--;
            mDebugDraw.DrawSegment(_loc3_.point1,_loc3_.point2,_loc11_);
            if(_loc3_.life > 0)
            {
               _loc13_.push(_loc3_);
            }
            _loc10_++;
         }
         mRayCasts = _loc13_;
      }
      
      private function drawAStarVisuals() : void
      {
         var _loc4_:* = 0;
         var _loc6_:AstarGridCircleDraw = null;
         var _loc7_:b2CircleShape = null;
         var _loc3_:b2Vec2 = null;
         var _loc8_:Number = NaN;
         var _loc9_:b2Vec2 = null;
         var _loc10_:AstarGridRectangleDraw = null;
         var _loc5_:b2PolygonShape = null;
         var _loc2_:Vector.<AstarGridCircleDraw> = new Vector.<AstarGridCircleDraw>();
         _loc4_ = 0;
         while(_loc4_ < mAstarGridCircs.length)
         {
            _loc6_ = mAstarGridCircs[_loc4_];
            _loc7_ = _loc6_.mCircle;
            _loc7_.GetLocalPosition();
            _loc3_ = b2Math.MulX(_loc6_.mTransform,_loc7_.GetLocalPosition());
            _loc8_ = _loc7_.GetRadius();
            _loc9_ = _loc6_.mTransform.R.col1;
            _loc6_.mlife--;
            if(_loc6_.mlife > 0)
            {
               _loc2_.push(_loc6_);
            }
            mDebugDraw.DrawSolidCircle(_loc3_,_loc8_,_loc9_,_loc6_.mColor);
            _loc4_++;
         }
         mAstarGridCircs = _loc2_;
         var _loc1_:Vector.<AstarGridRectangleDraw> = new Vector.<AstarGridRectangleDraw>();
         _loc4_ = 0;
         while(_loc4_ < mAstarGridRects.length)
         {
            _loc10_ = mAstarGridRects[_loc4_];
            _loc5_ = _loc10_.mRectangle;
            _loc10_.mlife--;
            if(_loc10_.mlife > 0)
            {
               _loc1_.push(_loc10_);
            }
            mDebugDraw.DrawSolidPolygon(_loc5_.GetVertices(),_loc5_.GetVertexCount(),_loc10_.mColor);
            _loc4_++;
         }
         mAstarGridRects = _loc1_;
      }
      
      public function reportCircleAttack(transform:b2Transform, circle:b2CircleShape, lifetimeInFrames:uint = 24) : void
      {
         var _loc4_:CircleAttackRecord = new CircleAttackRecord();
         _loc4_.mCircle = circle;
         _loc4_.mTransform = transform;
         _loc4_.mlife = lifetimeInFrames;
         mHeroCircleAttacks.push(_loc4_);
      }
      
      public function reportPolyAttack(transform:b2Transform, poly:b2PolygonShape, lifetimeInFrames:uint = 24) : void
      {
         var _loc4_:PolygonShapeRecord = new PolygonShapeRecord();
         _loc4_.mShape = poly;
         _loc4_.mTransform = transform;
         _loc4_.mLife = lifetimeInFrames;
         _loc4_.buildVerticies();
         mHeroPolyAttacks.push(_loc4_);
      }
      
      public function makeAGridCircle(transform:b2Transform, color:b2Color, lifetimeInFrames:uint = 24) : void
      {
         var _loc4_:AstarGridCircleDraw = new AstarGridCircleDraw();
         _loc4_.mCircle = new b2CircleShape(0.6);
         _loc4_.mTransform = transform;
         _loc4_.mColor = color;
         _loc4_.mlife = lifetimeInFrames;
         mAstarGridCircs.push(_loc4_);
      }
      
      public function makeAGridRectangle(transform:b2Transform, color:b2Color, lifetimeInFrames:uint = 24) : void
      {
         var _loc5_:AstarGridRectangleDraw = new AstarGridRectangleDraw();
         _loc5_.mRectangle = new b2PolygonShape();
         var _loc4_:Array = [];
         _loc4_[0] = new b2Vec2(transform.position.x + 0.5,transform.position.y + 0.5);
         _loc4_[1] = new b2Vec2(transform.position.x + 0.5,transform.position.y - 0.5);
         _loc4_[2] = new b2Vec2(transform.position.x - 0.5,transform.position.y - 0.5);
         _loc4_[3] = new b2Vec2(transform.position.x - 0.5,transform.position.y + 0.5);
         _loc5_.mRectangle.SetAsArray(_loc4_,_loc4_.length);
         _loc5_.mTransform = transform;
         _loc5_.mColor = color;
         _loc5_.mlife = lifetimeInFrames;
         mAstarGridRects.push(_loc5_);
      }
      
      public function reportShape(shape:b2Shape, transform:b2Transform, lifeTimeInFrames:uint = 24) : void
      {
         var _loc4_:PolygonShapeRecord = null;
         var _loc5_:ShapeRecord = null;
         if(shape is b2PolygonShape)
         {
            _loc4_ = new PolygonShapeRecord();
            _loc4_.mLife = lifeTimeInFrames;
            _loc4_.mShape = shape as b2PolygonShape;
            _loc4_.mTransform = transform;
            _loc4_.buildVerticies();
            mPolysToShow.push(_loc4_);
         }
         else if(shape is b2CircleShape)
         {
            _loc5_ = new ShapeRecord();
            _loc5_.mLife = lifeTimeInFrames;
            _loc5_.mShape = shape;
            _loc5_.mTransform = transform;
            mCirclesToShow.push(_loc5_);
         }
         else
         {
            Logger.warn("Shape is neither a b2Polygon nor a b2circle.  Unable to visualize.");
         }
      }
      
      public function reportRayCast(point1:b2Vec2, point2:b2Vec2, lifeTimeInFrames:uint = 24) : void
      {
         var _loc4_:RayCastDraw = new RayCastDraw();
         _loc4_.point1 = point1.Copy();
         _loc4_.point2 = point2.Copy();
         _loc4_.life = lifeTimeInFrames;
         mRayCasts.push(_loc4_);
      }
      
      public function destroy() : void
      {
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mPreRenderWorkComponent.destroy();
         mPreRenderWorkComponent = null;
         mHeroCircleAttacks = null;
         mHeroPolyAttacks = null;
         mRayCasts = null;
         mPolysToShow = null;
         mCirclesToShow = null;
         mAstarGridRects = null;
         mAstarGridCircs = null;
      }
   }
}

import Box2D.Collision.Shapes.b2CircleShape;
import Box2D.Collision.Shapes.b2PolygonShape;
import Box2D.Collision.Shapes.b2Shape;
import Box2D.Common.Math.b2Transform;
import Box2D.Common.Math.b2Vec2;
import Box2D.Common.b2Color;

class CircleAttackRecord
{
   
   public var mTransform:b2Transform;
   
   public var mCircle:b2CircleShape;
   
   public var mlife:uint;
   
   public function CircleAttackRecord()
   {
      super();
   }
}

class AstarGridCircleDraw
{
   
   public static const GRID_RADIUS:Number = 0.6;
   
   public var mTransform:b2Transform;
   
   public var mCircle:b2CircleShape;
   
   public var mColor:b2Color;
   
   public var mlife:uint;
   
   public function AstarGridCircleDraw()
   {
      super();
   }
}

class AstarGridRectangleDraw
{
   
   public var mTransform:b2Transform;
   
   public var mRectangle:b2PolygonShape;
   
   public var mColor:b2Color;
   
   public var mlife:uint;
   
   public function AstarGridRectangleDraw()
   {
      super();
   }
}

class PolygonShapeRecord
{
   
   public var mVerticies:Array;
   
   public var mVerticiesAsVector:Vector.<b2Vec2>;
   
   public var mShape:b2PolygonShape;
   
   public var mTransform:b2Transform;
   
   public var mLife:uint;
   
   public function PolygonShapeRecord()
   {
      super();
   }
   
   public function buildVerticies() : void
   {
      var _loc3_:* = 0;
      var _loc2_:b2Vec2 = null;
      var _loc1_:b2PolygonShape = mShape as b2PolygonShape;
      mVerticies = [];
      mVerticiesAsVector = new Vector.<b2Vec2>();
      _loc3_ = 0;
      while(_loc3_ < _loc1_.GetVertexCount())
      {
         _loc2_ = new b2Vec2(_loc1_.GetVertices()[_loc3_].x,_loc1_.GetVertices()[_loc3_].y);
         _loc2_.Add(mTransform.position);
         mVerticiesAsVector.push(_loc2_);
         mVerticies.push(_loc2_);
         _loc3_++;
      }
   }
}

class ShapeRecord
{
   
   public var mShape:b2Shape;
   
   public var mTransform:b2Transform;
   
   public var mLife:uint;
   
   public function ShapeRecord()
   {
      super();
   }
}

class RayCastDraw
{
   
   public var point1:b2Vec2;
   
   public var point2:b2Vec2;
   
   public var life:uint;
   
   public function RayCastDraw()
   {
      super();
   }
}
