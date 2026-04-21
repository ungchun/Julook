// A clean sample with zero Korean string literals.
// Used to verify the detector exits 0 on clean files.

import Foundation

struct NoKoreanSample {
    let title: String = "Recommendations"
    let subtitle: String = "Makgeolli"

    func welcome(name: String) -> String {
        return String(format: "Welcome, %@", name)
    }

    // Inline comment without Korean — should not trigger.
    let url: String = "https://example.com/api"
}
