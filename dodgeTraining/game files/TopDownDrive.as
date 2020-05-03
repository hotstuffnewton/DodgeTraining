//BUGS//////////////
// energy balls hitting the hop or right side of a rock dont bouce correctly
// music isnt looped and turns off
// need scoreboard
// need to add piccolo as a boss along with a winner page/frame
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
package {
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;                                         //IMPORTS DONT TOUCH
	import flash.utils.getTimer;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundMixer;
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	public class TopDownDrive extends MovieClip {
		
		// constants
		static const speed:Number = .7; // Gohans movment speed
		static const turnSpeed:Number = .5; // Gohans turn speed
		static const playerSize:Number = 50; // size of Gohan to be used in colisitions
		static const mapRect:Rectangle = new Rectangle(-1150,-1150,2300,2300); // size of the map 
		static const totalEnergyBalls:uint = 10; // max number of energy balls spawned at the begining of the game. more are spawned as time goes on!
		static const gohanHitDetection:Number = 40; // hit detection on Gohan with energy balls 
		
		// game objects
		private var blocks:Array; // blocks array used as barriers ect
		private var energyBalls:Array; // energy balls array
	
		// game variables
		private var arrowLeft, arrowRight, arrowUp:Boolean; // true/false movment for the key bindings (up is always true to keep player moving)
		private var lastTime:int; // used to calc the right time
		private var gameStartTime:int; // in game time
		private var timeCount:int = 0; // used for time set events such as scorinig
		private var timeCount2:int = 0; // used to spawn new energy balls
		private var totalenergyBalls:int; //changeable energyball count
		private var score:int = 0;  // score earned in game
		private var health:int = 100; // health, once its all gone its game over!
		
		// sounds
		var energyballspawn:energyballsound = new energyballsound(); // signal that a ball has been spawned 
		var energyballhit:blastsound = new blastsound(); // sound plays if your hit
		var dodge:dodgesound = new dodgesound(); // sound plays at the begining of every game.
		var theme:themesound = new themesound(); // background music
		var taunt:tauntsound = new tauntsound(); // end game taunt (game over)
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function startTopDownDrive() {
			SoundMixer.stopAll(); // stop all pervious music playing
			// get blocks
			findBlocks();
			// spawn energy balls
			spawnEnergyBalls();
			// make sure Gohan is ontop of all images
			gamesprite.setChildIndex(gamesprite.car,gamesprite.numChildren-1);
			// add listeners
			this.addEventListener(Event.ENTER_FRAME,gameLoop);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownFunction);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpFunction);
			// set up game variables
			gameStartTime = getTimer();
			centerMap();
			showScore();
			
			playSound(dodge); // plays a sound
			playSound(theme);
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// find all Block objects
		public function findBlocks() {
			blocks = new Array();
			for(var i=0;i<gamesprite.numChildren;i++) {
				var mc = gamesprite.getChildAt(i);
				if (mc is Block) {
					// add to array and make invisible
					blocks.push(mc);
					mc.visible = false; // blocks aren't visible
				}
			}
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		// create random energyballs objects 
		public function spawnEnergyBalls() {
		       energyBalls = new Array();
		       for(var i:int=0;i<totalEnergyBalls;i++) {
				
				// loop forever
				while (true) {
					
					// random location
					var x:Number = Math.floor(Math.random()*mapRect.width)+mapRect.x;
					var y:Number = Math.floor(Math.random()*mapRect.height)+mapRect.y;
					var ballXSpeed:Number = 1; // speed of x
		            var ballYSpeed:Number = 1; // speed of y
					
					// check all blocks to see if it is over any
					var isOnBlock:Boolean = false;
					for(var j:int=0;j<blocks.length;j++) {
						if (blocks[j].hitTestPoint(x+gamesprite.x,y+gamesprite.y)) {
							isOnBlock = true;
							break;
						}
					}
					
					// not over any, so use location
					if (!isOnBlock) {
						var newObject:TrashObject = new TrashObject();
						newObject.x = x;
						newObject.y = y;
						newObject.ballXSpeed = 1; // sets the speed 
						newObject.ballYSpeed = 1; // sets the speed
						newObject.gotoAndStop(Math.floor(Math.random()*3)+1);
						gamesprite.addChild(newObject);
						energyBalls.push(newObject);
						break;
					}
				}
			}
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		// note key presses, set properties
		public function keyDownFunction(event:KeyboardEvent) { // moving up is always true to keep the player moving. a down button isnt needed
			if (event.keyCode == 37) {
				arrowLeft = true;
			} else if (event.keyCode == 39) {
				arrowRight = true;
			} 
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		public function keyUpFunction(event:KeyboardEvent) { // moving up is always true to keep the player moving. a down button isnt needed
			if (event.keyCode == 37) {
				arrowLeft = false;
			} else if (event.keyCode == 39) {
				arrowRight = false;
			} 
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		// main game code 
		public function gameLoop(event:Event) {
			
			arrowUp = true; //always moving
					
			for(var i:int=energyBalls.length-1;i>=0;i--) { // this means all energyballs can be changed and calcuated up the the var energyballs[i]
				for(var key:int=0;key<blocks.length;key++) { // as one array in this fuction is already using [i] i have changed it to [key] but they both do the same thing.

                 var blockRect:Rectangle = blocks[key].getRect(gamesprite); // the var blockRect can now be used instead of blocks[key] this makes things easier to read and work out later on.
				 
	             energyBalls[i].x += energyBalls[i].ballXSpeed; // moves all energyballs x by + the xspeed 
	             energyBalls[i].y += energyBalls[i].ballYSpeed; // moves all energyballs y by + the yspeed 
				 
				  //CHECK TO SEE IF BALLS HAVE HIT A BLOCK
	if (energyBalls[i].x < mapRect.left) { // left side of map has been hit
		energyBalls[i].x = mapRect.left; // stop ball going past limit
		energyBalls[i].ballXSpeed *= +energyBalls[i].ballXSpeed; // bounce it back by changing the speed value
	}
	if (energyBalls[i].x > mapRect.right) { // right side hit
		energyBalls[i].x = mapRect.right; // stops at limit
		energyBalls[i].ballXSpeed *= -energyBalls[i].ballXSpeed; // bounces ball 
	}
	if (energyBalls[i].y < mapRect.top) { //top has been hit 
		energyBalls[i].y = mapRect.top; //stops at limit
		energyBalls[i].ballYSpeed *= +energyBalls[i].ballYSpeed; // bounce ball
	}
	if (energyBalls[i].y > mapRect.bottom) { // bottom limit hit
		energyBalls[i].y = mapRect.bottom; // stop at limit
		energyBalls[i].ballYSpeed *= -energyBalls[i].ballYSpeed; // bounce ball
	}     
	           //CHECK TO SEE IF ROCKS ARE HIT
	if (energyBalls[i].x + energyBalls[i].width >= blockRect.left && energyBalls[i].x < blockRect.left && energyBalls[i].y >= blockRect.top && energyBalls[i].y <= blockRect.bottom) { // left side hit
		energyBalls[i].x = blockRect.left; // stop ball going past limit
		energyBalls[i].ballXSpeed *= -energyBalls[i].ballXSpeed; // bounce it back by changing the speed value
	}
	if (energyBalls[i].x + energyBalls[i].width > blockRect.right && energyBalls[i].x <= blockRect.right && energyBalls[i].y >= blockRect.top && energyBalls[i].y <= blockRect.bottom) { // right side hit
		energyBalls[i].x = blockRect.right; // stops at limit
		energyBalls[i].ballXSpeed *= +energyBalls[i].ballXSpeed; // bounces ball 
	}
	if (energyBalls[i].x >= blockRect.left && energyBalls[i].x + energyBalls[i].width <= blockRect.right && energyBalls[i].y + energyBalls[i].height > blockRect.top && energyBalls[i].y < blockRect.top) { //top has been hit 
		energyBalls[i].y = blockRect.top; //stops at limit
		energyBalls[i].ballYSpeed *= -energyBalls[i].ballYSpeed; // bounce ball
	}
	if (energyBalls[i].x >= blockRect.left && energyBalls[i].x + energyBalls[i].width <= blockRect.right && energyBalls[i].y < blockRect.bottom && energyBalls[i].y + energyBalls[i].height > blockRect.bottom) { // bottom limit hit
		energyBalls[i].y = blockRect.bottom; // stop at limit
		energyBalls[i].ballYSpeed *= +energyBalls[i].ballYSpeed; // bounce ball
	}
  }
}
			
			// calculate time passed
			if (lastTime == 0) lastTime = getTimer();
			var timeDiff:int = getTimer()-lastTime;
			lastTime += timeDiff;
			
			// rotate left or right
			if (arrowLeft) {
				rotateGohan(timeDiff,"left");
			}
			if (arrowRight) {
				rotateGohan(timeDiff,"right");
			}
			
			// move gohan
			if (arrowUp) {
				moveGohan(timeDiff);
				centerMap();
				checkCollisions();
			}
			
			// update time 
			showTime();
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		// make sure gohan is always at the centre of the screen
		public function centerMap() {
			gamesprite.x = -gamesprite.car.x + 275;
			gamesprite.y = -gamesprite.car.y + 200;
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		public function rotateGohan(timeDiff:Number, direction:String) {
			if (direction == "left") {
				gamesprite.car.rotation -= turnSpeed*timeDiff;
			} else if (direction == "right") {
				gamesprite.car.rotation += turnSpeed*timeDiff;
			}
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		// move gohan
		public function moveGohan(timeDiff:Number) {
			// calculate area of gohan
			var gohanRect = new Rectangle(gamesprite.car.x-playerSize/2, gamesprite.car.y-playerSize/2, playerSize, playerSize);
			
			// calculate new area
			var newgohanRect = gohanRect.clone();
			var gohanAngle:Number = (gamesprite.car.rotation/360)*(2.0*Math.PI);
			var dx:Number = Math.cos(gohanAngle);
			var dy:Number = Math.sin(gohanAngle);
			newgohanRect.x += dx*speed*timeDiff;
			newgohanRect.y += dy*speed*timeDiff;
			
			// calculate new location
			var newX:Number = gamesprite.car.x + dx*speed*timeDiff;
			var newY:Number = gamesprite.car.y + dy*speed*timeDiff;
			
			// loop through blocks and check collisions
			for(var i:int=0;i<blocks.length;i++) {
				
				// get block rectangle, see if there is a collision
				var blockRect:Rectangle = blocks[i].getRect(gamesprite);
				if (blockRect.intersects(newgohanRect)) {
		
					// horizontal push-back
					if (gohanRect.right <= blockRect.left) {
						newX += blockRect.left - newgohanRect.right;
					} else if (gohanRect.left >= blockRect.right) {
						newX += blockRect.right - newgohanRect.left;
					}
					
					// vertical push-back
					if (gohanRect.top >= blockRect.bottom) {
						newY += blockRect.bottom-newgohanRect.top;
					} else if (gohanRect.bottom <= blockRect.top) {
						newY += blockRect.top - newgohanRect.bottom;
					}
				}
				
			}
			
			// check for collisions with sidees
			if ((newgohanRect.right > mapRect.right) && (gohanRect.right <= mapRect.right)) {
				newX += mapRect.right - newgohanRect.right;
			}
			if ((newgohanRect.left < mapRect.left) && (gohanRect.left >= mapRect.left)) {
				newX += mapRect.left - newgohanRect.left;
			}
			
			if ((newgohanRect.top < mapRect.top) && (gohanRect.top >= mapRect.top)) {
				newY += mapRect.top-newgohanRect.top;
			}
			if ((newgohanRect.bottom > mapRect.bottom) && (gohanRect.bottom <= mapRect.bottom)) {
				newY += mapRect.bottom - newgohanRect.bottom;
			}
		
			// set new car location
			gamesprite.car.x = newX;
			gamesprite.car.y = newY;
		}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
		// turn left or right
		// check for collisions for gohan and energyballs
		public function checkCollisions() {
			
			for(var i:int=energyBalls.length-1;i>=0;i--) {
		
				// see if close enough to be hit
				if (Point.distance(new Point(gamesprite.car.x,gamesprite.car.y), new Point(energyBalls[i].x, energyBalls[i].y)) < gohanHitDetection) {
						energyBalls[i].currentFrame-1;
						gamesprite.removeChild(energyBalls[i]);
						energyBalls.splice(i,1); // remove energy ball that was hit from the game
						health -= 5; // reduce health
						showScore(); // update score/HUD
						playSound(energyballhit); // play sound on hit
				}
			}
			
			if(health <= 0){ // check if dead
				health = 0; // gohans dead
				endGame(); // end game
				
			}
		}
		
		// update the time shown
		public function showTime() {
			
			var x:Number = Math.floor(Math.random()*mapRect.width)+mapRect.x;
			var y:Number = Math.floor(Math.random()*mapRect.height)+mapRect.y;
			
			if(timeCount >= 100){ // if the time count has hit 100
				score++; // score plus one
				timeCount = 0; // time count reset
				showScore(); // update score/ HUD
			}
			 if(timeCount2 >= 175){
				// SPAWN A NEW ENERGYBALL
				var newObject:TrashObject = new TrashObject();
				newObject.x = x;
				newObject.y = y;
				newObject.ballXSpeed = 1; // sets the speed 
				newObject.ballYSpeed = 1; // sets the speed
				newObject.gotoAndStop(Math.floor(Math.random()*3)+1);
				gamesprite.addChild(newObject);
				energyBalls.push(newObject);
				timeCount2 = 0; // time count reset
				playSound(energyballspawn);
				
			}
			
			timeCount++; // time count plus one
			timeCount2++;
			
			var gameTime:int = getTimer()-gameStartTime;
			timeDisplay.text = clockTime(gameTime);
		}
		
		// convert to time format
		public function clockTime(ms:int):String {
			var seconds:int = Math.floor(ms/1000);
			var minutes:int = Math.floor(seconds/60);
			seconds -= minutes*60;
			var timeString:String = minutes+":"+String(seconds+100).substr(1,2);
			return timeString;
			
		}
		
		// update the score text elements
		public function showScore() {
			
			// set health and score
			numLeft.text = String(health);
			scoreDisplay.text = String(score);
		}
		
		// game over, remove listeners and reset all variables
		public function endGame() {
			SoundMixer.stopAll();  // stop all pervious music playing
			blocks = null;
			energyBalls = null;
			health = 100;
			score = 0;
			this.removeEventListener(Event.ENTER_FRAME,gameLoop);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownFunction);
			stage.removeEventListener(KeyboardEvent.KEY_UP,keyUpFunction);
			gotoAndStop("gameover");
		}
		
		// show time on final screen
		public function showFinalMessage() {
			playSound(energyballhit); 
			playSound(taunt);
			showTime();
			var finalDisplay:String = "";
			finalDisplay += "Time: "+timeDisplay.text+"\n";
			finalMessage.text = finalDisplay;
		}
		
		public function playSound(soundObject:Object) { // needed to play sounds
			var channel:SoundChannel = soundObject.play(); // all sounds imported need to be wtitten in this format.
		}
	}
		
}