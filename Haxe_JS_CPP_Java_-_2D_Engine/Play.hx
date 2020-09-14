package;

import kha.Assets;
import sdg.Object;
import sdg.Screen;
import sdg.Sdg;
import sdg.graphics.Sprite;
import sdg.graphics.tiles.Tileset;
import sdg.graphics.tiles.Tilemap;
import sdg.graphics.TileSprite;
import sdg.collision.Hitbox;
import sdg.collision.Grid;
import sdg.math.Rectangle;
import sdg.atlas.Atlas;
import sdg.atlas.Region;
import format.tmx.Reader;
import format.tmx.Data.TmxTileLayer;
import format.tmx.Data.TmxObject;
import format.tmx.Data.TmxObjectGroup;
import format.tmx.Tools;

import format.tmx.Data.TmxMap;
import format.tmx.Data.TmxLayer;
 
import PlayerMgr;

/*
	Layers with higher values are rendered first. 

//NOTE: The order below has been changed to allow for shadows
	0 objects_fg
	1 player and shadow (places shadows on tiles & behind the foreground)
	2 objects_collision
	3 objects_bg 
	4 tilemap and collisionmap
	5 bg, 
	6-7 water
*/

class Play extends Screen
{
	var playerMgr:PlayerMgr;

	public function new()
	{
		super();

		playerMgr = new PlayerMgr(this);
		loadMap();
		playerMgr.add(1, 70, 120);

	}

	var layerColWidthF:Float;
	var layerColHeightF:Float;
	
	var layerColWidth:Array<Int>;
	var layerColHeight:Array<Int>;
	
	var sW:String;
	var sH:String;

	var colType:Array<String>;
	var colTypeId:Array<Int>;
	var layerName:Array<String>;

	public var water:sdg.Object;
	public var watera:sdg.Object;

	public var water1:sdg.Object;
	public var water2:sdg.Object;
		
	public var waterb:sdg.Object;

	public var water3:sdg.Object;
	public var water4:sdg.Object;

	public var water5:sdg.Object;
	public var water6:sdg.Object;

	public var animFrames = 0;
	public var trigAnim = 20;

//Collision layer parsing (allows tile width, height, & multiply via 'w', 'h', '*' characters)
	public function ParseMapLayers(aTmp:Array<String>)
	{
		var a = aTmp[0];
		if(a != null)
		{ 		
			//trace(a);
	
			var b = playerMgr.u.NSplit_AS(a, ',');
	
			//trace("a:" + a);
			//trace("b0:" + b[0]);
			//trace("b1:" + b[1]);

			playerMgr.u.ReAll_AS(b, 0, 'w', null);
			playerMgr.u.ReAll_AS(b, 1, 'h', null);

			//trace("b1 converted:" + b[1]);
			
			b[0] = b[0].toLowerCase();
			b[1] = b[1].toLowerCase();

			//trace("b1 converted:" + b[1]);

			b[0] = playerMgr.u.ReAll_S(b[0], 'w', sW);
			b[1] = playerMgr.u.ReAll_S(b[1], 'w', sW);
			b[0] = playerMgr.u.ReAll_S(b[0], 'w', sH);
			b[1] = playerMgr.u.ReAll_S(b[1], 'h', sH);

			//trace("b0 to F:" + b[0]);
			//trace("b1 to F:" + b[1]);

			var w = playerMgr.u.NSplit_AS(b[0], '*');
			var h = playerMgr.u.NSplit_AS(b[1], '*');
			
			playerMgr.u.ReAll_AS(w, 1, '1', null);
			playerMgr.u.ReAll_AS(h, 1, '1', null);

			//trace(w[0] + " " + w[1]); 
			//trace(h[0] + " " + h[1]); 

			var wF = Std.parseFloat(w[0]) * Std.parseFloat(w[1]);
			var hF = Std.parseFloat(h[0]) * Std.parseFloat(h[1]);

			//trace(wF +" F: "+ hF);
		
			layerColWidth.push(Std.int(wF));
			layerColHeight.push(Std.int(hF));
		
			//trace(layerColWidth + " : " + layerColHeight);
		}
	}

	public function CompileLayers(d:Int, data:Array<Array<Int>>, oldData:Array<Array<Int>>, colKeyData:Array<Array<Int>>):Array<Array<Int>>
	{
		var w = 0;
		var h = 0;
		
		while(h < data.length)
		{
			//trace('data: ' + data[h]);
			//trace('oDat: ' + oldData[h]);
		
			if(data[h] != oldData[h])
			{
				while(w < data[0].length)
				{	
					//trace(w + ' : ' + data[h][w] + ' onto '  + oldData[h][w]);
									
					if(data[h][w] != oldData[h][w] && oldData[h][w] == -1)
					{
						oldData[h][w] = data[h][w];
						colKeyData[h][w] = d;
					}
					w++;
				}
				w = 0;
			}
			h++;
		}
		return oldData;
	}
	
	inline function loadMap()
	{
		var tmxMap:format.tmx.Data.TmxMap;

		var reader = new Reader(Xml.parse(Assets.blobs.map_tmx.toString()));
		tmxMap = reader.read();

		playerMgr.bg = new Array<Object>();
		playerMgr.bg.push(create(0, -200, new Sprite(Assets.images.bg)));
		playerMgr.bg[0].fixed.x = true;
		
		watera = create(355, 696, new TileSprite('Water', 316, 234, 4, 0), 7);
		water2 = create(355, 696, new TileSprite('Water', 316, 234, -3, 0), 6);

		playerMgr.bg[0].layer = tmxMap.layers.length + 2;
		playerMgr.bg[0].width *=3;

		playerMgr.objectMap = new Object();

		Tools.fixObjectPlacement(tmxMap);
		
		var tileset = new Tileset('tileset', tmxMap.tileWidth, tmxMap.tileHeight);
		playerMgr.bgMap = new Tilemap(tileset);
		
		var a:Array<String>;

		sW = Std.string(tmxMap.tileWidth);
		sH = Std.string(tmxMap.tileHeight);

		layerName = new Array();
		layerColWidth = new Array();
		layerColHeight = new Array();

		//Region list from the atlas cache.
		var regions = new Map<Int, Region>();
		
		playerMgr.objectMap.layer = 1;
		
		colType = new Array();
		colTypeId = new Array<Int>();
	
		var colGrids:Int = 0;
		var colPlatforms:Int = 0;
		var colPillars:Int = 0;
		var colRectangles:Int = 0;

		var colLayerNum = 0;
		var gfxLayerNum = 0;

		var gfxLayers = new Array<Array<Array<Int>>>();
		var colLayers = new Array<Array<Array<Int>>>();

		var colKeyData:Array<Array<Int>>;
		var gfxData = new Array<Array<Array<Int>>>();
		
		var colData = new Array<Array<Int>>();
		var colDataOld = new Array<Array<Int>>();

		var oldTileLayer:format.tmx.Data.TmxTileLayer;
		var gfxLayerOpacity = new Array<Float>();

		for (tmxTileset in tmxMap.tilesets)
		{
			if (tmxTileset.name == 'objects')
			{
				var gid = tmxTileset.firstGID;
				
				for (tile in tmxTileset.tiles)
				{
					//Get the name of the images without the path and extension
					var name = tile.image.source;
					name = StringTools.replace(name, 'images/', '');
					name = StringTools.replace(name, '.png', '');

					regions.set(gid + tile.id, Atlas.getRegion(name));
				}				
			}
		}
		
		for (layer in tmxMap.layers)
		{
			switch(layer)
			{
				case TileLayer(layer):
				{
					var data = new Array<Array<Int>>();

					function ExtractTileLayer(data:Array<Array<Int>>, ?layerTmp:format.tmx.Data.TmxTileLayer):Array<Array<Int>>
					{ 
						var layer = layerTmp;
						var i = 0;
						for (y in 0...layer.height)
						{ 	
							data.push(new Array<Int>());
							for (x in 0...layer.width)
							{					
								data[y].push(layer.data.tiles[i].gid - 1);
								i++;
							}
						}
						return data;					
					} 

					trace('colLayerNum: ' + colLayerNum);
					
					if(layer.name.charAt(0) > '/')
					{
						//trace('current layer.name ' + layer.name);
							
						gfxData[gfxLayerNum] = ExtractTileLayer(data, layer);
						trace(layer.opacity);
						if(layer.opacity < 1)
						{
							gfxLayerOpacity.push(layer.opacity);
						}	
						else
						{
							gfxLayerOpacity.push(1);
						}
						gfxLayerNum++;
					}
					else
					{
						if(layer.name.charAt(0) == '#')
						{
							colType.push('#');
							colGrids++;
							layerName.push(layer.name.substr(1, layer.name.length));
							colTypeId.push(colLayerNum);
							colLayerNum++;
						}
						else
						{
							if(layer.name.charAt(0) == '-')
							{
								colType.push('-');
								colPlatforms++;
								colTypeId.push(colLayerNum);
								colLayerNum++;
							}
							else
							{
								if(layer.name.charAt(0) == '!')
								{
									colType.push('!');
									colPillars++;
									colTypeId.push(colLayerNum);
									colLayerNum++;
								}
								else
								{
									if(layer.name.charAt(0) == '&')
									{
										colType.push('&');
										colRectangles++;
										colTypeId.push(colLayerNum);
										colLayerNum++;
									}
								}
							}
						}
						
						colDataOld = colData; 	
						
						//trace(oldTileLayer.name + ' visibility:' + oldTileLayer.visible); 
						//trace(layer.name + ' visibility:' + layer.visible); 

						colData = ExtractTileLayer(data, layer);

						if(colLayerNum == 2)
						{
							colKeyData = playerMgr.u.In_2AI(colData.length, -1, colData[0].length);
							colKeyData = playerMgr.u.FillAllBut_2AI(colDataOld, colKeyData, -1);
							colKeyData = playerMgr.u.ReAllBut_2AI(colKeyData, -1, 0);		

						}
						if(colLayerNum > 1)
						{	
			
							colData = CompileLayers(colLayerNum-1, colData, colDataOld, colKeyData);

							//trace(oldTileLayer.name + ' visibility:' + oldTileLayer.visible); 
							if(!oldTileLayer.visible)
							{
								playerMgr.u.ReAllBut_2AI(colData, -1, -1);
								//oldTileLayer.visible = true;
							}
						}
						oldTileLayer = layer;
					}
					playerMgr.layersNum++;
				}
			case ObjectGroup(group):
				switch(group.name)
				{
					case 'objects_bg': 			createObjects(group.objects, regions, false, 3);						
					case 'objects_collision':		createObjects(group.objects, regions, true, 2);
					case 'objects_fg':			createObjects(group.objects, regions, false, 0);
				}
					
				default: continue;
			}	
		}	

		function AddTileMap(dataTmp:Array<Array<Int>>, ?i:Int, ?collision:Bool = false)
		{
			var data = dataTmp;

			if(!collision)
			{
				var tileMap = new Tilemap(tileset);
				var tileMap2Add = new sdg.Object();

				tileMap.loadFrom2DArray(data);

				worldWidth = tileMap.widthInPixels;
				worldHeight = tileMap.heightInPixels;
				
				//trace(gfxLayerOpacity[i]);
					
				tileMap2Add.graphic = tileMap;
				tileMap2Add.setSizeAuto();

				tileMap2Add.graphic.alpha = gfxLayerOpacity[i];
				tileMap2Add.layer = 4;

				add(tileMap2Add);
			}
			else
			{
				playerMgr.bgMap.loadFrom2DArray(data);
				playerMgr.objectMap.graphic = playerMgr.bgMap;
				playerMgr.objectMap.setSizeAuto();

				worldWidth = playerMgr.bgMap.widthInPixels;
				worldHeight = playerMgr.bgMap.heightInPixels;
				
				playerMgr.objectMap.layer = 4;
				//playerMgr.objectMap.visible = false;
				add(playerMgr.objectMap);
			}
		}

		function CreateCollisionMap()
		{
			var grid = new Grid(playerMgr.objectMap, tmxMap.tileWidth, tmxMap.tileHeight, 'collision');
			var rectTile = new Rectangle(0, 0, tmxMap.tileWidth, tmxMap.tileHeight / 4);
			trace(colKeyData);

			function PlaceTileCollision(rowWidth, w, h, val):Void
			{ trace('placing colytype: '+ colType[val] + ' val: ' + val);
				w = w - rowWidth;
				rowWidth++;
				if(colType[val] == '#')
				{
					//trace(playerMgr.bgMap.widthInTiles + " width:" + (w + rowWidth));
					grid.setArea(w, h, rowWidth, 1, true);
				}
				else
				{ 
					var i = 0;
					while(i < rowWidth)
					{
						grid.setColRect(w+i, h, rectTile);
						i++;
					}
				}
			}

			function MapTileCollision():Void
			{	
				var w = 0;
				var rowWidth = 0;
				var dataNext = 0;
				var data = 0;
				var dataPrev = 0;

				for(h in 0... colKeyData.length)
				{
					for(w in 0... colKeyData[0].length)
					{ 
						data = playerMgr.u.Get2AI_I(w, h, colKeyData) + 1;
						dataNext = playerMgr.u.Get2AI_I(w+1, h, colKeyData) + 1;
						dataPrev = playerMgr.u.Get2AI_I(w-1, h, colKeyData);
				
						//trace(playerMgr.bgMap.getTile(w, h)+1);	
						if(data > 0)
						{
							if(data  == dataNext)
	            			{
								rowWidth++;						
							}
							else
							{
								if(rowWidth > 0)
								{
									//trace("w: "+ w +" h:"+ h + " row:" + rowWidth + " val:" + dataPrev);
									PlaceTileCollision(rowWidth, w, h, dataPrev);
								}
								else
								{
									PlaceTileCollision(rowWidth, w, h, data-1);
									trace('Placing 1x1 tile row');
								}
								rowWidth = 0;

							}	
						}
					}
					w=0;
				
				}
			}

			MapTileCollision();
		}

		var i = 0;
		while(i < gfxLayerNum)
		{
			//trace(gfxData[i]);
			AddTileMap(gfxData[i], i);
			i++;
		}
		if(colLayerNum > 0)
		{
			AddTileMap(colData, true);
			CreateCollisionMap();
		}
	}

	function createObjects(objects:Array<TmxObject>, regions:Map<Int, Region>, collision:Bool, layer:Int)
	{
		var obj = {};
		for (object in objects)
		{
			switch(object.objectType)
			{
				case Tile(gid):
					obj = create(object.x, object.y, new Sprite(regions.get(gid)));
					obj.setSizeAuto();
					obj.layer = layer;

					if (collision) { new Hitbox(obj, null, 'collision'); }

				default: continue;
			}
		}
	}
}
