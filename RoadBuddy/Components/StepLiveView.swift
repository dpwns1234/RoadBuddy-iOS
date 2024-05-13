//
//  StepLiveView.swift
//  RoadBuddy
//
//  Created by 김예준 on 5/13/24.
//

import UIKit

final class StepLineView: UIView {
    var lineColor: UIColor = .brown
    var image: UIImage? // 이미지 속성 추가
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 캔버스에 그릴 선의 색과 두께 설정
        lineColor.setStroke()
        
        // 선을 그릴 경로 생성
        let path = UIBezierPath()
        path.lineWidth = 12
        path.lineCapStyle = .round
        
        // 시작점과 끝점 설정
        let startPoint = CGPoint(x: rect.minX + 8, y: rect.minY + rect.height/2) // 시작점을 변경
        let endPoint = CGPoint(x: rect.width - 8, y: startPoint.y) // 끝점을 변경
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        // 경로를 캔버스에 그림
        path.stroke()
        
        // 이미지를 시작점에 그림
        if let image = image {
            let circleSize = CGSize(width: 28, height: 28)
            let circleOrigin = CGPoint(x: startPoint.x - (circleSize.width/2) + 8, y: startPoint.y - (circleSize.height/2))
            let circleRect = CGRect(origin: circleOrigin, size: circleSize)
            let circlePath = UIBezierPath(ovalIn: circleRect)
            lineColor.setFill()
            circlePath.fill()
            
            let imageSize = CGSize(width: 20, height: 20) // 이미지 크기 설정
            let imageOrigin = CGPoint(x: startPoint.x - imageSize.width/2 + 8, y: startPoint.y - imageSize.height/2)
            let imageRect = CGRect(origin: imageOrigin, size: imageSize)
            
            image.draw(in: imageRect)
        }
    }
}
