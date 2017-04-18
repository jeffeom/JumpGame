//
//  GameScene.swift
//  Jump
//
//  Created by Jeff Eom on 2017-01-26.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
  
  var start = Bool(false)
  var firstRun = Bool(true)
  var onFloor1 = Bool(false)
  var onFloor2 = Bool(false)
  var gameBorder = SKPhysicsBody()
  var myBackground = SKSpriteNode()
  var myFloor1 = SKSpriteNode()
  var myFloor2 = SKSpriteNode()
  let birdAtlas = SKTextureAtlas(named: "player.atlas")
  var birdSprites = Array<SKTexture>()
  var bird = SKSpriteNode()
  var myLabel = SKLabelNode()
  var jumpLength = CGFloat(50)
  var holeLength = CGFloat(50)
  var floorLength = CGFloat(100)
  var jumpNumber = 5
  var dead = false
  
  struct PhysicsCategory {
    static let None : UInt32 = 0
    static let All  : UInt32 = UInt32.max
    static let Bird : UInt32 = 0b1
    static let Border : UInt32 = 0b10
    static let Floor : UInt32 = 0b11
  }
  
  override func didMove(to view: SKView) {
    
    physicsWorld.gravity = CGVector.init(dx: 0, dy: -9.8)
//            physicsWorld.gravity = CGVector.zero
    physicsWorld.contactDelegate = self
    
    //        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
    self.backgroundColor = SKColor(red: 91.0/255.0, green: 163.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    
    let bgm = SKAudioNode(fileNamed: "tapslow.mp3")
    bgm.autoplayLooped = true
//    addChild(bgm)
    
    let border = CGRect.init(x: -300, y: 0, width: self.frame.size.width + 600, height: self.frame.size.height)
    gameBorder = SKPhysicsBody.init(edgeLoopFrom: border)
    gameBorder.isDynamic = false
    gameBorder.categoryBitMask = PhysicsCategory.Border
    gameBorder.contactTestBitMask = PhysicsCategory.Bird
    gameBorder.collisionBitMask = PhysicsCategory.None
    gameBorder.usesPreciseCollisionDetection = true
    self.physicsBody = gameBorder
    
    myBackground = SKSpriteNode(imageNamed: "background_fire")
    myBackground.anchorPoint = CGPoint.zero
    myBackground.position = CGPoint.init(x: 0, y: 0)
    addChild(myBackground)
    
    myLabel = SKLabelNode.init(fontNamed: "Chalkduster")
    myLabel.text = String("Press to Start!")
    myLabel.fontSize = 45
    myLabel.fontColor = SKColor.black
    myLabel.position = CGPoint.init(x: frame.midX , y: frame.midY * 1.5)
    addChild(myLabel)
    
    birdSprites.append(birdAtlas.textureNamed("player1"))
    birdSprites.append(birdAtlas.textureNamed("player2"))
    birdSprites.append(birdAtlas.textureNamed("player3"))
    birdSprites.append(birdAtlas.textureNamed("player4"))
    
    bird = SKSpriteNode(texture: birdSprites[0])
    //        bird.position = CGPoint.init(x: view.bounds.size.width/2, y: myFloor1.size.height + 20)
    bird.position = CGPoint.init(x: view.bounds.size.width/2, y: 200 + 100)
    bird.size.width = bird.size.width / 10
    bird.size.height = bird.size.height / 10
    
    bird.physicsBody = SKPhysicsBody(texture: bird.texture!, size: bird.size)
    bird.physicsBody?.isDynamic = true
    bird.physicsBody?.categoryBitMask = PhysicsCategory.Bird
    bird.physicsBody?.contactTestBitMask = PhysicsCategory.Floor
    bird.physicsBody?.collisionBitMask = PhysicsCategory.Floor
    bird.physicsBody?.usesPreciseCollisionDetection = true
    bird.physicsBody?.allowsRotation = false
    
    let animateBird = SKAction.animate(with: birdSprites, timePerFrame: 0.1)
    let repeatAction = SKAction.repeatForever(animateBird)
    self.bird.run(repeatAction)
    addChild(self.bird)
    
    myFloor1 = SKSpriteNode(imageNamed: "floor")
    myFloor2 = SKSpriteNode(imageNamed: "floor")
    // initial floor length randomization
    jumpNumber = Int(randomBetweenNumbers(firstNum: 6, secondNum: 7))
    floorLength = bird.size.width * CGFloat(jumpNumber)
    jumpLength = floorLength / CGFloat(jumpNumber)
    myFloor1.size.width = floorLength
    myFloor1.position = CGPoint(x: 0, y: 0)
    myFloor1.anchorPoint = CGPoint.zero
    myFloor2.size.width = floorLength
    myFloor2.position = CGPoint.init(x: myFloor1.size.width, y: myFloor1.position.y)
    myFloor2.anchorPoint = CGPoint.zero
    
    let adjustPoint = CGPoint(x: myFloor1.size.width / 2, y: myFloor1.size.height / 2)
    myFloor1.physicsBody = SKPhysicsBody(rectangleOf: myFloor1.size, center: adjustPoint)
    myFloor1.physicsBody?.isDynamic = false
    myFloor1.physicsBody?.restitution = 0.1
    
    myFloor2.physicsBody = SKPhysicsBody(rectangleOf: myFloor2.size, center: adjustPoint)
    myFloor2.physicsBody?.isDynamic = false
    myFloor2.physicsBody?.restitution = 0.1
    
    addChild(self.myFloor1)
    addChild(self.myFloor2)
  }
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard !dead else { return }
    
    start = true
    
    bird.position.x = bird.position.x + jumpLength
    bird.position.y = bird.position.y + 50
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    if (!start){
      myFloor1.position = CGPoint.init(x: myFloor1.position.x - 4, y: myFloor1.position.y)
      myFloor2.position = CGPoint.init(x: myFloor2.position.x - 4, y: myFloor2.position.y)
      
      // floor 1 is moved out create new floor 1
      if (myFloor1.position.x < -myFloor1.size.width){
        
        jumpNumber = Int(randomBetweenNumbers(firstNum: 6, secondNum: 7))
        
        myFloor1.position = CGPoint.init(x: myFloor2.position.x + myFloor2.size.width, y: myFloor1.position.y)
        
        floorLength = bird.size.width * CGFloat(jumpNumber)
        
        jumpLength = floorLength / CGFloat(jumpNumber)
        
        myFloor1.size.width = floorLength
      }
      
      // floor 2 is moved out create new floor 2
      if (myFloor2.position.x < -myFloor2.size.width){
        
        jumpNumber = Int(randomBetweenNumbers(firstNum: 6, secondNum: 7))
        
        myFloor2.position = CGPoint.init(x: myFloor1.position.x + myFloor1.size.width, y: myFloor2.position.y)
        
        floorLength = bird.size.width * CGFloat(jumpNumber)
        
        jumpLength = floorLength / CGFloat(jumpNumber)
        
        myFloor2.size.width = floorLength
      }
    }
    
    if (start) {
      
      if dead {
        guard myFloor1.position.y > -myFloor1.size.height else { return }
        myFloor1.position = CGPoint.init(x: myFloor1.position.x, y: myFloor1.position.y - 2)
        myFloor2.position = CGPoint.init(x: myFloor2.position.x, y: myFloor2.position.y - 2)
        
        myLabel.text = String("You killed the bird :(")
      }
      
      // if the bird is on the first floor
      if (myFloor1.position.x < bird.position.x && bird.position.x < myFloor1.position.x + myFloor1.size.width){
        
        onFloor1 = true
        onFloor2 = false
        
        // send floor1 to only show half of the screen
        if ( -myFloor1.size.width / 2 - 10 < myFloor1.position.x ){
          myFloor1.position = CGPoint.init(x: myFloor1.position.x - 4, y: myFloor1.position.y)
          bird.position = CGPoint.init(x: bird.position.x - 4, y: bird.position.y)
          
          // if bird is too far right of the screen move camera faster
          if (self.frame.size.width - 100 < bird.position.x && bird.position.x < self.frame.size.width + 100){
            myFloor1.position = CGPoint.init(x: myFloor1.position.x - 15, y: myFloor1.position.y)
            bird.position = CGPoint.init(x: bird.position.x - 15, y: bird.position.y)
            
            // send floor2 to flow along with floor1
            if (-myFloor2.size.width - 1 < myFloor2.position.x){
              myFloor2.position = CGPoint.init(x: myFloor2.position.x - 15, y: myFloor2.position.y)
            }
            
            // if bird is too far left of the screen move camera slower
          }else if(bird.position.x < 50){
            myFloor1.position = CGPoint.init(x: myFloor1.position.x + 3, y: myFloor1.position.y)
            bird.position = CGPoint.init(x: bird.position.x + 3, y: bird.position.y)
            
            // send floor2 to flow along with floor1
            if (-myFloor2.size.width - 1 < myFloor2.position.x){
              myFloor2.position = CGPoint.init(x: myFloor2.position.x + 3, y: myFloor2.position.y)
            }
          }
          
          // send floor2 to flow along with floor1
          if (-myFloor2.size.width - 1 < myFloor2.position.x){
            myFloor2.position = CGPoint.init(x: myFloor2.position.x - 4, y: myFloor2.position.y)
          }
        }
        
        if firstRun{
          
          // if bird is near the start of the floor send to start of the floor
          
          if (bird.position.x < myFloor1.position.x + myFloor1.size.width / 2){
            bird.position.x = myFloor1.position.x + bird.size.width / 2
          }
          
          // if bird is near the end send to the start of the next floor
          
          if (myFloor1.position.x + myFloor1.size.width / 2 < bird.position.x){
            bird.position.x = myFloor2.position.x + bird.size.width / 2
          }
          
          
          firstRun = false
        }
        
        // if the bird is on the second floor
      }else if (myFloor2.position.x < bird.position.x && bird.position.x < myFloor2.position.x + myFloor2.size.width){
        
        onFloor1 = false
        onFloor2 = true
        
        // send floor2 to only show half of the screen
        if ( -myFloor2.size.width / 2 - 10 < myFloor2.position.x ){
          myFloor2.position = CGPoint.init(x: myFloor2.position.x - 4, y: myFloor2.position.y)
          bird.position = CGPoint.init(x: bird.position.x - 4, y: bird.position.y)
          
          // if bird is too far right of the screen move camera faster
          if (self.frame.size.width - 100 < bird.position.x && bird.position.x < self.frame.size.width + 100){
            myFloor2.position = CGPoint.init(x: myFloor2.position.x - 15, y: myFloor2.position.y)
            bird.position = CGPoint.init(x: bird.position.x - 15, y: bird.position.y)
            
            // send floor1 to flow along with floor2
            if (-myFloor1.size.width - 1 < myFloor1.position.x){
              myFloor1.position = CGPoint.init(x: myFloor1.position.x - 15, y: myFloor1.position.y)
            }
            
            // if bird is too far left of the screen move camera slower
          }else if(bird.position.x < 50){
            myFloor2.position = CGPoint.init(x: myFloor2.position.x + 3, y: myFloor1.position.y)
            bird.position = CGPoint.init(x: bird.position.x + 3, y: bird.position.y)
            
            // send floor1 to flow along with floor2
            if (-myFloor1.size.width - 1 < myFloor1.position.x){
              myFloor1.position = CGPoint.init(x: myFloor1.position.x + 3, y: myFloor1.position.y)
            }
          }
          
          // send floor1 to flow along with floor2
          if (-myFloor1.size.width - 1 < myFloor1.position.x){
            myFloor1.position = CGPoint.init(x: myFloor1.position.x - 4, y: myFloor1.position.y)
          }
        }
        
        if firstRun{
          // if bird is near the start of the floor send to start of the floor
          
          if (bird.position.x < myFloor2.position.x + myFloor2.size.width / 2){
            bird.position.x = myFloor2.position.x + bird.size.width / 2
          }
          
          // if bird is near the end send to the start of the next floor
          
          if (myFloor2.position.x + myFloor2.size.width / 2 < bird.position.x){
            bird.position.x = myFloor1.position.x + bird.size.width / 2
          }
          
          firstRun = false
        }
      }
      
      // if floor 1 is moved out of the screen create new floor 1
      if (myFloor1.position.x < -myFloor1.size.width){
        jumpNumber = Int(randomBetweenNumbers(firstNum: 3, secondNum: 7))
        
        holeLength = randomBetweenNumbers(firstNum: 80, secondNum: 120)
        
        myFloor1.position = CGPoint.init(x: myFloor2.position.x + myFloor2.size.width + holeLength, y: myFloor1.position.y)
        
        floorLength = bird.size.width * CGFloat(jumpNumber)
        NSLog("FloorLength: \(floorLength), JumpNumber: \(jumpNumber)")
        
        jumpLength = floorLength / CGFloat(jumpNumber)
        
        myFloor1.size.width = floorLength
      }
      
      // if floor 2 is moved out of the screen create new floor 2
      if (myFloor2.position.x < -myFloor2.size.width){
        jumpNumber = Int(randomBetweenNumbers(firstNum: 3, secondNum: 7))
        
        holeLength = randomBetweenNumbers(firstNum: 80, secondNum: 120)
        
        myFloor2.position = CGPoint.init(x: myFloor1.position.x + myFloor1.size.width + holeLength, y: myFloor2.position.y)
        
        floorLength = bird.size.width * CGFloat(jumpNumber)
        NSLog("FloorLength: \(floorLength), JumpNumber: \(jumpNumber)")
        
        jumpLength = floorLength / CGFloat(jumpNumber)
        
        myFloor2.size.width = floorLength
      }
      
      // within the death area after floor 1
      if (myFloor1.position.x + myFloor1.size.width - bird.size.width / 2 + 10 < bird.position.x && bird.position.x < myFloor1.position.x + myFloor1.size.width + holeLength + bird.size.width / 2 - 10 && !dead){
        NSLog("im on floor1 edge gotta jump")
        myLabel.text = String("Jump \(jumpNumber) times!")
        
//        bird.position.x = myFloor2.position.x + bird.size.width / 2
        
        // within the death area after floor 2
      }else if (myFloor2.position.x + myFloor2.size.width - bird.size.width / 2 + 10 < bird.position.x && bird.position.x < myFloor2.position.x + myFloor2.size.width + holeLength + bird.size.width / 2 - 10 && !dead){
        NSLog("im on floor2 edge gotta jump")
        myLabel.text = String("Jump \(jumpNumber) times!")
        
//        bird.position.x = myFloor1.position.x + bird.size.width / 2
      }
    }
  }
  
  func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
    
    return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
  }
  
  func didBegin(_ contact: SKPhysicsContact) {
    var firstBody: SKPhysicsBody
    var secondBody: SKPhysicsBody
    
    if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
      firstBody = contact.bodyA
      secondBody = contact.bodyB
    }else{
      firstBody = contact.bodyB
      secondBody = contact.bodyA
    }
    
    if ((firstBody.categoryBitMask - PhysicsCategory.Bird == 0 ) &&
      (secondBody.categoryBitMask - PhysicsCategory.Border == 0)) && !dead{
      let bird = firstBody.node as! SKSpriteNode
      let border = secondBody.node as! SKScene
      birdFell(bird: bird, border: border)
    }
  }
  
  func birdFell(bird: SKSpriteNode, border: SKScene) {
    NSLog("Bird Down")
    bird.removeFromParent()
    dead = true
    let screenRect = CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
    let screen = UIView.init(frame: screenRect)
    screen.backgroundColor = UIColor.init(red: 1, green: 0.1, blue: 0.1, alpha: 0.5)
    
    self.view?.addSubview(screen)
  }
}
