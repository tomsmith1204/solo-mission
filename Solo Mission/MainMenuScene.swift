//
//  MainMenuScene.swift
//  Solo Mission
//
//  Created by Tom Smith on 8/29/20.
//  Copyright © 2020 Tom Smith. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    
    // Images.
    let background: SKSpriteNode
    
    // Text.
    let gameFont: String
    var gameBy = SKLabelNode()
    var gameName1 = SKLabelNode()
    var gameName2 = SKLabelNode()
    var startGame = SKLabelNode()
    
    
    override init(size: CGSize) {
        // Images.
        background = SKSpriteNode(imageNamed: "background")
        background.zPosition = 0
        
        
        //Text.
        gameFont = "The Bold Font"
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        // Set background size.
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        self.addChild(background)
        
        // Set up labels.
        gameBy = makeLabel(text: "CloudSmith Interactive", fontSize: 50,fontColor: SKColor.white,
        position: CGPoint(x: self.size.width*0.5, y: self.size.height*0.78))
        self.addChild(gameBy)
        
        gameName1 = makeLabel(text: "Solo", fontSize: 200,fontColor: SKColor.white,
        position: CGPoint(x: self.size.width*0.5, y: self.size.height*0.7))
        self.addChild(gameName1)
        
        gameName2 = makeLabel(text: "Mission", fontSize: 200,fontColor: SKColor.white,
        position: CGPoint(x: self.size.width*0.5, y: self.size.height*0.625))
        self.addChild(gameName2)
        
        startGame = makeLabel(text: "Start Game", fontSize: 150,fontColor: SKColor.white,
        position: CGPoint(x: self.size.width*0.5, y: self.size.height*0.4))
        startGame.name = "startButton"
        self.addChild(startGame)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            let nodeITouched = atPoint(pointOfTouch)
            
            if nodeITouched.name == "startButton" {
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
            
        }
        
    }
    func makeLabel(text: String, fontSize: CGFloat, fontColor: SKColor, position: CGPoint) -> SKLabelNode {
        let labelNode = SKLabelNode(fontNamed: gameFont)
        labelNode.text = text
        labelNode.fontSize = fontSize
        labelNode.fontColor = fontColor
        labelNode.position = position
        labelNode.zPosition = 1
        return labelNode
    }
}
