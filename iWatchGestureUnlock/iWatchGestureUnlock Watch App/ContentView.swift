//
//  ContentView.swift
//  iWatchGestureUnlock Watch App
//
//  Created by Akira Le on 2023/9/5.
//

import SwiftUI
import CoreGraphics

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(x)
        hasher.combine(y)
    }
    
    public static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}


struct ContentView: View {
    var body: some View {
        GridUnlockView()
    }
}


struct GridUnlockView: View {
    @State private var selectedPoints: [CGPoint] = []
    @State private var errorMessage: String? // 错误消息

    var body: some View {
        GeometryReader { geometry in
//            var width = geometry.size.width / 3
            let height = (geometry.size.height - 14) / 3  // 从总高度中减去 14 为错误消息留出空间
            let width = (geometry.size.height - 14) / 3
            let fPadding = (geometry.size.width - geometry.size.height + 14)/2

            let points: [CGPoint] = [
                CGPoint(x: width / 2 + fPadding, y: height / 2),
                CGPoint(x: width * 1.5 + fPadding, y: height / 2),
                CGPoint(x: width * 2.5 + fPadding, y: height / 2),
                CGPoint(x: width / 2 + fPadding, y: height * 1.5),
                CGPoint(x: width * 1.5 + fPadding, y: height * 1.5),
                CGPoint(x: width * 2.5 + fPadding, y: height * 1.5),
                CGPoint(x: width / 2 + fPadding, y: height * 2.5),
                CGPoint(x: width * 1.5 + fPadding, y: height * 2.5),
                CGPoint(x: width * 2.5 + fPadding, y: height * 2.5)
            ]

            let pointToNumber: [CGPoint: Int] = Dictionary(uniqueKeysWithValues: zip(points, 1...9))

            VStack(spacing: 20) {
                Group {
                    if let message = errorMessage {
                        Text(message)
                            .foregroundColor(message == "成功" ? .green : .red)
                            .font(.headline)
                    } else {
                        Text("请输入手势")  // 当没有错误信息时显示一个空白文本
                    }
                }
                .frame(height: 14)  // 设定固定高度
                .padding(.horizontal)
                .background(Color.clear)
//                .cornerRadius(8)


                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    GridLines(points: selectedPoints)
                    GridPoints(points: points, pointToNumber: pointToNumber, selectedPoints: $selectedPoints, errorMessage: $errorMessage)
                }
            }
        }
    }
}



struct GridLines: View {
    var points: [CGPoint]
    
    var body: some View {
        Path { path in
            guard points.count > 1 else { return }
            
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
        }
        .stroke(style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
        .foregroundColor(Color(red: 1, green: 0.45, blue: 0.15))
    }
}

struct GridPoints: View {
    
    
    let points: [CGPoint]
    let pointToNumber: [CGPoint: Int]
    @Binding var selectedPoints: [CGPoint]
    @Binding var errorMessage: String?


    var body: some View {
        ZStack {
            ForEach(points, id: \.self) { point in
//                Circle()
//                    .fill(selectedPoints.contains(point) ? Color.green : Color.white)
//                    .frame(width: 44, height: 44)
//                    .position(point)
                
                // 外部圆环
                Circle()
                    .stroke(selectedPoints.contains(point) ? Color(red: 1, green: 0.45, blue: 0.15) : Color(red: 0.68, green: 0.68, blue: 0.68), lineWidth: 1)
                    .frame(width: 40, height: 40)
                    .position(point)
                
                // 中心实心小圆
                Circle()
                    .fill(selectedPoints.contains(point) ? Color(red: 1, green: 0.45, blue: 0.15) : Color(red: 0.68, green: 0.68, blue: 0.68))
                    .frame(width: 12, height: 12)
                    .position(point)
                
            }
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    let location = gesture.location
                    if let selectedPoint = points.first(where: { point in
                        let distance = sqrt(pow(location.x - point.x, 2) + pow(location.y - point.y, 2))
                        return distance < 25
                    }) {
                        if !selectedPoints.contains(selectedPoint) {
                            selectedPoints.append(selectedPoint)
                        }
                    }
                }
                .onEnded { _ in
                    let selectedNumbers = selectedPoints.compactMap { pointToNumber[$0] }
                    let pattern = selectedNumbers.map(String.init).joined()
                    if pattern == "14789" {
                        errorMessage = "成功"
                    } else {
                        errorMessage = "错误"
                    }
                    selectedPoints.removeAll()
                }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
