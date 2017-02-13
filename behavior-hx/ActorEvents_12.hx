package scripts;

import com.stencyl.graphics.G;
import com.stencyl.graphics.BitmapWrapper;

import com.stencyl.behavior.Script;
import com.stencyl.behavior.Script.*;
import com.stencyl.behavior.ActorScript;
import com.stencyl.behavior.SceneScript;
import com.stencyl.behavior.TimedTask;

import com.stencyl.models.Actor;
import com.stencyl.models.GameModel;
import com.stencyl.models.actor.Animation;
import com.stencyl.models.actor.ActorType;
import com.stencyl.models.actor.Collision;
import com.stencyl.models.actor.Group;
import com.stencyl.models.Scene;
import com.stencyl.models.Sound;
import com.stencyl.models.Region;
import com.stencyl.models.Font;
import com.stencyl.models.Joystick;

import com.stencyl.Engine;
import com.stencyl.Input;
import com.stencyl.Key;
import com.stencyl.utils.Utils;

import openfl.ui.Mouse;
import openfl.display.Graphics;
import openfl.display.BlendMode;
import openfl.display.BitmapData;
import openfl.display.Bitmap;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.TouchEvent;
import openfl.net.URLLoader;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import box2D.dynamics.B2Fixture;
import box2D.dynamics.joints.B2Joint;

import motion.Actuate;
import motion.easing.Back;
import motion.easing.Cubic;
import motion.easing.Elastic;
import motion.easing.Expo;
import motion.easing.Linear;
import motion.easing.Quad;
import motion.easing.Quart;
import motion.easing.Quint;
import motion.easing.Sine;

import com.stencyl.graphics.shaders.BasicShader;
import com.stencyl.graphics.shaders.GrayscaleShader;
import com.stencyl.graphics.shaders.SepiaShader;
import com.stencyl.graphics.shaders.InvertShader;
import com.stencyl.graphics.shaders.GrainShader;
import com.stencyl.graphics.shaders.ExternalShader;
import com.stencyl.graphics.shaders.InlineShader;
import com.stencyl.graphics.shaders.BlurShader;
import com.stencyl.graphics.shaders.SharpenShader;
import com.stencyl.graphics.shaders.ScanlineShader;
import com.stencyl.graphics.shaders.CSBShader;
import com.stencyl.graphics.shaders.HueShader;
import com.stencyl.graphics.shaders.TintShader;
import com.stencyl.graphics.shaders.BloomShader;



class ActorEvents_12 extends ActorScript
{
	public var _Xposition:Float;
	public var _MoveSpeed:Float;
	public var _EnemyHealth:Float;
	public var _RandomNumber:Float;
	public var _CanShoot:Bool;
	public var _BulletSpeed:Float;
	public var _PushBack:Float;
	public var _OnGround:Bool;
	public var _BulletCooldown:Float;
	public var _Player:Actor;
	public var _Alive:Bool;
	public var _Damage:Float;
	
	/* ========================= Custom Event ========================= */
	public function _customEvent_Hit():Void
	{
		_EnemyHealth -= _Damage;
		propertyChanged("_EnemyHealth", _EnemyHealth);
		actor.setFilter([createBrightnessFilter(100)]);
		runLater(1000 * .05, function(timeTask:TimedTask):Void
		{
			actor.clearFilters();
		}, actor);
	}
	
	
	public function new(dummy:Int, actor:Actor, dummy2:Engine)
	{
		super(actor);
		nameMap.set("Xposition", "_Xposition");
		_Xposition = 0.0;
		nameMap.set("MoveSpeed", "_MoveSpeed");
		_MoveSpeed = 10.0;
		nameMap.set("EnemyHealth", "_EnemyHealth");
		_EnemyHealth = 3.0;
		nameMap.set("RandomNumber", "_RandomNumber");
		_RandomNumber = 0.0;
		nameMap.set("CanShoot", "_CanShoot");
		_CanShoot = true;
		nameMap.set("BulletSpeed", "_BulletSpeed");
		_BulletSpeed = 35.0;
		nameMap.set("PushBack", "_PushBack");
		_PushBack = 3.0;
		nameMap.set("OnGround", "_OnGround");
		_OnGround = false;
		nameMap.set("BulletCooldown", "_BulletCooldown");
		_BulletCooldown = 0.08;
		nameMap.set("Player", "_Player");
		nameMap.set("Alive", "_Alive");
		_Alive = true;
		nameMap.set("Damage", "_Damage");
		_Damage = 0.0;
		
	}
	
	override public function init()
	{
		
		/* ======================== When Creating ========================= */
		actor.makeAlwaysSimulate();
		_Xposition = asNumber((getScreenWidth() - 50));
		propertyChanged("_Xposition", _Xposition);
		_Alive = true;
		propertyChanged("_Alive", _Alive);
		
		/* ======================== When Updating ========================= */
		addWhenUpdatedListener(null, function(elapsedTime:Float, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled)
			{
				if((actor.getX() > _Xposition))
				{
					actor.push(-1, 0, _MoveSpeed);
				}
				if((actor.getX() < _Xposition))
				{
					actor.push(1, 0, _MoveSpeed);
				}
				if((actor.getX() == _Xposition))
				{
					actor.setXVelocity(0);
				}
				actor.bringToFront();
			}
		});
		
		/* ======================== When Updating ========================= */
		addWhenUpdatedListener(null, function(elapsedTime:Float, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled)
			{
				if((_EnemyHealth <= 0))
				{
					_Alive = false;
					propertyChanged("_Alive", _Alive);
					actor.setIgnoreGravity(!true);
					actor.enableRotation();
					actor.applyImpulseInDirection(randomInt(Math.floor(250), Math.floor(290)), randomInt(Math.floor(20), Math.floor(25)));
					_RandomNumber = asNumber(randomInt(Math.floor(1), Math.floor(2)));
					propertyChanged("_RandomNumber", _RandomNumber);
					if((_RandomNumber == 1))
					{
						createRecycledActor(getActorType(16), actor.getXCenter(), actor.getYCenter(), Script.BACK);
						actor.setAngularVelocity(Utils.RAD * (randomInt(Math.floor(360), Math.floor(720))));
					}
					else if((_RandomNumber == 2))
					{
						createRecycledActor(getActorType(16), actor.getXCenter(), actor.getYCenter(), Script.BACK);
						actor.setAngularVelocity(Utils.RAD * (randomInt(Math.floor(-360), Math.floor(-720))));
					}
					actor.applyImpulseInDirection(randomInt(Math.floor(250), Math.floor(290)), 1);
					actor.killSelfAfterLeavingScreen();
					Engine.engine.setGameAttribute("Score", (Engine.engine.getGameAttribute("Score") + 100));
					runPeriodically(1000 * .01, function(timeTask:TimedTask):Void
					{
						createRecycledActor(getActorType(16), actor.getXCenter(), actor.getYCenter(), Script.BACK);
					}, actor);
				}
			}
		});
		
		/* ========================= When Drawing ========================= */
		addWhenDrawingListener(null, function(g:G, x:Float, y:Float, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled)
			{
				g.setFont(getFont(11));
				g.drawString("" + actor.getLastCollidedActor().getValue("ActorEvents_9", "_Damage"), 0, 0);
			}
		});
		
		/* ======================== When Updating ========================= */
		addWhenUpdatedListener(null, function(elapsedTime:Float, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled)
			{
				if((_CanShoot && _Alive))
				{
					_CanShoot = false;
					propertyChanged("_CanShoot", _CanShoot);
					runLater(1000 * randomInt(Math.floor(3), Math.floor(6)), function(timeTask:TimedTask):Void
					{
						if(_Alive)
						{
							createRecycledActor(getActorType(14), (actor.getXCenter() - 10), actor.getYCenter(), Script.FRONT);
							actor.setAnimation("" + "Shoot");
							getLastCreatedActor().setVelocity(Utils.DEG * (Math.atan2((Engine.engine.getGameAttribute("PlayerY") - actor.getYCenter()), (Engine.engine.getGameAttribute("PlayerX") - actor.getXCenter()))), 40);
							_CanShoot = true;
							propertyChanged("_CanShoot", _CanShoot);
							runLater(1000 * .4, function(timeTask:TimedTask):Void
							{
								actor.setAnimation("" + "Idle");
							}, actor);
						}
					}, actor);
				}
			}
		});
		
		/* ======================== When Updating ========================= */
		addWhenUpdatedListener(null, function(elapsedTime:Float, list:Array<Dynamic>):Void
		{
			if(wrapper.enabled)
			{
				if(_Alive)
				{
					actor.setAngle(Utils.RAD * (Utils.DEG * (Math.atan2((Engine.engine.getGameAttribute("PlayerY") - actor.getYCenter()), (Engine.engine.getGameAttribute("PlayerX") - actor.getXCenter())))));
				}
				else
				{
					disableThisBehavior();
				}
			}
		});
		
	}
	
	override public function forwardMessage(msg:String)
	{
		
	}
}