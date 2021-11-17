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
    var dropsExpected: Int = 10
    var dropsCollected: Int = 0

    var dropSpeed: CGFloat = 1
    var minDropSpeed: CGFloat = 0.12
    var maxDropSpeed: CGFloat = 1

    var scoreLabel: SKLabelNode = SKLabelNode()
    var levelLabel: SKLabelNode = SKLabelNode()

    var gameInProgress = false
//    var playingLevel = false

    override func update(_ currentTime: TimeInterval) {
//        checkForRemainingDrops()
    }

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
        swipeInit(to: self.view!)
        showMessage("Tap to start game")
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

        collectible.position = CGPoint(x: randomX, y: viewTop())
        addChild(collectible)
        collectible.drop(dropSpeed: TimeInterval(1), floorLevel: player.frame.minY)
    }

    func checkForRemainingDrops() {
//        guard playingLevel else {return}
        if dropsCollected == dropsExpected {
//            playingLevel = false
            nextLevel()
        }
    }

    func nextLevel() {
        showMessage("Get Ready!")
        let wait = SKAction.wait(forDuration: 2.25)
        run(wait) { [unowned self] in
            self.level += 1
            self.spawnMultipleGloops()
        }
    }

    func spawnMultipleGloops() {
        player.walk()
        if !gameInProgress {
            score = 0
            level = 1
        }

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

        dropsCollected = 0
        dropsExpected = numberOfDrops

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

        gameInProgress = true
        hideMessage()
//        playingLevel = true
    }

    func gameOver() {
        showMessage("Game Over\nTap to try again")
        gameInProgress = false
        resetPlayerPosition()
        popRemainingDrops()

        player.die()
        removeAction(forKey: "gloop")

        enumerateChildNodes(withName: "co_*") { (node, stop)  in
            node.removeAction(forKey: "drop")
            node.physicsBody = nil
        }
    }

    func resetPlayerPosition() {
        if player.position.x > frame.midX {
            player.moveToPosition(x: frame.midX, direction: .left, speed: player.movingSpeed * 2)
        } else {
            player.moveToPosition(x: frame.midX, direction: .right, speed: player.movingSpeed * 2)
        }
    }

    func popRemainingDrops() {
        var i = 0
        enumerateChildNodes(withName: "co_*") {
            (node, stop)  in
            let initialWait = SKAction.wait(forDuration: 1)
            let wait = SKAction.wait(forDuration: TimeInterval(0.15 * CGFloat(i)))
            let removeFromParent = SKAction.removeFromParent()
            let actionSequence = SKAction.sequence([initialWait, wait, removeFromParent])
            node.run(actionSequence)
            i += 1
        }
    }

    func showMessage(_ message: String) {
        let messageLabel = SKLabelNode()
        messageLabel.name = "message"
        messageLabel.position = CGPoint(x: frame.midX, y: player.frame.maxY + 100)
        messageLabel.zPosition = Layer.ui.rawValue

        messageLabel.numberOfLines = 2

        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: SKColor(red: 251/255, green: 155/255, blue: 24/255, alpha: 1),
            .backgroundColor: UIColor.clear,
            .font: UIFont(name: "Nosifer", size: 45),
            .paragraphStyle: paragraph
        ]

        messageLabel.attributedText = NSAttributedString(string: message, attributes: attributes)
        messageLabel.run(SKAction.fadeIn(withDuration: 0.25))
        addChild(messageLabel)
    }

    func hideMessage() {
        guard let messageLabel = childNode(withName: "//message") as? SKLabelNode else { return }

        messageLabel.run(
            SKAction.sequence([
                SKAction.fadeOut(withDuration: 0.25),
                SKAction.removeFromParent()
                              ])
        )
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
        player.removeAction(forKey: PlayerActionType.moving.rawValue)
        player.moveToPosition(x: viewRight() - player.size.width / 2, direction: .right, speed: player.movingSpeed)
    }

    @objc func swipedLeft(sender: UIGestureRecognizer) {
        player.removeAction(forKey: PlayerActionType.moving.rawValue)
        player.moveToPosition(x: viewLeft() + player.size.width / 2, direction: .left, speed: player.movingSpeed)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let _ = touches.first else { return }

        guard gameInProgress else {
            spawnMultipleGloops()
            return
        }

        player.removeAction(forKey: PlayerActionType.moving.rawValue)
    }
}

extension GameScene: SKPhysicsContactDelegate {
    public func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        if collision == PhysicsCategory.player | PhysicsCategory.collectible {
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ? contact.bodyA.node : contact.bodyB.node
            if let sprite = body as? Collectible {
                dropsCollected += 1
                sprite.collected()
                score += level
                checkForRemainingDrops()
            }
        }

        if collision == PhysicsCategory.foreground | PhysicsCategory.collectible {
            let body = contact.bodyA.categoryBitMask == PhysicsCategory.collectible ? contact.bodyA.node : contact.bodyB.node
            if let sprite = body as? Collectible {
//                dropsCollected += 1
//                sprite.collected()
//                score += level
//                checkForRemainingDrops()
                sprite.missed()
                gameOver()
            }
        }
    }

    public func didEnd(_ contact: SKPhysicsContact) {
    }
}
