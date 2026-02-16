//
//  Untitled.swift
//  xdrip
//
//  Created by Denis Shishmarev on 13.02.2026.
//  Copyright © 2026 Johan Degraeve. All rights reserved.
//

import UIKit

final class BloodGlucoseAgeCircularBarView: UIView {
    private enum Constants {
        static let totalDuration: TimeInterval = 10 * 60
        static let greenThreshold: TimeInterval = 5 * 60
        
        static let lineWidth: CGFloat = 10
        static let inset: CGFloat = 2
        
        static let timeFontSize: CGFloat = 12
        
        static let textEmpty = "--:--"
        static let textStale = Texts_Common.stale
        static let textTimeFormat = "%02d:%02d"
    }
    
    private let trackLayer = CAShapeLayer()
    private let progressLayer = CAShapeLayer()
    private let timeLabel = UILabel()
    
    private var timer: Timer?
    private var startDate: Date?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit { timer?.invalidate() }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }
    
    func setDate(_ date: Date) {
        if let currentStartDate = startDate {
            if date > currentStartDate {
                startDate = date
            }
        } else {
            startDate = date
        }
        
        startTimerIfNeeded()
        tick()
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        isOpaque = false
        backgroundColor = .clear
        
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = UIColor(white: 1.0, alpha: 0.15).cgColor
        trackLayer.lineWidth = Constants.lineWidth
        trackLayer.lineCap = .round
        layer.addSublayer(trackLayer)
        
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = UIColor.green.cgColor
        progressLayer.lineWidth = Constants.lineWidth
        progressLayer.lineCap = .round
        progressLayer.strokeEnd = 0
        layer.addSublayer(progressLayer)
        
        timeLabel.font = UIFont.monospacedDigitSystemFont(ofSize: Constants.timeFontSize, weight: .semibold)
        timeLabel.textAlignment = .center
        timeLabel.textColor = .white
        timeLabel.text = Constants.textEmpty
        timeLabel.numberOfLines = 1
        addSubview(timeLabel)
    }
    
    private func updatePath() {
        let lineWidth = trackLayer.lineWidth
        let radius = min(bounds.width, bounds.height) / 2 - lineWidth / 2
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let start = -CGFloat.pi / 2
        let end = start + 2 * CGFloat.pi
        
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        trackLayer.path = path.cgPath
        progressLayer.path = path.cgPath
        timeLabel.frame = bounds.insetBy(dx: Constants.inset, dy: Constants.inset)
    }
    
    private func startTimerIfNeeded() {
        guard timer == nil else { return }
        guard let startDate else { return }
        guard Date().timeIntervalSince(startDate) < Constants.totalDuration else { return }
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        RunLoop.main.add(timer!, forMode: .common)
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard let startDate else { return }
        let color: UIColor
        let elapsed = Date().timeIntervalSince(startDate)
        
        let progress = max(0, min(elapsed / Constants.totalDuration, 1))
        progressLayer.strokeEnd = CGFloat(progress)
        
        let total = max(0, Int(elapsed))
        timeLabel.text = String(format: Constants.textTimeFormat, total / 60, total % 60)
        
        if elapsed < Constants.greenThreshold {
            color = UIColor.green
        } else if elapsed < Constants.totalDuration {
            color = UIColor.yellow
        } else {
            color = UIColor.red
            timeLabel.text = Constants.textStale
            stopTimer()
        }
        
        progressLayer.strokeColor = color.cgColor
    }
}
