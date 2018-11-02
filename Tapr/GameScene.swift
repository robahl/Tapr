//
//  GameScene.swift
//  Tapr
//
//  Created by Robert Ahlberg on 2018-09-18.
//  Copyright © 2018 Robert Ahlberg. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  var logo: SKSpriteNode?
  var counterLabel: SKLabelNode?
  var timeLabel: SKLabelNode?
  var tapZone: SKShapeNode?
  var startButton: SKSpriteNode?
  var scoreModal: SKNode?
  var readyNode: SKSpriteNode?
  
  let readySetGoTextures = [SKTexture(imageNamed: "ready"), SKTexture(imageNamed: "set"), SKTexture(imageNamed: "go")]
  
  var canTap = false
  
  var gameTime: Float = 10 {
    didSet {
      timeLabel?.text = String(format: "Time: %.1f", abs(gameTime))
    }
  }
  
  var gameTimer: Timer?
  
  var tapCount = 0 {
    didSet {
      counterLabel?.text = String(tapCount)
    }
  }
  
  override func didMove(to view: SKView) {
    logo = childNode(withName: "//title") as? SKSpriteNode
    counterLabel = childNode(withName: "//counterLabel") as? SKLabelNode
    timeLabel = childNode(withName: "//timeLabel") as? SKLabelNode
    startButton = childNode(withName: "//startButton") as? SKSpriteNode
    scoreModal = childNode(withName: "//scoreModal")
    
    readyNode = SKSpriteNode(texture: readySetGoTextures[0])
    readyNode?.position = CGPoint(x: 0, y: 0)
    
    // Background music
    addChild(SKAudioNode.init(fileNamed: "musicloop.aiff"))
    
    tapZone = SKShapeNode.init(rectOf: CGSize(width: 303, height: 542), cornerRadius: 5)
    tapZone?.name = "tapZone"
    tapZone?.position = CGPoint(x: 0, y: -50)
    tapZone?.fillColor = SKColor.init(red:0.98, green:1.00, blue:0.53, alpha:0.8)
    tapZone?.alpha = 0
    addChild(tapZone!)
    
    logo?.run(SKAction.repeatForever(SKAction.init(named: "Pulse")!))
    
    scoreModal?.isHidden = true
    timeLabel?.isHidden = true
    // Better to hide counter while playing?
    counterLabel?.isHidden = true
  }
  
  func startGame() {
    gameTime = 10
    tapCount = 0
    scoreModal?.isHidden = true
    timeLabel?.isHidden = false
    
    // reset scale
    readyNode?.xScale = 1
    readyNode?.yScale = 1
    
    let readyAnimation = SKAction.animate(with: readySetGoTextures, timePerFrame: 1)
    let scaleDown = SKAction.scale(by: 0.1, duration: 0.3)
    let gameTimerAction = SKAction.run({
      self.gameTimer = Timer.scheduledTimer(
        timeInterval: 0.1,
        target: self,
        selector: #selector(self.gameCountdown),
        userInfo: nil, repeats: true)
      
      self.canTap = true
    })
    
    let rsgSound = SKAction.sequence([
      SKAction.playSoundFileNamed("sReady.wav", waitForCompletion: true), // "Ready?"
      SKAction.playSoundFileNamed("sSet.wav", waitForCompletion: true), // "Set"
      SKAction.playSoundFileNamed("sGo.wav", waitForCompletion: true) // "GO!"
    ])
    
    readyNode?.run(rsgSound)
    readyNode?.run(SKAction.sequence([readyAnimation, gameTimerAction, scaleDown, SKAction.removeFromParent()]))
    addChild(readyNode!)
  }
  
  func gameOver() {
    canTap = false
    gameTime = 0
    let scoreLabel = scoreModal?.childNode(withName: "scoreLabel") as? SKLabelNode
    scoreLabel?.text = "\(tapCount) taps!!"
    timeLabel?.isHidden = true
    tapZone?.run(SKAction.fadeOut(withDuration: 0.3))
    startButton?.texture = SKTexture(imageNamed: "replay_button")
    startButton?.position = CGPoint(x: 0, y: 290)
    startButton?.run(SKAction.fadeIn(withDuration: 0.3))
    scoreModal?.isHidden = false
  }
  
  @objc func gameCountdown() {
    if gameTime <= 0.0 {
      gameTimer?.invalidate()
      gameOver()
    } else {
      gameTime -= 0.1
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Determine what node the user tapped
    if let touchPoint = touches.first?.location(in: self) {
      let touchedNode = atPoint(touchPoint)
      
      if touchedNode.name == "startButton" {
        // Touched start button
        startButton?.run(SKAction.fadeOut(withDuration: 0.3))
        logo?.run(SKAction.init(named: "ScaleDown")!)
        tapZone?.run(SKAction.fadeIn(withDuration: 0.5))
        startGame()
      } else if canTap && (tapZone?.frame.contains(touchPoint))! {
        // Touched inside the tapzone
        
        // Beep
        run(SKAction.playSoundFileNamed("beep.wav", waitForCompletion: false))
        
        // Touch feedback
        let tapDot = SKShapeNode.init(ellipseOf: CGSize(width: 34, height: 34))
        tapDot.name = "tapDot"
        tapDot.lineWidth = 0
        tapDot.fillColor = SKColor.init(white: 1, alpha: 0.35)
        tapDot.position = touchPoint
        let fadeOutAndRemove = SKAction.sequence([
          SKAction.fadeOut(withDuration: 0.3),
          SKAction.removeFromParent()
        ])
        tapDot.run(fadeOutAndRemove)
        tapDot.isUserInteractionEnabled = false
        addChild(tapDot)
        
        // Score
        tapCount += 1
      }
      
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
  }
  
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
  }
}
