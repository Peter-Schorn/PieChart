//
//  TestView.swift
//  PieChart
//
//  Created by Peter Schorn on 2/28/22.
//

import SwiftUI

struct TestView: View {
    
    @State private var angle = Angle.zero

    let animation = Animation.linear(duration: 1)

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack {
                    
                    let frame = geometry.frame(in: .local)
                    
                    Circle()
                        .strokeBorder(lineWidth: 2)
                    
                    Rectangle()
                        .fill(.green)
                        .frame(width: 20, height: 20)
                        .position(x: frame.midX, y: frame.midY)
                        .modifier(
                            RadialOffsetEffect(
                                radius: frame.width / 2,
                                angle: angle
                            )
                        )
                }
            }
            .animation(animation, value: angle)
            .aspectRatio(1, contentMode: .fit)
            .border(Color.black, width: 2)
            .padding()
            
            LabeledSlider(
                value: $angle.degrees,
                in: -360...360,
                format: .number.precision(.fractionLength(2)),
                label: "Angle"
            )
            .padding()
            
        }
        
    }
    
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .frame(width: 400, height: 600)
    }
}
