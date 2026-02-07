//
//  BubbleView.swift
//  tgClone
//
//  Created by Андрей Чучупал on 23.10.2025.
//

import UIKit

final class BubbleView: UIView {
    
    var role: ChatRoles = .friend {
        didSet { setNeedsDisplay() }
    }

    init(role: ChatRoles) {
        super.init(frame: .zero)
        self.role = role
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.backgroundColor = .clear
    }

    override func draw(_ rect: CGRect) {
        let radius: CGFloat = 10
        let tailWidth: CGFloat = 6
        
        let isUser = (role == .user)
        
        let bubbleRect: CGRect
        if isUser {
            bubbleRect = CGRect(x: 0, y: 0, width: rect.width - tailWidth, height: rect.height)
        } else {
            bubbleRect = CGRect(x: tailWidth, y: 0, width: rect.width - tailWidth, height: rect.height)
        }
        
        let path = UIBezierPath()
        
        if isUser {
            path.move(to: CGPoint(x: radius, y: 0))
            path.addLine(to: CGPoint(x: bubbleRect.width - radius, y: 0))
            path.addArc(withCenter: CGPoint(x: bubbleRect.width - radius, y: radius),
                        radius: radius,
                        startAngle: -CGFloat.pi/2,
                        endAngle: 0,
                        clockwise: true)
            
            path.addLine(to: CGPoint(x: bubbleRect.width, y: bubbleRect.height - radius - 8))
            path.addCurve(to: CGPoint(x: rect.width, y: bubbleRect.height - 6),
                          controlPoint1: CGPoint(x: bubbleRect.width + 2, y: bubbleRect.height - radius - 6),
                          controlPoint2: CGPoint(x: rect.width - 1, y: bubbleRect.height - 8))
            path.addCurve(to: CGPoint(x: bubbleRect.width, y: bubbleRect.height - radius + 2),
                          controlPoint1: CGPoint(x: rect.width - 1, y: bubbleRect.height - 4),
                          controlPoint2: CGPoint(x: bubbleRect.width + 2, y: bubbleRect.height - radius + 4))
            
            path.addArc(withCenter: CGPoint(x: bubbleRect.width - radius, y: bubbleRect.height - radius),
                        radius: radius, startAngle: 0,
                        endAngle: CGFloat.pi/2,
                        clockwise: true)
            path.addLine(to: CGPoint(x: radius, y: bubbleRect.height))
            path.addArc(withCenter: CGPoint(x: radius, y: bubbleRect.height - radius),
                        radius: radius,
                        startAngle: CGFloat.pi/2, endAngle: CGFloat.pi,
                        clockwise: true)
            path.addLine(to: CGPoint(x: 0, y: radius))
            path.addArc(withCenter: CGPoint(x: radius, y: radius),
                        radius: radius, startAngle: CGFloat.pi,
                        endAngle: -CGFloat.pi/2,
                        clockwise: true)
            
        } else {
            path.move(to: CGPoint(x: tailWidth + radius, y: 0))
            path.addLine(to: CGPoint(x: rect.width - radius, y: 0))
            path.addArc(withCenter: CGPoint(x: rect.width - radius, y: radius),
                        radius: radius, startAngle: -CGFloat.pi/2,
                        endAngle: 0,
                        clockwise: true)
            path.addLine(to: CGPoint(x: rect.width, y: rect.height - radius))
            path.addArc(withCenter: CGPoint(x: rect.width - radius, y: rect.height - radius),
                        radius: radius, startAngle: 0,
                        endAngle: CGFloat.pi/2,
                        clockwise: true)
            path.addLine(to: CGPoint(x: tailWidth + radius, y: rect.height))
            path.addArc(withCenter: CGPoint(x: tailWidth + radius, y: rect.height - radius),
                        radius: radius, startAngle: CGFloat.pi/2,
                        endAngle: CGFloat.pi,
                        clockwise: true)
            
            path.addLine(to: CGPoint(x: tailWidth, y: rect.height - radius + 2))
            path.addCurve(to: CGPoint(x: 0, y: rect.height - 6),
                          controlPoint1: CGPoint(x: tailWidth - 2, y: rect.height - radius + 4),
                          controlPoint2: CGPoint(x: 1, y: rect.height - 4))
            path.addCurve(to: CGPoint(x: tailWidth, y: rect.height - radius - 8),
                          controlPoint1: CGPoint(x: 1, y: rect.height - 8),
                          controlPoint2: CGPoint(x: tailWidth - 2, y: rect.height - radius - 6))
            
            path.addArc(withCenter: CGPoint(x: tailWidth + radius, y: radius),
                        radius: radius, startAngle: CGFloat.pi,
                        endAngle: -CGFloat.pi/2,
                        clockwise: true)
        }
        
        path.close()
        
        let bubbleColor: UIColor = isUser
        ? UIColor(red: 0.83, green: 0.98, blue: 0.87, alpha: 1.0)
        : .white
        
        bubbleColor.setFill()
        path.fill()
    }
}
