//
//  Player.swift
//  gloopdrop
//
//  Created by Evgenii Ryshkov on 08.08.2021.
//

import Foundation
import SpriteKit

enum PlayerAnimationType: String {
    case walk
}

class Player: SKSpriteNode {
    // MARK: - Properties
    private var walkTextures: [SKTexture]?
    
    // MARK: - INIT
    init() {
        let texture = SKTexture(imageNamed: "blob-walk_0")
        super.init(texture: texture, color: .clear, size: texture.size())
        self.walkTextures = self.loadTextures(atlas: "blob", prefix: "blob-walk_", startsAt: 0, stopsAt: 2)
        self.name = "player"
        self.setScale(1)
        self.anchorPoint = CGPoint(x: 0.5, y: 0)
        self.zPosition = Layer.player.rawValue;
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - METHODS

    func setupConstraints(floor: CGFloat) {
        let range = SKRange(lowerLimit: floor, upperLimit: floor)
        let lockToPlatform = SKConstraint.positionY(range)

        constraints = [lockToPlatform]
    }

    func walk() {
        guard let walkTextures = walkTextures else {
            preconditionFailure("Could not find textures")
        }
        
        startAnimation(textures: walkTextures, speed: 0.25, name: PlayerAnimationType.walk.rawValue, count: 0, resize: true, restore: true)
    }

    func moveToPosition(pos: CGPoint, direction: String, speed: TimeInterval) {
        switch direction {
        case "L":
            xScale = -abs(xScale)
        default:
            xScale = abs(xScale)
        }

        let moveAction = SKAction.move(to: pos, duration: speed)
        run(moveAction)
    }
}
