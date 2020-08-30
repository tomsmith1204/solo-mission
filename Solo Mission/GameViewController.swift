//
//  GameViewController.swift
//  Solo Mission
//
//  Created by Tom Smith on 8/23/20.
//  Copyright © 2020 Tom Smith. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {

    var bgm = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "bgm", ofType: "wav")
        let audioNSURL = NSURL(fileURLWithPath: filePath!)
        
        do { bgm = try AVAudioPlayer(contentsOf: audioNSURL as URL)}
        catch { return print("ERROR: Can't find audio track for BGM!")}
        
        bgm.numberOfLoops = -1
        bgm.play()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            let scene = MainMenuScene(size: (CGSize(width: 1536, height: 2048)))
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
