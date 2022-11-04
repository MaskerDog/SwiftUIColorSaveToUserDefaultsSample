//
//  ContentView.swift
//  UserDefaultsSample
//
//  Created by npc on 2022/11/04.
//

import SwiftUI

struct ContentView: View {
    private static let gradientColors: [(start: Color, end: Color)] = [
        (.init(hex: "#ff9a9e"), .init(hex: "#fad0c4")), // 0
        (.init(hex: "#a18cd1"), .init(hex: "#fbc2eb")), // 1
        (.init(hex: "#f6d365"), .init(hex: "#fda085")), // 2
        (.init(hex: "#fbc2eb"), .init(hex: "#a6c1ee"))  // 3
    ]
    
    @State var backgroundGradientColor: [Color] = [.init(hex: "#6a85b6"), .init(hex: "#bac8e0")]
    @State var selection: Int = -1
    
    let colorOptions = ["ピンク",  // 0
                        "濃い紫",  // 1
                        "オレンジ", // 2
                        "ピンク紫"  // 3
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(colors: backgroundGradientColor, startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack {
                Spacer()
                Text("UserDefault\nSamples")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(height: 100)
                Spacer()
                Picker(selection: $selection) {
                    Text("未選択").tag(-1)
                        .font(.system(size: 20, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    ForEach(0..<colorOptions.count, id: \.self) { number in
                        Text(colorOptions[number])
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                } label: {
                    Text("色を選択してください")
                    
                }
                .onChange(of: selection) { newSelection in
                    print(newSelection)
                    if newSelection < 0 { return }
                    backgroundGradientColor = [Self.gradientColors[newSelection].start, Self.gradientColors[newSelection].end]
                    
                    
                    let jsonEncoder = JSONEncoder()
                    guard let startColorData = try? jsonEncoder.encode(Self.gradientColors[newSelection].start) else {
                        return
                    }
                    guard let endColorData = try? jsonEncoder.encode(Self.gradientColors[newSelection].end) else {
                        return
                    }
                    
                    UserDefaults.standard.set(startColorData, forKey: "startColorData")
                    
                    UserDefaults.standard.set(endColorData, forKey: "endColorData")
                    
                    
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
                .frame(maxHeight: 200)
                .frame(minHeight: 150)
                .frame(minHeight: 150)
                .frame(minWidth: 375)
                Spacer(minLength: 50)
                
            }
        }
        .ignoresSafeArea()
        .onAppear {
            let jsonDecoder = JSONDecoder()
            
            guard let startColorData = UserDefaults.standard.data(forKey: "startColorData"),
                  let endColorData =  UserDefaults.standard.data(forKey: "endColorData"),
                  let startColor = try? jsonDecoder.decode(Color.self, from: startColorData),
                  let endColor = try? jsonDecoder.decode(Color.self, from: endColorData) else { return }
            
            backgroundGradientColor = [startColor, endColor]
            
            
        }
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension Color {
    
    /// 16進数表現の色文字列からColorを生成する。
    /// 色文字列からColorが生成ができない場合は**黒のColor**を生成する。
    /// - Parameters:
    ///   - hex: 16進数の色文字列
    ///   - opacity: 透明度
    init(hex: String, opacity: CGFloat = 1.0) {
        let hexFormatted = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 文字数が6じゃない場合は不正文字列
        guard hexFormatted.count == 6 else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }
        
        var rgbValue: UInt64 = 0
        // String値をInt64にする。できない場合は不正文字列
        guard Scanner(string: hexFormatted).scanHexInt64(&rgbValue) else {
            self.init(red: 0, green: 0, blue: 0)
            return
        }
        
        
        
        self.init(red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: Double((rgbValue & 0x0000FF)) / 255.0,
                  opacity: opacity)
    }
}

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red
        case green
        case blue
        case opacity
    }
    
    public func encode(to encoder: Encoder) throws {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        try container.encode(red, forKey: .red)
        try container.encode(green, forKey: .green)
        try container.encode(blue, forKey: .blue)
        try container.encode(opacity, forKey: .opacity)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let opacity = try container.decode(Double.self, forKey: .opacity)
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
