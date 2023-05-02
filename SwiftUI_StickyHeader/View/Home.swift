//
//  Home.swift
//  SwiftUI_StickyHeader
//
//  Created by パク on 2023/05/02.
//

import SwiftUI

struct Home: View {

    @State var offsetY: CGFloat = 0

    var body: some View {

        GeometryReader { proxy in
            let safeAreaTop = proxy.safeAreaInsets.top

            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    HeaderView(safeAreaTop)
                        .offset(y: -offsetY)
                        .zIndex(1)

                    // Scroll Contant
                    VStack {
                        ForEach(1...10, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.blue.gradient)
                                .frame(height: 220)
                        }
                    }
                    .padding(15)
                    .zIndex(0)
                }
                .offset(coordinateSpace: .named("SCROLL")) { offset in
                    offsetY = offset
                }
            }
            .coordinateSpace(name: "SCROLL")
            .edgesIgnoringSafeArea(.top)
        }
    }

    // 三項演算子がわかりにくいのでこれでわかりやすくする
    // thresholdHightはアイコンを最大80で固定するための値
    func scrollProgress(with offsetY: CGFloat, thresholdHight: CGFloat = 80) -> CGFloat {
        //let progress = -(offsetY / 80) > 1 ? -1 : (offsetY < 0 ? 0 : (offsetY / 80))

        print("        offsetY : \(offsetY)")
        print("-(offsetY / 80) : \(-(offsetY / 80))")

        // 80: scroll閾値
        // 上にscrollしたoffsetが 80を超えたら -1を返す (上にscroll中は -1をずっと返す :: アイコンを -1 * 65 位置させるため)
        // 80を超えた領域内でスクロール中では、アイコンを -1 * 65 位置に固定させるため
        if -(offsetY / thresholdHight) > 1 {
            return -1
        } else {

            if offsetY > 0 {
                // 下に引っ張った場合、アイコンは元の位置から移動しない
                return 0
            } else {
                // 80まではスクロールと同時にアイコンを上に動かす (scrollOffset分ではなく、スクロールした (offset * 0.81)
                return offsetY / thresholdHight
            }
        }
    }

    @ViewBuilder
    func HeaderView(_ safeAreaTop: CGFloat) -> some View {

        // scrollした offsetYが 80を超えた場合、 -1
        //　scrollした offsetYが 80を超えていない場合、
        //let progress = -(offsetY / 80) > 1 ? -1 : (offsetY < 0 ? 0 : (offsetY / 80))
        let progress: CGFloat = scrollProgress(with: offsetY)


        VStack(spacing: 15) {

            // Custom TextField & ProfileIcon
            HStack(spacing: 15) {

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)

                    TextField("Search", text: .constant(""))
                        .tint(.white)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 15)
                .background {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.black)
                        .opacity(0.15)
                }
                // progress加減でTextFieldを表示 ~ 非表示させる
                .opacity(1 + progress)

                Button {

                } label: {
                    Image("Pic")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .background {
                            Circle()
                                .fill(.white)
                                .padding(-2)
                        }
                }
            }

            // 4 Custom Buttons
            HStack(spacing: 0) {
                CustomButton(symbolImage: "rectangle.portrait.and.arrow.forward", title: "Deposit") {
                }

                CustomButton(symbolImage: "dollarsign", title: "Withdraw") {
                }

                CustomButton(symbolImage: "qrcode", title: "QR Code") {
                }

                CustomButton(symbolImage: "qrcode.viewfinder", title: "Scanning") {
                }
            }
            // アイコンが上に移動するとともに、アイコンの間いのマージンを 0から 最大 -50 縮める
            .padding(.horizontal, -progress * 50)
            .padding(.top, 10)
            // MARK: Moving up when Scrolling Started
            // アイコンを 最大 65 offsetする
            .offset(y: progress * 65)

        }
        // TextFieldが非表示の代わりに表示させるもの
        .overlay(alignment: .topLeading) {
            Button {

            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .offset(x: 13, y: 10)
            .opacity(-progress)

        }
        .environment(\.colorScheme, .dark)
        .padding(.top, safeAreaTop + 10)
        .padding([.horizontal, .bottom], 15)
        .background(
            Rectangle()
                .fill(Color.red.gradient)
                .padding(.bottom, -progress * 85)
        )

    }

    @ViewBuilder
    func CustomButton(symbolImage: String, title: String, onClick: @escaping () -> Void) -> some View {

        // 80ではなく、40にすることで スクロール半分で progressを 0 ~ 1に計算
        let progress = scrollProgress(with: offsetY, thresholdHight: 40)

        Button {

        } label: {
            VStack(spacing: 8) {
                Image(systemName: symbolImage)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .frame(width: 35, height: 35)
                    .background {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(.white)
                    }

                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            // ヘッダー固定の場合、非表示
            .opacity(1 + progress)
            .overlay {

                // スクロールによって、元のアイコンを表示・非表示の反対に行われる
                // ヘッダー固定した場合、このアイコンだけが表示
                Image(systemName: symbolImage)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .offset(y: -10)
                    .opacity(-progress)
            }
        }
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct OffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    @ViewBuilder
    func offset(coordinateSpace: CoordinateSpace, completion: @escaping (CGFloat) -> Void) -> some View {
        self
            .overlay {
                GeometryReader { proxy in
                    let minY = proxy.frame(in: coordinateSpace).minY

                    Color.clear
                        .preference(key: OffsetKey.self, value: minY)
                        .onPreferenceChange(OffsetKey.self) { value in
                            completion(value)
                        }
                }
            }
    }
}





