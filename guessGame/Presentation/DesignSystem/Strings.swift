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
        /// Accessibility label for the icon-only "..." button, which has no
        /// visible text of its own (unlike Home's other buttons).
        static let settingsAccessibilityLabel = "الإعدادات"
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
        static let title = "كيفية اللعبة؟"
        /// Accessibility label for the icon-only back button (RoundedChevronButton).
        static let backAccessibilityLabel = "رجوع"

        // Descriptions carry the mockup's own line breaks ("\n"); the copy is
        // transcribed verbatim from it, spelling included.
        static let setIdeaTitle = "حدد الفكرة"
        static let setIdeaDescription = "يختار الواصف صورة واحدة تمثل الفكرة الرئيسية\nللكلمة السرية."
        static let addDetailsTitle = "أضف التفاصيل"
        static let addDetailsDescription = "ثم يضع حتى 10 مكعاب على صور تشرح تفاصيل\nالفكرة بلا كلام او إشارات."
        static let subIdeaTitle = "فكرة فرعية"
        static let subIdeaDescription = "إذا احتاج يضيف فكرة فرعية واحدة لتوضيح جانب\nاخر من الكلمة."
        static let describerTitle = "الواصف"
        static let describerDescription = "يرى الكلمة ويختار الصور فقط. لايكتب ولا يتكلم"
        static let guessersTitle = "المخمّنون"
        static let guessersDescription = "يكتبو تخميناتهم في أي وقت. اول تخمين صحيح يأخذ النقاط."

        static let pointsTitle = "النقاط"
        static let pointsDescription = "سهل +1 · متوسط +2 · صعب +3 — والواصف يأخذ نقطة إذا خُمّنت كلمته"
        /// Two spaces on purpose: the mockup's word-to-digit gap is about twice a single space.
        static let rounds = "6  جولات"
    }

    enum HomeSetting {
        static let title = "الإعدادات"
        static let soundEffects = "المؤثرات الصوتية"
        static let music = "الموسيقى"
        static let vibration = "الاهتزاز"
        static let howToPlay = "كيف تلعب؟"
        static let caption = "تخمين · الإصدار 1.0 · الشروط والخصوصية"
        /// Accessibility label for the icon-only back button (RoundedChevronButton).
        static let backAccessibilityLabel = "رجوع"
        /// VoiceOver values for the custom toggle rows, which have no native switch to announce them.
        static let on = "مفعّل"
        static let off = "معطّل"
    }
}
