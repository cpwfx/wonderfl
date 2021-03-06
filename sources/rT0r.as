/**
    
    バネモデルによるグラフ描画　その２
    
     ●をクリックすると増えます。

	 つなげる操作ができるといい感じだと思うんですが、
	 ちょっと時間がかかるので。。。





*/






package
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.*;

	public class EadesMainWonderfl2 extends Sprite
	{
		
		private var eades:EadesGraph;
		private var edgeVCArray:Array;
		private var nodeVCArray:Array;
		
		private var nodeStg:Sprite;
		private var edgeStg:Sprite;
		
		public function EadesMainWonderfl2()
		{
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			this.stage.align = StageAlign.TOP_LEFT;
			
			eades = new EadesGraph();
			
			var node1:Node = new Node();
			var node2:Node = new Node();
			var node3:Node = new Node();
			var node4:Node = new Node();

			node1.x = 220;
			node1.y = 221;
			node2.x = 220;
			node2.y = 222;
			node3.x = 220;
			node3.y = 223;
			node4.x = 220;
			node4.y = 223;
			
			eades.addNode(node1);
			eades.addNode(node2);
			eades.addNode(node3);
			eades.addNode(node4);

			var edge1:Edge = new Edge(node1, node2);
			var edge2:Edge = new Edge(node2, node3);
			var edge3:Edge = new Edge(node3, node4);
			var edge4:Edge = new Edge(node4, node1);
			var edge5:Edge = new Edge(node1, node3);
			var edge6:Edge = new Edge(node2, node4);
			
			eades.addEdge(edge1);			
			eades.addEdge(edge2);			
			eades.addEdge(edge3);			
			eades.addEdge(edge4);			
			eades.addEdge(edge5);			
			eades.addEdge(edge6);
			
			nodeStg = new Sprite();
			nodeVCArray = [	new NodeVC(this.createSprite(), node1),
					new NodeVC(this.createSprite(),node2),
                                              new NodeVC(this.createSprite(),node3),
                                              new NodeVC(this.createSprite(),node4)];
						
			edgeStg = new Sprite();
			edgeVCArray = [new EdgeVC(createEdgeView(),edge1),
                                        new EdgeVC(createEdgeView(),edge2),
                                        new EdgeVC(createEdgeView(),edge3),
                                        new EdgeVC(createEdgeView(),edge4),
                                        new EdgeVC(createEdgeView(),edge5),
                                        new EdgeVC(createEdgeView(),edge6)]
			nodeVCArray[0].addEventListener(MouseEvent.CLICK, clickHandler);
			nodeVCArray[1].addEventListener(MouseEvent.CLICK, clickHandler);
			nodeVCArray[2].addEventListener(MouseEvent.CLICK, clickHandler);
			nodeVCArray[3].addEventListener(MouseEvent.CLICK, clickHandler);
			
			addChild(edgeStg);
			addChild(nodeStg);

			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			addParticle(event.target.node);
		}
		
		private function addParticle(node0:Node):void
		{
			//node0 つなぎ先
			var node1:Node = new Node();
			
			var edge:Edge = new Edge(node0, node1);
			
			node1.x = node0.x;
			node1.y = node0.y;
			
			
			eades.addNode(node1);
			eades.addEdge(edge);
			
			var nodeVC:NodeVC = new NodeVC(createSprite(), node1);
			nodeVCArray.push(nodeVC);
			nodeVC.addEventListener(MouseEvent.CLICK, clickHandler);
			
			var edgeVC:EdgeVC = new EdgeVC(createEdgeView(),edge);
			edgeVCArray.push(edgeVC);
		}
		
		private function createSprite():Sprite
		{
			var sp:Sprite = new Sprite();
			var g:Graphics = sp.graphics;

			g.beginFill(0x000000);
			g.drawCircle(0,0,10);
			g.endFill();
		
			sp.buttonMode = true;
			
			nodeStg.addChild(sp);
			return sp;
		}
		
		private function createEdgeView():Sprite
		{
			var sp:Sprite = new Sprite();
			var g:Graphics = sp.graphics;
			g.lineStyle(0x000000);
			g.moveTo(0,0);
			g.lineTo(100,100);
		
			edgeStg.addChild(sp);
			return sp;
		}
		
		private function enterFrameHandler(event:Event):void
		{
			eades.update();
			
			nodeVCArray.forEach(function(node:NodeVC, i:int, arr:Array):void{
				node.update();				
			});
			
			edgeVCArray.forEach(function(edge:EdgeVC, i:int, arr:Array):void{
				edge.update();				
			});
			
			
		}
	}
}
	import flash.events.*;
	import flash.display.*;
	import flash.geom.Point;

	class EadesChild
	{
		static protected var idCounter:Number = 0;
		public var id:Number;
		
		public function EadesChild()
		{
			id = idCounter++;
		}

		
	}
	

	class EadesGraph
	{
		
		public var nodeArray:Array;
		public var edgeArray:Array;

		public function EadesGraph()
		{
			nodeArray = [];
			edgeArray = [];
			
			initialize();
		}

		private function initialize():void
		{
			
		}
		
		public function addNode(node:Node):Node
		{
			if(isContainNode(node))
			{
				return node;
			}
			nodeArray.push(node);
			return node;
		}
		
		public function removeNode(node:Node):Node
		{

			var l:int = nodeArray.length;
			for(var i:int = 0; i<l; i++)
			{
				if(nodeArray[i].id == node.id)
				{
					return nodeArray.splice(i,1);
				}
			}

			
			return null;
		}
		
		public function addEdge(edge:Edge):Edge
		{
			//連結を作る。
			
			edgeArray.push(edge);
			return edge;
		}
		
		public function removeEdge(edge:Edge):Edge
		{
			
			var l:int = edgeArray.length;
			for(var i:int = 0; i<l; i++)
			{
				if(edgeArray[i].id == edge.id)
				{
					return edgeArray.splice(i,1);
				}
			}

			return edge;
		}
		
		private function isContainNode(node:Node):Boolean
		{
			var l:int = nodeArray.length;
			for(var i:int = 0; i<l; i++)
			{
				if(nodeArray[i].id == node.id)
				{
					return true;
				}
			}
			return false;
		}
/*
		y 
	  x 01234
		1/,,,
		2 /,,
		3  /,
		4   /
*/
		
		private var point:Point = new Point(0,0);
		public function update():void
		{
			edgeArray.forEach(function(edge:Edge, i:int, arr:Array):void{
				edge.update();
			});

			//つながってないノード同士は離す。
			var nodeArray:Array = this.nodeArray;
			var l:int = nodeArray.length;
			for(var i:int = 0; i<l ; i++)
			{
				for(var j:int = i; j<l ; j++)
				{
					if(i == j)
					{
						//自分同士の判定はしない。
						continue;
					}
					var node0:Node = nodeArray[i];
					var node1:Node = nodeArray[j];
					
					if(!isConnection(node0, node1))
					{
						//つながっているか調べる。いない場合は反発させる。
						
						point.x = node0.x - node1.x;
						point.y = node0.y - node1.y;
						var length:Number = point.length;
						if(length < 1)
						{
							length = 1;
						}
						
						point.normalize(100);
						
						var x:Number = point.x * (1/length);
						var y:Number = point.y * (1/length);
						
						node0.forceX += x;
						node0.forceY += y;
						node1.forceX += -x;
						node1.forceY += -y;

					}
					
				}
			}
			
			nodeArray.forEach(function(node:Node, i:int, arr:Array):void{
				node.update();
			});
		}

		private function isConnection(_node0:Node, _node1:Node):Boolean
		{
			var node0:Node;
			var node1:Node;
			
			if(_node0.id < _node1.id)
			{
				node0 = _node0;
				node1 = _node1;
			}
			{
				node0 = _node1;
				node1 = _node0;
			}
			
			//edgeArrayの中から探す。
			var arr:Array = edgeArray;
			var l:int = arr.length;
			for(var i:int = 0; i<l; i++)
			{
				var edge:Edge = arr[i];
				if(node0.id == edge.node0.id)
				{
					if(node1.id == edge.node1.id)
					{
						return true;
					}
				}
			}
			
			return false;			
		}
		
	}
	
	
	class Edge extends EadesChild
	{
		

		public var node0:Node;
		public var node1:Node;
		
		
		public var targetLength:Number = 30;	//ばねの長さ
		public var bounce:Number = 1;	//ばねが元に戻ろうとする力。
		
		
		public function Edge(node0:Node, node1:Node)
		{
			super();
			
			//ID順にソートをする。
			if(node0.id < node1.id)
			{
				this.node0 = node0;
				this.node1 = node1;
			}
			else
			{
				this.node0 = node1;
				this.node1 = node0;
			}
			
			
			this.initialize();
		}

		private function initialize():void
		{
			
		}
		
		
		static private var tmpPoint:Point = new Point(0,0);
		public function update():void
		{
			//node0とnode1の距離はかる。	
			if(node0.x == node1.x && node0.y == node0.y)
			{
				node0.x += Math.random();
				node0.y += Math.random();
			}
			
			
			tmpPoint.x = node0.x - node1.x;
			tmpPoint.y = node0.y - node1.y;
			
			

			var lenght:Number = tmpPoint.length - targetLength;
			if( lenght < 0.5 && length < -0.5)
			{
				return;
			}
			
			
			var force:Number = bounce*((tmpPoint.length - targetLength)/targetLength);

			tmpPoint.normalize(targetLength);

			var x:Number = tmpPoint.x / 2 * force;
			var y:Number = tmpPoint.y / 2* force;
			
			
			node0.forceX -= x;
			node0.forceY -= y ;
			
			node1.forceX += x;
			node1.forceY += y;
			
			
			//log(距離/length);をlog1,log2に与える。
		}
		
	}


	class EdgeVC extends EventDispatcher
	{

		public var view:DisplayObject
		public var edge:Edge;
		public function EdgeVC(view:DisplayObject, edge:Edge)
		{
			this.view = view;
			this.edge = edge;
			
		}
		
		public function update():void
		{
			view.x = edge.node0.x;
			view.y = edge.node0.y;
			view.scaleX = (edge.node1.x - edge.node0.x)/100;
			view.scaleY = (edge.node1.y - edge.node0.y)/100;
			
		}
		
	}

	
	class Node extends EadesChild
	{

		
		private var edgeArray:Array;
		
		
		public var x:Number = 0;
		public var y:Number = 0;
		
		public var ease:Number = 5;
		
		public function Node()
		{
			super();
		}
		
		private var _forceX:Number = 0;
		public function set forceX(value:Number):void
		{
			_forceX = value;
		}
		
		public function get forceX():Number
		{
			return _forceX;
		}
		
		private var _forceY:Number = 0;
		public function set forceY(value:Number):void
		{
			_forceY = value;
		}
		
		public function get forceY():Number
		{
			return _forceY;
		}
		
		public function update():void
		{
			//forceX, forceY をゆっくり与えていく・・のか？
			
			x += _forceX*0.1;
			_forceX *= 0.8;
			y += _forceY*0.1;
			_forceY *= 0.8;

		}
	}
	
	
	 class NodeVC extends EventDispatcher
	{

		public var view:DisplayObject
		public var node:Node;
		public function NodeVC(view:DisplayObject, node:Node)
		{
			this.view = view;
			this.node = node;
			
			view.addEventListener(MouseEvent.CLICK, clickHandler);
		}
		
		public function update():void
		{
			view.x = node.x;
			view.y = node.y;
		}
		
		public function clickHandler(event:MouseEvent):void
		{
			this.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
		}
	}

	