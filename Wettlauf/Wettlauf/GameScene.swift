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
    var player: SKNode {
        return childNode(withName: "Player")!
    }


    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        self.scaleMode = .aspectFit

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

        player.physicsBody?.restitution = 0
        player.physicsBody?.allowsRotation = false

        let runFrameAtlas = SKTextureAtlas(named: "run")
        var runFrames = [SKTexture]()
        for i in 1...8 {
            runFrames.append(runFrameAtlas.textureNamed("run-\(i)"))
        }
        player.run(.repeatForever(.animate(with: runFrames,
                                           timePerFrame: 0.075,
                                           resize: false,
                                           restore: true)),
                   withKey: "runanimation")

        guard let bottom1 = childNode(withName: "Bottom1"),
            let bottom2 = childNode(withName: "Bottom2"),
            let top1 = childNode(withName: "Top1"),
            let top2 = childNode(withName: "Top2"),
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
        top1.children.forEach { $0.run(.sequence([oneBottomMove, resetBottomMove, repeatBottomAction])) }

        bottom2.children.forEach { $0.run(repeatBottomAction) }
        top2.children.forEach { $0.run(repeatBottomAction) }
    }

    var jumpTimer: Timer?
    var playerGroundContacts = [SKPhysicsBody]()
    
    func touchDown(atPoint pos : CGPoint) {
        physicsWorld.gravity.dy *= -1
        player.yScale *= -1
        // TODO: reverse character model animation
        return
        let canJump = !playerGroundContacts.isEmpty
        guard canJump else { return }
        var count = 0
        jumpTimer?.invalidate()
        jumpTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                guard count < 5 else {
                    timer.invalidate()
                    self.jumpTimer = nil
                    return
                }
                count += 1
                self.player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 500))
        }
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 5000))

        let runFrameAtlas = SKTextureAtlas(named: "jump")
        var runFrames = [SKTexture]()
        for i in 1...4 {
            runFrames.append(runFrameAtlas.textureNamed("jump-\(i)"))
        }
        player.removeAction(forKey: "runanimation")
        player.run(.animate(with: runFrames,
                            timePerFrame: 0.1,
                            resize: false,
                            restore: false),
                   withKey: "jumpanimation")
    }
    
    func touchMoved(toPoint pos : CGPoint) {    }
    
    func touchUp(atPoint pos : CGPoint) {
        jumpTimer?.invalidate()
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

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        var grounded = false
        if contact.bodyA == player.physicsBody {
            playerGroundContacts.append(contact.bodyB)
            grounded = true
        }
        if contact.bodyB == player.physicsBody {
            playerGroundContacts.append(contact.bodyA)
            grounded = true
        }
        if grounded {
            let runFrameAtlas = SKTextureAtlas(named: "run")
            var runFrames = [SKTexture]()
            for i in 1...8 {
                runFrames.append(runFrameAtlas.textureNamed("run-\(i)"))
            }

            player.removeAction(forKey: "jumpanimation")
            guard player.action(forKey: "runanimation") == nil else { return }
            player.run(.repeatForever(.animate(with: runFrames,
                                               timePerFrame: 0.075,
                                               resize: false,
                                               restore: true)),
                       withKey: "runanimation")
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        if contact.bodyA == player.physicsBody {
            playerGroundContacts.delete(body: contact.bodyB)
        }
        if contact.bodyB == player.physicsBody {
            playerGroundContacts.delete(body: contact.bodyA)
        }
    }
}

extension Array where Element == SKPhysicsBody {
    mutating func delete(body: SKPhysicsBody) {
        guard let index = self.firstIndex(of: body) else { return }
        self.remove(at: index)
    }
}
