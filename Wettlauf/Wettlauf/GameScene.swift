//
//  GameScene.swift
//  Wettlauf
//
//  Created by Luis Reisewitz on 31.01.19.
//  Copyright © 2019 ZweiGraf. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    override func didMove(to view: SKView) {
        guard let backgroundMiddle1 = childNode(withName: "BackgroundMiddle1"),
            let backgroundMiddle2 = childNode(withName: "BackgroundMiddle2") else {
            fatalError()
        }

        let oneBackgroundWidth = backgroundMiddle1.frame.width
        let singleMoveDelta = -1 * oneBackgroundWidth
        let singleMoveDuration = 10.0
        let oneMove = SKAction.moveBy(x: singleMoveDelta, y: 0, duration: singleMoveDuration)
        let resetMove = SKAction.moveBy(x: oneBackgroundWidth * 2, y: 0, duration: 0)
        let repeatAction = SKAction.repeatForever(
            .sequence([
                oneMove,
                oneMove,
                resetMove]))
        backgroundMiddle1.run(.sequence([oneMove, resetMove, repeatAction]))
        backgroundMiddle2.run(repeatAction)

        guard let player = childNode(withName: "Player") else {
            fatalError()
        }

        let runFrameAtlas = SKTextureAtlas(named: "run")
        var runFrames = [SKTexture]()
        for i in 1...8 {
            runFrames.append(runFrameAtlas.textureNamed("run-\(i)"))
        }
        player.run(.repeatForever(.animate(with: runFrames,
                                           timePerFrame: 0.075,
                                           resize: false,
                                           restore: true)))

        guard let bottom1 = childNode(withName: "Bottom1"),
            let bottom2 = childNode(withName: "Bottom2"),
            let oneBox = bottom1.children.first else {
                fatalError()
        }

        let oneBottomWidth = oneBox.frame.width * 3
        let singleBottomDelta = -1 * oneBottomWidth
        let singleBottomDuration = 1.8
        let oneBottomMove = SKAction.moveBy(x: singleBottomDelta, y: 0, duration: singleBottomDuration)
        let resetBottomMove = SKAction.moveBy(x: oneBottomWidth * 2, y: 0, duration: 0)
        let repeatBottomAction = SKAction.repeatForever(
            .sequence([
                oneBottomMove,
                oneBottomMove,
                resetBottomMove]))
        bottom1.children.forEach { $0.run(.sequence([oneBottomMove, resetBottomMove, repeatBottomAction])) }
        bottom2.children.forEach { $0.run(repeatBottomAction) }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {

    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
