/// Hardcoded Arabic UI strings, namespaced per screen. The app is single-language
/// for now (no Localizable.strings infra); keeping every literal here rather than
/// scattered in views makes a future localization pass a mechanical extraction.
enum Strings {
    enum Home {
        static let title = "تخمين"
        static let subtitle = "لعبة الوصف بالصور"
        static let createRoom = "إنشاء غرفة"
        static let joinRoom = "انضم إلى غرفة"
        static let howToPlay = "كيف تلعب؟"
        static let playerCountCaption = "من ٣ إلى ٦ لاعبين كل لاعب على جهازة"
    }

    enum CreateRoom {
        static let title = "إنشاء غرفة"
        static let comingSoon = "قريباً"
    }

    enum JoinRoom {
        static let title = "انضم إلى غرفة"
        static let comingSoon = "قريباً"
    }

    enum HowPlay {
        static let title = "كيف تلعب؟"
        static let comingSoon = "قريباً"
    }
}
