//
//  GameScene.swift
//  Solo Mission
//
//  Created by Tom Smith on 8/23/20.
//  Copyright © 2020 Tom Smith. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {

    let gameArea: CGRect
    let background = SKSpriteNode(imageNamed: "background")
    let player = SKSpriteNode(imageNamed: "playerShip")
    let bulletSound = SKAction.playSoundFileNamed("pew.wav", waitForCompletion: false)
    let explosionSound = SKAction.playSoundFileNamed("pew.wav", waitForCompletion: false)
    
    struct PhysicsCatagories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 // 1
        static let Bullet: UInt32 = 0b10 // 2
        static let Enemy: UInt32 = 0b100 // 4
    }
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0 / 9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView){
        
        self.physicsWorld.contactDelegate = self
        
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCatagories.Player
        player.physicsBody!.collisionBitMask = PhysicsCatagories.None
        player.physicsBody!.contactTestBitMask = PhysicsCatagories.Enemy
        self.addChild(player)
        
        startNewLevel()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireBullet()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
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
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        if let body2Node = body2.node {
            // Optional binding for body2 in case it is nil.
            if body1.categoryBitMask == PhysicsCatagories.Bullet && body2.categoryBitMask == PhysicsCatagories.Enemy && body2Node.position.y < self.size.height {
                // If the bullet has hit the enemy.
                if body2.node != nil {
                    spawnExplosion(spawnPosition: body2.node!.position)
                }
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
            }
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
    
    func startNewLevel() {
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: 1)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever)
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
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    func spawnEnemy() {

        let startPoint = CGPoint(x: getRandX(), y: self.size.height * 2)
        let endPoint = CGPoint(x: getRandX(), y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1)
        enemy.zPosition = 3
        enemy.position = startPoint
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCatagories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCatagories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCatagories.Player | PhysicsCatagories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 2)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let amountToRotate = atan2(deltaY, deltaX)
        enemy.zRotation = amountToRotate
    }
    
    func getRandX() -> CGFloat {
        return CGFloat.random(in: gameArea.minX ..< gameArea.maxX)
    }
}
