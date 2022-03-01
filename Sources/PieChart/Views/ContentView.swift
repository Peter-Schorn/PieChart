//
//  ContentView.swift
//  PieChart
//
//  Created by Peter Schorn on 2/23/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var configuration = PieChartConfiguration(
        highlightBehavior: .mouseHover,
        innerRadius: 0.5,
        [
            PieSliceConfiguration(
                title: "Rent",
                fill: .red,
                amount: 50
            ) {
                Text("Rent")
                    .onTapGesture {
                        print("tapped Rent")
                    }
            },
            PieSliceConfiguration(
                title: "Food",
                fill: .blue,
                amount: 100.2999123
            ) {
                Text("Food")
                    .onTapGesture {
                        print("tapped Food")
                    }
            },
            PieSliceConfiguration(
                title: "Gas",
                fill: .green,
                amount: 200
            ) {
                Text("Gas")
                    .onTapGesture {
                        print("tapped Gas")
                    }
            },
            PieSliceConfiguration(
                title: "Fun",
                fill: .orange,
                amount: 20
            ) {
                Text("Fun")
                    .onTapGesture {
                        print("tapped Fun")
                    }
            }
        ]
    )

    @State private var rotationIncrement: Double = 20

    let animation = Animation.linear(duration: 2)

    var body: some View {
        VStack {
            PieChartView(
                configuration: configuration
            ) {
                PieChartCenterView(configuration: configuration)
            }
            
            HStack {
                Button("Increment Rotation") {
//                    withAnimation(self.animation) {
                        self.configuration.rotation += .degrees(
                            rotationIncrement
                        )
//                    }
                }
                .keyboardShortcut("i")
                .help("⌘I")
                TextField(
                    "",
                    value: $rotationIncrement,
                    format: .number.precision(.fractionLength(0)),
                    prompt: Text("Increment")
                )
                .frame(width: 100)
            }
            
            Group {
                LabeledSlider(
                    value: $configuration.rotation.degrees,
                    in: -360...360,
                    format: .number.precision(.fractionLength(2)),
                    label: "Rotation"
                )
            }
            .padding(.horizontal)
            
        }
        .padding()
        .animation(self.animation, value: configuration.rotation)
        
//        .onAppear {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                self.shuffleSlices()
//            }
//        }
    }

    func changeRotation() {
        withAnimation {
            self.configuration.rotation = .degrees(90)
        }
    }
    
    func shuffleSlices() {
        withAnimation {
//            self.configuration.slices.shuffle()
            let temp = self.configuration.slices[0]
            self.configuration.slices[0] = self.configuration.slices[1]
            self.configuration.slices[1] = temp
        }
    }

}


struct ContentView_Previews: PreviewProvider {
    
    static let gradient = RadialGradient(
        colors: [.blue, .purple, .red],
        center: .center,
        startRadius: 0,
        endRadius: 500
    )
    
    static let gradient2 = LinearGradient(
        colors: [.blue, .purple, .red],
        startPoint: .top,
        endPoint: .bottom
    )

    static var previews: some View {
        ContentView()
            .background()
            .frame(width: 400)
            .preferredColorScheme(.light)
            .previewLayout(.sizeThatFits)
         
    }
}
