//
//  GameScene.swift
//  gloopdrop
//
//  Created by Evgenii Ryshkov on 22.07.2021.
//

import SpriteKit
import GameplayKit
class GameScene: SKScene {
    let player = Player()

    override func didMove(to view: SKView) {
        // Set up background
        let background = SKSpriteNode(imageNamed: "background_1")
        background.anchorPoint = CGPoint.zero
        background.zPosition = Layer.background.rawValue;
        background.position = CGPoint(x: 0, y: 0)
        addChild(background)
        
        let foreground = SKSpriteNode(imageNamed: "foreground_1")
        foreground.anchorPoint = CGPoint.zero
        foreground.position = CGPoint(x: 0, y: 0)
        foreground.zPosition = Layer.foreground.rawValue
        addChild(foreground)
        
        player.position = CGPoint(x: size.width/2, y: foreground.frame.maxY)
        player.setupConstraints(floor: foreground.frame.maxY)
        addChild(player)
        player.walk()
    }

    // MARK: - TOUCH HANDLING

    func touchDown(atPoint pos: CGPoint) {
        if pos.x < player.position.x {
            player.moveToPosition(pos: pos, direction: "L", speed: 1)
        } else {
            player.moveToPosition(pos: pos, direction: "R", speed: 1)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.touchDown(atPoint: t.location(in: self))
        }
    }
}
