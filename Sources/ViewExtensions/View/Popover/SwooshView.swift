//
//  SwooshView.swift
//  
//
//  Created by Ilya Senchukov on 08.10.2021.
//

import UIKit

public class SwooshView: UIView {

    public enum Direction {
        case left
        case up
        case right
        case down
    }

    private let color: UIColor

    private let direction: Direction

    init(color: UIColor, direction: Direction) {
        self.color = color
        self.direction = direction
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func draw(_ rect: CGRect) {
        let path = UIBezierPath()

        path.move(to: .init(x: rect.width, y: rect.height))
        path.addCurve(to: .init(x: 0, y: 0),
                      controlPoint1: .init(x: rect.width * 0.4, y: rect.height),
                      controlPoint2: .init(x: 0, y: rect.midY))
        path.addLine(to: .init(x: rect.width * 0.7, y: 0))
        path.addCurve(to: .init(x: rect.width, y: rect.height),
                      controlPoint1: .init(x: rect.width * 0.8, y: rect.midY),
                      controlPoint2: .init(x: rect.midX, y: rect.midY))

        color.set()
        path.fill()

        setDirection()
    }

}

private extension SwooshView {

    func setDirection() {
        switch direction {
            case .down:
                transform = CGAffineTransform(rotationAngle: 45)
            case .left:
                transform = CGAffineTransform(scaleX: -1, y: 1)
            case .right:
                break
            case .up:
                transform = CGAffineTransform(rotationAngle: -90)
        }
    }

}
