//
//  GameScene.swift
//  Solo Mission
//
//  Created by Tom Smith on 8/23/20.
//  Copyright © 2020 Tom Smith. All rights reserved.
//

import SpriteKit
import GameplayKit

// Publically available.

var highScore: Int = 0
var gameScore: Int = 0

class GameScene: SKScene, SKPhysicsContactDelegate {

    // Compute game area before init.
    var gameArea: CGRect {
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        return CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
    }
    
    // Settings.
    var currentGameState: GameState
    let gameFont: String
    var livesNumber: Int8
    var levelNumber: Int8
    
    // Images.
    let background: SKSpriteNode
    let player: SKSpriteNode
    
    // Sounds.
    let bulletSound: SKAction
    let explosionSound: SKAction
    
    // Text.
    let scoreLabel = SKLabelNode()
    let livesLabel = SKLabelNode()
    let tapToStartLabel = SKLabelNode()
    
    override init(size: CGSize) {
        
        // Game settings.
        currentGameState = GameState.preGame
        gameFont = "The Bold Font"
        livesNumber = 10
        levelNumber = 0
        gameScore = 0
        
        // Images.
        background = SKSpriteNode(imageNamed: "background")
        player = SKSpriteNode(imageNamed: "playerShip")
        
        // Sounds.
        bulletSound = SKAction.playSoundFileNamed("pew.wav", waitForCompletion: false)
        explosionSound = SKAction.playSoundFileNamed("pew.wav", waitForCompletion: false)
        
        // Text.
        scoreLabel.fontName = gameFont
        livesLabel.fontName = gameFont
        tapToStartLabel.fontName = gameFont
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView){
        
        self.physicsWorld.contactDelegate = self
        
        // Background setup.
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        // Player setup.
        player.setScale(0.75)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCatagories.Player
        player.physicsBody!.collisionBitMask = PhysicsCatagories.None
        player.physicsBody!.contactTestBitMask = PhysicsCatagories.Enemy
        self.addChild(player)
        
        // Score setup.
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 50
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.225, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
                
        // Lives setup.
        livesLabel.text = "Lives: \(livesNumber)"
        livesLabel.fontSize = 50
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.775, y: self.size.height + livesLabel.frame.size.height )
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        // Start prompt setup.
        tapToStartLabel.text = "Tap to Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
                let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        self.addChild(tapToStartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        switch currentGameState {
        case GameState.preGame:
            gameStart()
        case GameState.inGame:
            fireBullet()
        case GameState.afterGame:
            print("TODO: Implement after game touch event....")
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == GameState.inGame {
            for touch: AnyObject in touches{
                let pointOfTouch = touch.location(in: self)
                let previousPointOfTouch = touch.previousLocation(in: self)
                
                let amountDragged = pointOfTouch.x - previousPointOfTouch.x
                
                player.position.x += amountDragged
                
                if player.position.x > gameArea.maxX - player.size.width/2 {
                    player.position.x = gameArea.maxX - player.size.width/2
                }
                
                if player.position.x < gameArea.minX + player.size.width/2 {
                    player.position.x = gameArea.minX + player.size.width/2
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {

        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask  {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCatagories.Player && body2.categoryBitMask == PhysicsCatagories.Enemy {
            // If the player has hit the enemy.
            if body1.node != nil {
                loseALife()
                spawnExplosion(spawnPosition: body2.node!.position)
                
                if livesNumber < 1 {
                    body1.node?.removeFromParent()
                    gameOver()
                }
            }
            // If a bullet has hit the enemy.
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body2.node?.removeFromParent()
        }
        
        if let body2Node = body2.node {
            // Optional binding for body2 in case it is nil.
            if body1.categoryBitMask == PhysicsCatagories.Bullet && body2.categoryBitMask == PhysicsCatagories.Enemy && body2Node.position.y < self.size.height {
                // If the bullet has hit the enemy.
                if body2.node != nil {
                    spawnExplosion(spawnPosition: body2.node!.position)
                    addScore()
                }
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
            }
        }
    }
    
    func gameStart() {
        
        // Move SKNode objects into starting position.
        moveNode(node: scoreLabel, position: CGPoint(x: scoreLabel.position.x, y: self.frame.height*0.925), duration: 0.5)
        moveNode(node: livesLabel, position: CGPoint(x: livesLabel.position.x, y: self.frame.height*0.925), duration: 0.5)
        moveNode(node: player, position: CGPoint(x: player.position.x, y: self.frame.height*0.1), duration: 0.5)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let deleteNode = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOut, deleteNode])
        tapToStartLabel.run(deleteSequence)
        currentGameState = GameState.inGame
        startNewLevel()
    }
    
    func gameOver() {
        
        self.removeAllActions()
        removeActionsFromNode(nodeName: "Bullet")
        removeActionsFromNode(nodeName: "Enemy")
        
        currentGameState = GameState.afterGame
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([changeSceneAction, waitToChangeScene])
        self.run(changeSceneSequence)
    }
    
    func changeScene() {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    func removeActionsFromNode(nodeName: String) {
        self.enumerateChildNodes(withName: nodeName) { (node, stop) in
            node.removeAllActions()
        }
    }
    
    func startNewLevel() {
        
        levelNumber += 1
        if self.action(forKey: "spawningEnemies") != nil {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        switch levelNumber {
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            print("WARN: Cannot find level info")
            levelDuration = 0.5
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
    }
    
    func loseALife() {
        livesNumber -= 1
        
        livesLabel.text = "Lives: \(livesNumber)"
        
        if livesNumber < 1 {
            gameOver()
        }
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
    }
    
    
    func addScore() {

        gameScore+=1
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 10 || gameScore == 20 || gameScore == 30 {
            startNewLevel()
        }
    }
    
    func spawnExplosion(spawnPosition: CGPoint) {
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([explosionSound, scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 3
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCatagories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCatagories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCatagories.Enemy
        bullet.name = "Bullet"
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func spawnEnemy() {

        if currentGameState == GameState.inGame {
            let startPoint = CGPoint(x: getRandX(), y: self.size.height * 2)
            let endPoint = CGPoint(x: getRandX(), y: -self.size.height * 0.2)
            
            let enemy = SKSpriteNode(imageNamed: "enemyShip")
            enemy.setScale(0.85)
            enemy.zPosition = 3
            enemy.position = startPoint
            enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
            enemy.physicsBody!.affectedByGravity = false
            enemy.physicsBody!.categoryBitMask = PhysicsCatagories.Enemy
            enemy.physicsBody!.collisionBitMask = PhysicsCatagories.None
            enemy.physicsBody!.contactTestBitMask = PhysicsCatagories.Player | PhysicsCatagories.Bullet
            enemy.name = "Enemy"
            self.addChild(enemy)
            
            let moveEnemy = SKAction.move(to: endPoint, duration: 4)
            let deleteEnemy = SKAction.removeFromParent()
            let damagePlayer = SKAction.run(loseALife)
            let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, damagePlayer])
            enemy.run(enemySequence)
            
            let deltaX = endPoint.x - startPoint.x
            let deltaY = endPoint.y - startPoint.y
            let amountToRotate = atan2(deltaY, deltaX)
            enemy.zRotation = amountToRotate
        }
    }
    
    // Move node into place.
       func moveNode (node: SKNode, position: CGPoint, duration: TimeInterval) {
           let moveNode = SKAction.move(to: position, duration: duration)
           node.run(moveNode)
       }
    
    func getRandX() -> CGFloat {
        return CGFloat.random(in: gameArea.minX ..< gameArea.maxX)
    }
    
    // Enumeration for state.
    enum GameState {
        case preGame
        case inGame
        case afterGame
    }
    
    // Catagorize types of physics bodies.
    struct PhysicsCatagories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 // 1
        static let Bullet: UInt32 = 0b10 // 2
        static let Enemy: UInt32 = 0b100 // 4
    }
}
