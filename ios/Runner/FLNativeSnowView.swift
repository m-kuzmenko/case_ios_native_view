import Flutter
import UIKit

class FLNativeSnowViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        print("was create FLNativeSnowViewFactory")
        return FLNativeSnowView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }
}

class FLNativeSnowView: NSObject, FlutterPlatformView {
    private var _view: SnowView

    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        _view = SnowView()
        super.init()
        let colors = [
            UIColor.blue,
        ]
        
        let channel = FlutterMethodChannel(
            name: "com.case_ios_native_view/snow" + String(viewId),
            binaryMessenger: messenger
        )

        channel.setMethodCallHandler({
            (call: FlutterMethodCall, result: FlutterResult) -> Void in
            if (call.method == "startAnimation") {
                self._view.start(colors: colors, duration: 8.0)
            }
        })
        
        print("was init FLNativeSnowView")
    }

    func view() -> UIView {
        return _view
    }
}

private class SnowView: UIView {
    override class var layerClass: AnyClass {
        CAEmitterLayer.self
    }
    
    private var completion: ((Bool) -> Void)?

    private var emitLayer: CAEmitterLayer? {
        layer as? CAEmitterLayer
    }
        
    override func layoutSubviews() {
        super.layoutSubviews()
        
        emitLayer?.emitterSize = CGSize(width: frame.size.width, height: 1.0)
        emitLayer?.emitterPosition = CGPoint(x: frame.size.width / 2.0, y: 0)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        emitLayer?.emitterMode = .outline
        emitLayer?.emitterShape = .line
        
        print("was init SnowView")
    }
    
    @available(*, unavailable)
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func start(
        colors: [UIColor],
        duration: TimeInterval,
        completion: ((Bool) -> Void)? = nil
    ) {
        self.completion = completion
        layer.removeAllAnimations()

        configure(colors: colors)

        emitLayer?.birthRate = 1.0

        let animation = CAKeyframeAnimation(keyPath: #keyPath(CAEmitterLayer.birthRate))
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeIn)
        animation.values = [1, 2, 0]
        animation.keyTimes = [0, 0.5, 1]
        animation.isRemovedOnCompletion = true
        animation.delegate = self
        emitLayer?.add(animation, forKey: nil)
        print("was start SnowView")
        if self.window != nil {
            print("UIView добавлено в иерархию и отображается")
        } else {
            print("UIView еще не добавлено в иерархию")
        }
    }

    private func configure(colors: [UIColor]) {
        emitLayer?.emitterCells = colors.map { color in
            let cell = CAEmitterCell()

            cell.birthRate = 30.0
            cell.lifetime = 10.0
            cell.velocity = 500
            cell.velocityRange = cell.velocity / 2
            cell.emissionLongitude = .pi
            cell.emissionRange = .pi / 4
            cell.spinRange = .pi * 8
            cell.scaleRange = 1
            cell.scale = 0.1
            cell.contents = color.snowflakeImage.cgImage
            cell.color = color.cgColor
            cell.beginTime = CACurrentMediaTime()

            return cell
        }
        print("was configure SnowView")
    }
}

 extension SnowView: CAAnimationDelegate {
     func animationDidStart() {
         print("Анимация началась")
     }
     func animationDidStop(_ animation: CAAnimation, finished flag: Bool) {
          emitLayer?.birthRate = 0
          completion?(flag)
          print("was animationDidStop SnowView", animation, flag)
          if flag {
             print("Анимация завершилась успешно")
           } else {
             print("Анимация была прервана")
           }
     }
 }

 private extension UIColor {
     var snowflakeImage: UIImage {
             let rect = CGRect(origin: .zero, size: CGSize(width: 10, height: 10))
             return UIGraphicsImageRenderer(size: rect.size).image { context in
                 let cgContext = context.cgContext
                 
                 cgContext.setFillColor(UIColor.clear.cgColor)
                 
                 cgContext.setStrokeColor(self.cgColor)
                 cgContext.setLineWidth(2.0)
                 
                 let center = CGPoint(x: rect.midX, y: rect.midY)
                 
                 let radius: CGFloat = 20.0
                 
                 let numberOfRays = 6
                 
                 for i in 0..<numberOfRays {
                     let angle = CGFloat(i) * (2 * .pi / CGFloat(numberOfRays))
                     let endX = center.x + radius * cos(angle)
                     let endY = center.y + radius * sin(angle)
                     
                     cgContext.move(to: center)
                     cgContext.addLine(to: CGPoint(x: endX, y: endY))
                     
                     let branchLength: CGFloat = radius / 3.0
                     let branchAngle: CGFloat = .pi / 6.0
                     
                     let branch1X = endX - branchLength * cos(angle - branchAngle)
                     let branch1Y = endY - branchLength * sin(angle - branchAngle)
                     cgContext.move(to: CGPoint(x: endX, y: endY))
                     cgContext.addLine(to: CGPoint(x: branch1X, y: branch1Y))
                     
                     let branch2X = endX - branchLength * cos(angle + branchAngle)
                     let branch2Y = endY - branchLength * sin(angle + branchAngle)
                     cgContext.move(to: CGPoint(x: endX, y: endY))
                     cgContext.addLine(to: CGPoint(x: branch2X, y: branch2Y))
                 }
                 
                 cgContext.strokePath()
             }
         }

     static var blue: UIColor {
         return UIColor(red: 0.5, green: 0.5, blue: 1, alpha: 1.00)
     }
 }
