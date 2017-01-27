//
//  GameScene.swift
//  Jump
//
//  Created by Jeff Eom on 2017-01-26.
//  Copyright © 2017 Jeff Eom. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var start = Bool(false)
    var onFloor1 = Bool(false)
    var onFloor2 = Bool(false)
    var firstJump = Bool(true)
    var myBackground = SKSpriteNode()
    var myFloor1 = SKSpriteNode()
    var myFloor2 = SKSpriteNode()
    let birdAtlas = SKTextureAtlas(named: "player.atlas")
    var birdSprites = Array<SKTexture>()
    var bird = SKSpriteNode()
    var jumpSpace = CGFloat(100)
    var floorLength = CGFloat(100)
    var birdJumpLength = CGFloat(50)
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor(red: 80.0/255.0, green: 192.0/255.0, blue: 203.0/255.0, alpha: 1.0)
        
        let bgm = SKAudioNode(fileNamed: "tapslow.mp3")
        bgm.autoplayLooped = true
        addChild(bgm)
        
        myBackground = SKSpriteNode(imageNamed: "background")
        myBackground.anchorPoint = CGPoint.zero
        myBackground.position = CGPoint.init(x: 0, y: 0)
        addChild(myBackground)
        
        myFloor1 = SKSpriteNode(imageNamed: "floor")
        myFloor2 = SKSpriteNode(imageNamed: "floor")
        floorLength = myFloor1.size.width / 1.5
        myFloor1.size.width = myFloor1.size.width / 1.5
        myFloor2.size.width = myFloor2.size.width / 1.5
        myFloor1.anchorPoint = CGPoint.zero
        myFloor1.position = CGPoint.init(x: 0, y: 0)
        myFloor2.anchorPoint = CGPoint.zero
        myFloor2.position = CGPoint.init(x: myFloor1.size.width, y: 10)
        addChild(self.myFloor1)
        addChild(self.myFloor2)
        
        birdSprites.append(birdAtlas.textureNamed("player1"))
        birdSprites.append(birdAtlas.textureNamed("player2"))
        birdSprites.append(birdAtlas.textureNamed("player3"))
        birdSprites.append(birdAtlas.textureNamed("player4"))
        
        bird = SKSpriteNode(texture: birdSprites[0])
        bird.position = CGPoint.init(x: view.bounds.size.width/2, y: myFloor1.size.height + 20)
        bird.size.width = bird.size.width / 10
        bird.size.height = bird.size.height / 10
        
        let animateBird = SKAction.animate(with: birdSprites, timePerFrame: 0.1)
        let repeatAction = SKAction.repeatForever(animateBird)
        self.bird.run(repeatAction)
        addChild(self.bird)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        start = true
        
        bird.position.x = bird.position.x + birdJumpLength
        
        NSLog("\(birdJumpLength) FJ?: \(firstJump)")
        firstJump = false
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        myFloor1.position = CGPoint.init(x: myFloor1.position.x - 4, y: myFloor1.position.y)
        myFloor2.position = CGPoint.init(x: myFloor2.position.x - 4, y: myFloor2.position.y)
        
        if (!start){
            if (myFloor1.position.x < -myFloor1.size.width){
                myFloor1.position = CGPoint.init(x: myFloor2.position.x + myFloor2.size.width, y: myFloor1.position.y)
                
                NSLog("boom 1 \(floorLength)")
            }
            
            if (myFloor2.position.x < -myFloor2.size.width){
                myFloor2.position = CGPoint.init(x: myFloor1.position.x + myFloor1.size.width, y: myFloor2.position.y)
                NSLog("boom 2")
            }
        }
        
        if (start) {
            bird.position = CGPoint.init(x: bird.position.x - 4, y: bird.position.y)
            
            if (myFloor1.position.x < -myFloor1.size.width){
                jumpSpace = randomBetweenNumbers(firstNum: 50, secondNum: 200)
                myFloor1.position = CGPoint.init(x: myFloor2.position.x + myFloor2.size.width + jumpSpace, y: myFloor1.position.y)
                
                floorLength = randomBetweenNumbers(firstNum: 200, secondNum: 500)
                NSLog("FloorLength: \(floorLength), JumpSpace: \(jumpSpace)")
                
                myFloor1.size.width = floorLength
                
            }
            
            if (myFloor1.position.x < bird.position.x && bird.position.x < myFloor1.position.x + myFloor1.size.width){
                
                onFloor1 = true
                onFloor2 = false
                
                if firstJump{
                    birdJumpLength = myFloor1.size.width / 5 - bird.size.width / 2
                }else{
                    birdJumpLength = myFloor1.size.width / 5
                }
                
            }else if (myFloor2.position.x < bird.position.x && bird.position.x < myFloor2.position.x + myFloor2.size.width){
                
                onFloor1 = false
                onFloor2 = true
                
                if firstJump{
                    birdJumpLength = myFloor2.size.width / 5 - bird.size.width / 2
                }else{
                    birdJumpLength = myFloor2.size.width / 5
                }
            }
            
            if (myFloor1.position.x + myFloor1.size.width < bird.position.x + bird.size.width / 2 && bird.position.x - bird.size.width / 2 < myFloor1.position.x + myFloor1.size.width + myFloor1.size.width / 5 ){
                NSLog("im on floor1 edge gotta jump")
                
                bird.position.x = myFloor2.position.x + bird.size.width / 2
                firstJump = true
                
            }else if (myFloor2.position.x + myFloor2.size.width < bird.position.x + bird.size.width / 2 && bird.position.x - bird.size.width / 2 < myFloor2.position.x + myFloor2.size.width + myFloor2.size.width / 5  ){
                NSLog("im on floor2 edge gotta jump")
                
                bird.position.x = myFloor1.position.x + bird.size.width / 2
                firstJump = true
            }
            
//            NSLog("1: \(myFloor1.position.x + floorLength - 100), birdPo: \(bird.position.x) ")
            
//            if ( myFloor1.position.x + floorLength - 100 < bird.position.x && bird.position.x < myFloor1.position.x + floorLength ){
//                
//                bird.position.x = bird.position.x + jumpSpace
//                
//                NSLog("hit1")
//                
//            }
            
            if (myFloor2.position.x < -myFloor2.size.width){
                jumpSpace = randomBetweenNumbers(firstNum: 80, secondNum: 200)
                myFloor2.position = CGPoint.init(x: myFloor1.position.x + myFloor1.size.width + jumpSpace, y: myFloor2.position.y)
                floorLength = randomBetweenNumbers(firstNum: 200, secondNum: 500)
                NSLog("FloorLength: \(floorLength), JumpSpace: \(jumpSpace)")

                myFloor2.size.width = floorLength
                

            }
            
//            if ( myFloor2.position.x + floorLength - 100 < bird.position.x && bird.position.x < myFloor2.position.x + floorLength ){
//                
//                bird.position.x = bird.position.x + jumpSpace
//                
//                NSLog("hit2")
//                
//            }
        }
    }
    
    func randomBetweenNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat{
        
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
        
    }
}
