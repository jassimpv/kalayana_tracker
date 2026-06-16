import GoogleMobileAds
import UIKit
import google_mobile_ads

/// Builds the "inline" native ad shown in the Overview feed.
///
/// Built programmatically (no .xib) so the whole template lives in one
/// reviewable Swift file. Visual style mirrors the app's card design:
/// white rounded card, maroon CTA button, gold "Ad" badge.
final class InlineNativeAdFactory: NSObject, FLTNativeAdFactory {
  private let brandMaroon = UIColor(red: 0x8F / 255, green: 0x14 / 255, blue: 0x38 / 255, alpha: 1)
  private let brandGold = UIColor(red: 0xE8 / 255, green: 0xB7 / 255, blue: 0x5C / 255, alpha: 1)
  private let brandDeep = UIColor(red: 0x3A / 255, green: 0x11 / 255, blue: 0x17 / 255, alpha: 1)

  func createNativeAd(
    _ nativeAd: NativeAd,
    customOptions: [AnyHashable: Any]? = nil
  ) -> NativeAdView? {
    let adView = NativeAdView()
    adView.backgroundColor = .white
    adView.layer.cornerRadius = 18
    adView.layer.borderWidth = 1
    adView.layer.borderColor = UIColor(red: 0xF1 / 255, green: 0xD9 / 255, blue: 0xD5 / 255, alpha: 1).cgColor
    adView.clipsToBounds = true

    let badge = UILabel()
    badge.text = "  Ad  "
    badge.font = .systemFont(ofSize: 10, weight: .semibold)
    badge.textColor = brandDeep
    badge.backgroundColor = brandGold.withAlphaComponent(0.35)
    badge.layer.cornerRadius = 8
    badge.clipsToBounds = true
    badge.translatesAutoresizingMaskIntoConstraints = false

    let iconView = UIImageView()
    iconView.contentMode = .scaleAspectFill
    iconView.layer.cornerRadius = 10
    iconView.clipsToBounds = true
    iconView.translatesAutoresizingMaskIntoConstraints = false

    let headlineLabel = UILabel()
    headlineLabel.font = .systemFont(ofSize: 14, weight: .semibold)
    headlineLabel.textColor = brandDeep
    headlineLabel.numberOfLines = 1
    headlineLabel.translatesAutoresizingMaskIntoConstraints = false

    let bodyLabel = UILabel()
    bodyLabel.font = .systemFont(ofSize: 12, weight: .regular)
    bodyLabel.textColor = UIColor(white: 0.35, alpha: 1)
    bodyLabel.numberOfLines = 2
    bodyLabel.translatesAutoresizingMaskIntoConstraints = false

    let mediaView = MediaView()
    mediaView.translatesAutoresizingMaskIntoConstraints = false
    mediaView.layer.cornerRadius = 12
    mediaView.clipsToBounds = true

    let ctaButton = UIButton(type: .system)
    ctaButton.backgroundColor = brandMaroon
    ctaButton.setTitleColor(.white, for: .normal)
    ctaButton.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
    ctaButton.layer.cornerRadius = 10
    ctaButton.isUserInteractionEnabled = false
    ctaButton.translatesAutoresizingMaskIntoConstraints = false

    let headRow = UIStackView(arrangedSubviews: [iconView, headlineLabel, badge])
    headRow.axis = .horizontal
    headRow.alignment = .center
    headRow.spacing = 10
    headRow.translatesAutoresizingMaskIntoConstraints = false

    let stack = UIStackView(arrangedSubviews: [headRow, bodyLabel, mediaView, ctaButton])
    stack.axis = .vertical
    stack.spacing = 10
    stack.translatesAutoresizingMaskIntoConstraints = false
    adView.addSubview(stack)

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: adView.topAnchor, constant: 14),
      stack.leadingAnchor.constraint(equalTo: adView.leadingAnchor, constant: 14),
      stack.trailingAnchor.constraint(equalTo: adView.trailingAnchor, constant: -14),
      stack.bottomAnchor.constraint(equalTo: adView.bottomAnchor, constant: -14),
      iconView.widthAnchor.constraint(equalToConstant: 36),
      iconView.heightAnchor.constraint(equalToConstant: 36),
      mediaView.heightAnchor.constraint(equalToConstant: 120),
      ctaButton.heightAnchor.constraint(equalToConstant: 38),
    ])

    adView.iconView = iconView
    adView.headlineView = headlineLabel
    adView.bodyView = bodyLabel
    adView.mediaView = mediaView
    adView.callToActionView = ctaButton

    headlineLabel.text = nativeAd.headline
    mediaView.mediaContent = nativeAd.mediaContent

    if let body = nativeAd.body {
      bodyLabel.text = body
      bodyLabel.isHidden = false
    } else {
      bodyLabel.isHidden = true
    }

    if let icon = nativeAd.icon {
      iconView.image = icon.image
      iconView.isHidden = false
    } else {
      iconView.isHidden = true
    }

    if let cta = nativeAd.callToAction {
      ctaButton.setTitle(cta, for: .normal)
      ctaButton.isHidden = false
    } else {
      ctaButton.isHidden = true
    }

    adView.nativeAd = nativeAd
    return adView
  }
}
