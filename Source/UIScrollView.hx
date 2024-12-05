package;


import openfl.events.TimerEvent;
import openfl.utils.Timer;
import openfl.events.MouseEvent;
import openfl.display.DisplayObject;
import lime.math.Rectangle;
import openfl.geom.Point;
import openfl.display.Sprite;


interface Delegate {
	function viewForZooming(scrollView:UIScrollView):DisplayObject;
    function scrollViewDidEndZooming(scrollView:UIScrollView):Void;
    function scrollViewDidScroll(scrollView: UIScrollView):Void;
}

typedef Size = {
    var width:Float;
    var height:Float;
}
 
class UIScrollView extends DrawSprite {
    
    
    private var size(default, set):Size;
    function set_size(nSize) {
        return this.size = nSize;
    }
     
    public var delegate:Delegate;
    public var masker:Masker;
    public var clipToBounds(default, set):Bool;
    public var maxZoomScale:Float = 3;
    public var minZoomScale:Float = 0.2;
    public var zoomScale:Float = 1;
    public var decelerationRate:Float = 0.85;
    private var decelerationRateX:Float;
    private var decelerationRateY:Float;
    function set_clipToBounds(nclipToBounds) {
        if(nclipToBounds){
            if(masker == null) {
                masker = new Masker();
            }
            masker.draw(size.width,size.height);
            addChild(masker);
            mask = masker;
            this.draw(size.width,size.height,{width:5,color:0x000000});
        }
        else if(masker != null ) {
            mask = null;
            removeChild(masker);
            masker = null;
            this.draw(size.width,size.height,null);
        }
        return this.clipToBounds = nclipToBounds;
    }

    public var contentOffset(default, set):Point;
    function set_contentOffset(nOffset) {
        if(contentView != null){
            interactiveSprite.x = -nOffset.x;
            interactiveSprite.y = -nOffset.y;
            contentView.x = interactiveSprite.x;
            contentView.y = interactiveSprite.y;
        }
        return this.contentOffset = nOffset;
    }
     
    public var contentView(default, set):DisplayObject;
    function set_contentView(nContentView) {
        if(contentView?.parent == this){
            removeChild(contentView);
        }
        contentOffset = new Point(0,0);
        addChild(nContentView);
        return this.contentView = nContentView;
    }
    public var contentSize(default, set):Size;
    function set_contentSize(newSize) {
      
        interactiveSprite.draw(newSize.width,newSize.height);
        return contentSize = newSize;
    }
    private var interactiveSprite:InteractiveSprite;
    public function new(?viewPort:Rectangle,bgColor:Int,contentBgColor:Int) {
        super();
        x = viewPort.x; y = viewPort.y;
        size = {width: viewPort?.width ?? 500,height:viewPort?.height ?? 500};
        interactiveSprite = new InteractiveSprite();
        interactiveSprite.alpha = 0.5;
        @:privateAccess interactiveSprite.backgroundColor = contentBgColor;
        addChild(interactiveSprite);
        this.backgroundColor = bgColor;
        this.draw(size.width,size.height);
        addGestures();
    }
 
    function addGestures(){
        interactiveSprite.addEventListener(MouseEvent.MOUSE_DOWN,mouseHandler);
    }

    var omp:Point = null; //old mouse point
    var oldContentOffset:Point;
    var animateTimer:Timer;
    var animateVector:Point;
    var prevMP:Point;
    var lastMP:Point;
    var isOriginalOverScrolledX:Bool = false;
    var isOriginalOverScrolledY:Bool = false;

    function mouseHandler(e:MouseEvent):Void{
        if(e.type == MouseEvent.MOUSE_DOWN){

            animateTimer?.stop();
            animateTimer?.removeEventListener(TimerEvent.TIMER,animationLoop);

            oldContentOffset = new Point(contentOffset.x,contentOffset.y);
            omp = new Point(e.stageX,e.stageY);
            stage.addEventListener(MouseEvent.MOUSE_MOVE,mouseHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP,mouseHandler);
        }
        else if(e.type == MouseEvent.MOUSE_MOVE){
            
            var cmp:Point = new Point(e.stageX,e.stageY);
            var movedX:Float = cmp.x - omp.x;
            var movedY:Float = cmp.y - omp.y;
            var newOffset = new Point(oldContentOffset.x-movedX,oldContentOffset.y-movedY);
            this.contentOffset = newOffset;
            if(prevMP == null){
                prevMP = new Point(e.stageX,e.stageY);
            }
            else{
                prevMP  = lastMP;
            }
            lastMP = new Point(e.stageX,e.stageY);
        }
        else if(e.type == MouseEvent.MOUSE_UP){
            var cmp:Point = new Point(e.stageX,e.stageY);
            var movedX:Float = cmp.x - omp.x;
            var movedY:Float = cmp.y - omp.y;
            var newOffset = new Point(oldContentOffset.x-movedX,oldContentOffset.y-movedY);
            this.contentOffset = newOffset;
            stage.removeEventListener(MouseEvent.MOUSE_MOVE,mouseHandler);
            stage.removeEventListener(MouseEvent.MOUSE_UP,mouseHandler);

             
            animateTimer?.stop();
            animateTimer?.removeEventListener(TimerEvent.TIMER,animationLoop);

            decelerationRateX = decelerationRateY = decelerationRate;
             
            animateTimer = new Timer(1000.0/60.0,0);
            animateTimer.addEventListener(TimerEvent.TIMER,animationLoop);
            animateTimer.start();
            animateVector = new Point(prevMP.x-lastMP.x,prevMP.y-lastMP.y);
            
           
        }
        
        
    }

    var goBackSpeed:Float = 0.2;
    function animationLoop(e:TimerEvent):Void{
        
        var _contentOffset:Point = new Point(this.contentOffset.x,this.contentOffset.y);


        if(Math.abs(animateVector.x) > 0.01){
            _contentOffset.x = _contentOffset.x + animateVector.x;
        }
        
        if(_contentOffset.x < 0){
            _contentOffset.x += (0 - _contentOffset.x) * goBackSpeed;
            
        }
        if(_contentOffset.x > contentSize.width - size.width){
            _contentOffset.x += ((contentSize.width - size.width) - _contentOffset.x) * goBackSpeed;
           
        }

        if(Math.abs(animateVector.y) > 0.01){
            _contentOffset.y = _contentOffset.y + animateVector.y;
        }

        if(_contentOffset.y < 0){
            _contentOffset.y += (0 - _contentOffset.y) * goBackSpeed;
            
        }

        if(_contentOffset.y > contentSize.height - size.height){
            _contentOffset.y += (contentSize.height - size.height - _contentOffset.y) * goBackSpeed;
           
        }

        
        if(_contentOffset.x >= 0){
            animateVector.x *= decelerationRateX;
        }
        else{
            animateVector.x *= decelerationRateX * 0.5;
        }
        if(_contentOffset.y >= 0){
            animateVector.y *= decelerationRateY;
        }
        else{
            animateVector.y *= decelerationRateY * 0.5;
        }


        this.contentOffset = new Point(_contentOffset.x,_contentOffset.y);
 
        // if(Math.abs(animateVector.x) < 0.01 && Math.abs(animateVector.y) < 0.01 && _contentOffset.x >= 0 && _contentOffset.y >= 0 && _contentOffset.x <= contentSize.width - size.width){
        //     animateTimer?.stop();
        //     animateTimer?.removeEventListener(TimerEvent.TIMER,animationLoop);
        //     prevMP = null;
        //     trace("okokokok");
        // }

        
    }
        
 
}

class InteractiveSprite extends DrawSprite{
    public function new() {
        super();
    }
}

class Masker extends DrawSprite{
    public function new() {
        super();
    }
}

class DrawSprite extends Sprite {
    private var backgroundColor:Int = 0xff0000;
    public function draw(width:Float,height:Float,lineStyle:{width:Float,color:Int} = null):Void {
        this.graphics.clear();
        this.graphics.lineStyle(lineStyle?.width ?? 0,lineStyle?.color ?? 0x00ff00);
        this.graphics.beginFill(this.backgroundColor);
        this.graphics.drawRect(0,0,width,height);
        this.graphics.endFill();
    }
}
