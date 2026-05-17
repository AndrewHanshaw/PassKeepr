import SwiftUI

struct NoPassesToShow: View {
    var body: some View {
        VStack {
            Spacer()
            Text("Use the ＋ Button to Add a Pass")
                .font(Font.system(size: 24, weight: .bold, design: .rounded))
                .padding(.trailing, 32)
                .padding(.leading, 64)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
            HStack {
                Spacer()
                Image(systemName: "arrow.turn.down.right")
                    .font(.system(size: 36))
            }
        }
        .opacity(0.4)
        .padding(.bottom, -40)
        .padding(.trailing, 80)
    }
}

#Preview {
    NoPassesToShow()
}
