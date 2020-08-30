//
//  GameOverScene.swift
//  Solo Mission
//
//  Created by Tom Smith on 8/29/20.
//  Copyright © 2020 Tom Smith. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    
    // Settings.
    let gameFont: String
    
    // Images.
    let background: SKSpriteNode

    //Sounds.
    // TODO: Add.
    
    // Text.
    let gameOverLabel = SKLabelNode()
    let scoreLabel = SKLabelNode()
    let highScoreLabel = SKLabelNode()
    let restartLabel = SKLabelNode()
    
    override init(size: CGSize) {
    
        // Settings.
        gameFont = "The Bold Font"
        
        // Images.
        background = SKSpriteNode(imageNamed: "BackgroundA")
        
        //Sounds.
        // TODO: Add.
        
        // Text.
        gameOverLabel.fontName = gameFont
        scoreLabel.fontName = gameFont
        highScoreLabel.fontName = gameFont
        restartLabel.fontName = gameFont
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView){
        // Background setup.
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        // Game over label setup.
        gameOverLabel.text = "Game Over!"
        gameOverLabel.fontSize = 150
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.zPosition = 1
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        self.addChild(gameOverLabel)
        
        // Score label setup.
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        // High score setup.
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        if gameScore > highScoreNumber {
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        // High score label setup.
        highScoreLabel.text = "High Score: \(highScoreNumber)"
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.40)
        highScoreLabel.zPosition = 1
        self.addChild(highScoreLabel)
        
        // Restart game label setup.
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.2)
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            if restartLabel.contains(pointOfTouch) {
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }
    }
}
