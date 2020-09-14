package gui;

import kha.math.FastVector2;
import kha.Color;
import plume.graphics.NinePatch;
import plume.graphics.text.Text;
import plume.input.Mouse;
import kha.input.KeyCode;
import plume.input.Keyboard;
import plume.input.Swipe;
import plume.input.Touch;
import plume.input.TouchData;

import utils.statics.funcs.FuncA;

class UX
{
	public var on:Bool = true; 
	public var text3D:Text3D;
	public var visited = false;
	public var resized = false;
	public var themable:Bool;

	public var pos:FastVector2;
	public var offset:FastVector2;

	public var inputOffsetX:Float = 0.0;
	public var inputOffsetY:Float = 0.0;
	
	public var func:Void->Void;
	public var funcA:Array<Void->Void>;
	public var funcMax:Null<Int>;
	public var funcMin:Null<Int>; 
	public var funcVars:Null<Array<Int>>;

	public var hotKey:KeyCode;

	public var inputWidth:Int;
	public var inputHeight:Int;

	inline public function new(text3DTmp:Text3D,
	?funcTmp:Void->Void,?funcATmp:Array<Void->Void>, 
	?funcMinTmp:Int = null, ?funcMaxTmp:Int = null, ?funcVarsTmp:Array<Int> = null,
	?downColorTmp = Color.Orange, ?overColorTmp = Color.Yellow, 
	?onColorTmp = Color.White, ?visitColorTmp:Color, 
	?ninePatchTmp:NinePatch, ?themeTmp:Array<Color>,
	?hotKeyTmp:KeyCode, ?themableTmp:Bool = true):Void 
	{
		themable = themableTmp;
		
		if(hotKeyTmp != null){hotKey = hotKeyTmp;}
	
		funcA = funcATmp;
		funcMax = funcMaxTmp;
		funcMin = funcMinTmp;
		funcMin = funcMinTmp;
		funcVars = funcVarsTmp;

		hotKey = hotKeyTmp;
		
	//x,y 
		pos = new FastVector2(0, 0);
		offset = new FastVector2(0, 0);
	
		if(ninePatchTmp != null)
		{
			SetupNinePatch(ninePatchTmp);
			ResizeNinePatch();
		}
		else
		{	
			calcTextInput();		
			calcOffset();
		}
	}
	
	inline public function update():Void
	{
		if(on)
		if(Mouse.get().inRect(pos.x + offset.x - inputOffsetX, pos.y + offset.y
		 - inputOffsetY, inputWidth, inputHeight)|| 
		Keyboard.get().isDown(hotKey))
		{
			if(Mouse.get().isPressed() || Keyboard.get().isPressed(hotKey))
			{	
				if(curColor != downColor)
				{
					curColor = downColor;
					//untyped if(npDownColor != untyped Any) { npCurColor = npDownColor; }
				}

				if(!visited)
				{
					visited = true;
					onColor = visitColor;
					
					#if themable
						if(npOnColor != null) { npOnColor = npVisitColor; } 
					#end
				}

				if(func != null) { func(); }
				else
				{
					if(funcA != null)
					{
						if(funcMin != null)
						{
							if(funcMax != null)
							{
								FuncA.Range(funcA, funcMax, funcMin);
							}
							else
							{
								FuncA.Min(funcA,funcMin);
							}
						}
						else
						{
							if(funcVars != null)
							{
								FuncA.Vars(funcA, funcVars);
							}
							else
							{	
								FuncA.All(funcA);
							}
						}
					}
				}
			}
			else
			{
				if(curColor != overColor)
				{
					curColor = overColor;
					#if themable
					if(themable) { if(npOverColor != null) { npCurColor = npOverColor; } }
					#end
				}
			}
		}
		else
		{
			if(curColor != onColor)
			{
				curColor = onColor;
				#if themable
					if(npCurColor != null) { npCurColor = npOnColor; }
					//npCurColor = 0xfff0efeb;
				#end
			}
		}
	}

	inline public function setTheme(?themeTmp:Array<Color>,  
	?ninePatchTmp:NinePatch, ?fontTmp:kha.Font, ?fontSizeTmp:Int, ?textStrTmp:String):Void
	{
		if(themeTmp != null)
		{
			themable = true;
			npOnColor = themeTmp[0]; npCurColor = npOnColor;
			if(themeTmp.length > 1) { npOverColor = themeTmp[1]; }
			if(themeTmp.length > 2) { npDownColor = themeTmp[2]; }
			if(themeTmp.length > 3) { npVisitColor = themeTmp[3]; }
			else { npVisitColor = npOnColor; }

			if(themeTmp.length > 5) { onColor = themeTmp[4]; }
			if(themeTmp.length > 6) { overColor = themeTmp[5]; }
			if(themeTmp.length > 7) { downColor = themeTmp[6]; }
			if(themeTmp.length > 8) { visitColor = themeTmp[7]; }

			if(themeTmp.length > 9) { text3D.depthColor = themeTmp[8]; }
			if(themeTmp.length > 10) { text3D.shadColor = themeTmp[9]; }

			else{visitColor = onColor;}
		}

		if(textStrTmp != null || ninePatchTmp != null || fontTmp != null || fontSizeTmp != null)
		{		
			if(textStrTmp != null) { text3D.text.set_text(textStrTmp); }
			if(fontTmp != null) { text3D.text.font = fontTmp; }
			if(fontSizeTmp != null) { text3D.text.fontSize = fontSizeTmp; }
			text3D.update();

			if(ninePatchTmp != null) { resized = false; SetupNinePatch(ninePatchTmp); }
			else
			{
				if(!resized) //fix ninePatch corruption on initial resize
				{
					ninePatch.region.sx += .25; //.25: ??? 2/8,  border / allborders?
					npX += 1; //1 ??? 2/2, border / border?
					resized = true;
				}
			}
			ResizeNinePatch();	
		}
	}

	inline public function getTheme_AkhaColor(?nTmp:Int = 10):Array<Color>
	{
		var themeTmp:Array<Color> = new Array();
		
		//to-do: optimize
		themeTmp.push(npOnColor);
		if(nTmp > 0) {themeTmp.push(npOverColor); }
		if(nTmp > 1) {themeTmp.push(npDownColor); }
		if(nTmp > 2) {themeTmp.push(npVisitColor); }

		if(nTmp > 3) { themeTmp.push(onColor); }
		if(nTmp > 4) { themeTmp.push(overColor); }
		if(nTmp > 5) { themeTmp.push(downColor); }
		if(nTmp > 6) { themeTmp.push(visitColor); }
		
		if(nTmp > 7) { themeTmp.push(text3D.depthColor); }
		if(nTmp > 8) { themeTmp.push(text3D.shadColor); }

		return themeTmp;
	}

	inline public function SetupNinePatch(ninePatchTmp):Void
	{
			ninePatch = ninePatchTmp;

			npWidthMargin = ninePatch.width;
			npHeightMargin = ninePatch.height;
	}

	inline public function calcOffset():Void
	{
		if(text3D.text.align == plume.graphics.text.TextAlign.Center)
		{
			offset.x = (text3D.text.boxWidth / 2) - text3D.text.getLineWidth() / 2;
		}
		else
		{
			if(text3D.text.align == plume.graphics.text.TextAlign.Right)
			{
				offset.x = text3D.text.boxWidth - text3D.text.getLineWidth();
			}
		}
		offset.y = 0 - text3D.text.lineSpacing / 2;
	}

	inline public function calcTextInput():Void
	{
		inputWidth = text3D.text.getLineWidth();
		inputHeight = text3D.text.boxHeight;
	}

	inline public function ResizeNinePatch():Void
	{
		calcOffset();
		ninePatch.width = text3D.text.getLineWidth() + npWidthMargin;
		ninePatch.height = text3D.text.boxHeight + npHeightMargin;	
	
		if(resized){npX = -1 + (ninePatch.width - text3D.text.getLineWidth()) / 2;}
		else{npX = (ninePatch.width - text3D.text.getLineWidth()) / 2;}
	
		npY = (ninePatch.height - text3D.text.boxHeight) / 2;

		inputWidth = ninePatch.width;
		inputHeight = ninePatch.height;

		inputOffsetX = npWidthMargin / 2;
		inputOffsetY = npHeightMargin / 2;
	}

//Rendering
	inline public function render(g2:kha.graphics2.Graphics):Void
	{	
		text3D.textColor = curColor;
		text3D.render(g2, pos.x, pos.y);
	}

	inline public function renderNP(g2:kha.graphics2.Graphics):Void
	{	
		ninePatch.render(g2, offset.x + pos.x - npX, offset.y + pos.y - npY);
		text3D.textColor = curColor;
		text3D.render(g2, pos.x, pos.y);
	}

	inline public function renderNPcolors(g2:kha.graphics2.Graphics):Void
	{	
		g2.color = npCurColor;
		ninePatch.render(g2, offset.x + pos.x - npX, offset.y + pos.y - npY);
		g2.color = 0xfff0efeb;
		text3D.render(g2, pos.x, pos.y);
	}

	inline public function renderFinNPcolors(g2:kha.graphics2.Graphics):Void
	{	
		ninePatch.render(g2, offset.x + pos.x - npX, offset.y + pos.y - npY);
		text3D.textColor = npCurColor;
		text3D.render(g2, pos.x, pos.y);
	}

	inline public function renderNPinFcolors(g2:kha.graphics2.Graphics):Void
	{	
		g2.color = curColor;
		ninePatch.render(g2, offset.x + pos.x - npX, offset.y + pos.y - npY);
		text3D.render(g2, pos.x, pos.y);
		
	}

	inline public function renderAllinFcolors(g2:kha.graphics2.Graphics):Void
	{	
		g2.color = curColor;
		ninePatch.render(g2, offset.x + pos.x - npX, offset.y + pos.y - npY);
		text3D.textColor = curColor;
		text3D.render(g2, pos.x, pos.y);
	}

	inline public function renderAllinNPcolors(g2:kha.graphics2.Graphics):Void
	{	
		g2.color = npCurColor;
		ninePatch.render(g2, offset.x + pos.x - npX, offset.y + pos.y - npY);
		text3D.textColor = npCurColor;
		text3D.render(g2, pos.x, pos.y);
	}
	
	inline public function renderTheme(g2:kha.graphics2.Graphics):Void
	{	
		g2.color = npCurColor;
		ninePatch.render(g2, offset.x + pos.x - npX, offset.y + pos.y - npY);
		text3D.textColor = curColor;
		text3D.render(g2, pos.x, pos.y);
	}
}
