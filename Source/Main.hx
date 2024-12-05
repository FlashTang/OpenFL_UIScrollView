package;

import openfl.geom.Point;
import lime.math.Rectangle;
import openfl.display.DisplayObject;
import openfl.display.Sprite;

class Main extends Sprite implements UIScrollView.Delegate {




	var scrollView:UIScrollView;
	var contentView:Sprite;
	public function new() {
		super();

		
		scrollView = new UIScrollView(new Rectangle(200,150,600,400),0xff0000,0x0000ff);
		scrollView.clipToBounds = true;
		scrollView.contentSize = {width: 1000,height:800};
		scrollView.contentView = new Sprite();
		for(i in 0...50){
			var c = new Sprite();
			
			c.graphics.beginFill(0xff9d00);
			c.graphics.drawCircle(Math.random() * 950+ 25,Math.random() * 750 + 50,25);
			c.graphics.endFill();
			c.mouseEnabled = false;
			c.mouseChildren = false;
			cast(scrollView.contentView,Sprite).addChild(c);
	 
		}
		scrollView.contentOffset = new Point(100,100);
		scrollView.delegate = this;
		addChild(scrollView);


		var p = new Point();

		var a = p;

		a.x = 100;

		trace(a);
		trace(p);
	}

	public function viewForZooming(scrollView:UIScrollView):DisplayObject {
		return contentView;
	}

	public function scrollViewDidEndZooming(scrollView:UIScrollView){
		 
	}

	public function scrollViewDidScroll(scrollView:UIScrollView) {

	}
}


