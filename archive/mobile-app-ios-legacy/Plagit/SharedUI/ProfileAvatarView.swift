//
//  ProfileAvatarView.swift
//  Plagit
//
//  Reusable avatar that shows a real photo (from base64 data URL) or falls back to gradient initials.
//

import SwiftUI

struct ProfileAvatarView: View {
    let photoUrl: String?
    let initials: String
    let hue: Double
    let size: CGFloat
    var verified: Bool = false
    var countryCode: String? = nil

    var body: some View {
        ZStack {
            if let image = decodedImage {
                Image(uiImage: image)
                    .resizable().scaledToFill()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(hue: hue, saturation: 0.40, brightness: 0.92), Color(hue: hue, saturation: 0.55, brightness: 0.78)],
                        startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: size, height: size)
                    .overlay(
                        Text(initials)
                            .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    )
            }

            // Verification badge — bottom-right
            if verified {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: size * 0.22))
                    .foregroundColor(.plagitVerified)
                    .background(Circle().fill(.white).frame(width: size * 0.18, height: size * 0.18))
                    .frame(width: size, height: size, alignment: .bottomTrailing)
                    .offset(x: size * 0.04, y: size * 0.04)
            }

            // Country flag badge — bottom-left
            if let code = countryCode, !code.isEmpty {
                let flag = CountryFlag.emoji(for: code)
                if !flag.isEmpty {
                    Text(flag)
                        .font(.system(size: size * 0.22))
                        .frame(width: size * 0.28, height: size * 0.28)
                        .background(Circle().fill(.white).shadow(color: .black.opacity(0.12), radius: 2, y: 1))
                        .frame(width: size, height: size, alignment: .bottomLeading)
                        .offset(x: -(size * 0.04), y: size * 0.04)
                }
            }
        }
        .frame(width: size, height: size)
    }

    private var decodedImage: UIImage? {
        guard let photoUrl, !photoUrl.isEmpty else { return nil }

        // Strip the data URI prefix if present
        let base64String: String
        if let range = photoUrl.range(of: ";base64,") {
            base64String = String(photoUrl[range.upperBound...])
        } else {
            base64String = photoUrl
        }

        // Decode with lenient options (ignores whitespace/newlines in base64)
        guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else { return nil }
        return UIImage(data: data)
    }
}
