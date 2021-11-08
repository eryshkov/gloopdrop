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

    var level: Int = 1 {
        didSet {
            levelLabel.text = "Level: \(level)"
        }
    }

    var score: Int = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }

    var numberOfDrops: Int = 10

    var dropSpeed: CGFloat = 1
    var minDropSpeed: CGFloat = 0.12
    var maxDropSpeed: CGFloat = 1

    var scoreLabel: SKLabelNode = SKLabelNode()
    var levelLabel: SKLabelNode = SKLabelNode()

    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
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
        foreground.physicsBody = SKPhysicsBody(edgeLoopFrom: foreground.frame)
        foreground.physicsBody?.affectedByGravity = false
        foreground.physicsBody?.categoryBitMask = PhysicsCategory.foreground
        foreground.physicsBody?.contactTestBitMask = PhysicsCategory.collectible
        foreground.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(foreground)

        player.position = CGPoint(x: size.width / 2, y: foreground.frame.maxY)
        player.setupConstraints(floor: foreground.frame.maxY, sceneWidth: self.size.width)
        addChild(player)
        setupLabels()
        player.walk()
        swipeInit(to: self.view!)

        spawnMultipleGloops()
    }

    func setupLabels() {
        scoreLabel.name = "score"
        scoreLabel.fontName = "Nosifer"
        scoreLabel.fontColor = .yellow
        scoreLabel.fontSize = 35
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.zPosition = Layer.ui.rawValue
        scoreLabel.position = CGPoint(x: frame.maxX - 50, y: viewTop() - 100)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)

        levelLabel.name = "level"
        levelLabel.fontName = "Nosifer"
        levelLabel.fontColor = .yellow
        levelLabel.fontSize = 35
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.verticalAlignmentMode = .center
        levelLabel.zPosition = Layer.ui.rawValue
        levelLabel.position = CGPoint(x: frame.minX + 50, y: viewTop() - 100)
        levelLabel.text = "Level: \(level)"
        addChild(levelLabel)
    }

    func spawnGloop() {
        let collectible = Collectible(collectibleType: CollectibleType.gloop)

        let margin = collectible.size.width * 2
        let dropRange = SKRange(lowerLimit: frame.minX + margin, upperLimit: frame.maxX - margin)
        let randomX = CGFloat.random(in: dropRange.lowerLimit ... dropRange.upperLimit)

        collectible.position = CGPoint(x: randomX, y: player.position.y * 2.5)
        addChild(collectible)
        collectible.drop(dropSpeed: TimeInterval(1), floorLevel: player.frame.minY)
    }

    func spawnMultipleGloops() {
        switch level {
        case 1, 2, 3, 4, 5:
            numberOfDrops = level * 10
        case 6:
            numberOfDrops = 75
        case 7:
            numberOfDrops = 100
        case 8:
            numberOfDrops = 150
        default:
            numberOfDrops = 150
        }

        dropSpeed = 1 / (CGFloat(level) + (CGFloat(level) / CGFloat(numberOfDrops)))
        if dropSpeed < minDropSpeed {
            dropSpeed = minDropSpeed
        } else if dropSpeed > maxDropSpeed {
            dropSpeed = maxDropSpeed
        }

        let wait = SKAction.wait(forDuration: TimeInterval(dropSpeed))
        let spawn = SKAction.run { [unowned self] in self.spawnGloop() }
        let sequence = SKAction.sequence([wait, spawn])
        let repeatAction = SKAction.repeat(sequence, count: numberOfDrops)

        run(repeatAction, withKey: "gloop")
    }

    // MARK: - TOUCH HANDLING

    func swipeInit(to view: SKView) {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight(sender:)))
        swipeRight.direction = .right
        swipeRight.cancelsTouchesInView = true
        swipeRight.delaysTouchesBegan = true

        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft(sender:)))
        swipeLeft.direction = .left
        swipeLeft.cancelsTouchesInView = true
        swipeLeft.delaysTouchesBegan = true

        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
    }

    @objc func swipedRight(sender: UIGestureRecognizer) {
        player.moveToPosition(x: viewRight() - player.size.width / 2, direction: "R", speed: 1)
    }

    @objc func swipedLeft(sender: UIGestureRecognizer) {
        player.moveToPosition(x: viewLeft() + player.size.width / 2, direction: "L", speed: 1)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    public func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.player | PhysicsCategory.collectible {
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ? contact.bodyA.node : contact.bodyB.node
            if let sprite = body as? Collectible {
                sprite.collected()
                score += level
            }
        }

        if collision == PhysicsCategory.foreground | PhysicsCategory.collectible {
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ? contact.bodyA.node : contact.bodyB.node
            if let sprite = body as? Collectible {
                sprite.missed()
            }
        }
    }

    public func didEnd(_ contact: SKPhysicsContact) {
    }
}
