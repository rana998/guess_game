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
        /// Accessibility label for the icon-only back button (RoundedChevronButton).
        static let backAccessibilityLabel = "رجوع"

        /// An instructional (not a sample-name) hint for the empty field, so no
        /// fake player name is ever shown; also the avatar's initial-letter
        /// fallback until a real name is typed.
        static let namePlaceholder = "اكتب اسمك"
        static let nameFieldLabel = "اسم اللاعب"
        static let avatarColorLabel = "لون الصورة الرمزية"

        static let playersTitle = "عدد اللاعبين"
        static let playersCaption = "لاعبين"
        static let durationTitle = "مدة الجولة"
        static let durationCaption = "ثانية"

        static let submit = "إنشاء غرفة"
        static let codeCaption = "تُنشأ الغرفة برمز من ٤ خانات شاركه مع أصدقائك"
    }

    /// VoiceOver names for the player-color swatches, which have no visible text.
    enum Swatch {
        static let green = "أخضر"
        static let gold = "ذهبي"
        static let blue = "أزرق"
        static let pink = "وردي"
        static let purple = "بنفسجي"
        static let teal = "تركوازي"
    }

    enum EnterName {
        static let title = "اسمك في اللعبة"
        /// Accessibility label for the icon-only back button (RoundedChevronButton).
        static let backAccessibilityLabel = "رجوع"

        static let roomCaption = "غرفة"
        /// An instructional (not a sample-name) hint for the empty field, so no
        /// fake player name is ever shown; also the avatar's initial-letter
        /// fallback until a real name is typed.
        static let namePlaceholder = "اكتب اسمك"
        static let nameFieldLabel = "اسم اللاعب"
        static let avatarColorLabel = "لون الصورة الرمزية"
        /// VoiceOver name of the live avatar preview; its value is the initial.
        static let avatarPreviewLabel = "معاينة الصورة الرمزية"
        static let submit = "دخول الغرفة"

        static let playersTitle = "في الغرفة الآن"
        static let ownerCaption = "مالك الغرفة"
        /// "3 من 6 لاعبين": computed from the room, never fixed text.
        static func playersCount(count: Int, capacity: Int) -> String { "\(count) من \(capacity) لاعبين" }
    }

    enum WaitingRoom {
        static let title = "غرفة الانتظار"
        /// Accessibility label for the icon-only back button (RoundedChevronButton).
        static let backAccessibilityLabel = "رجوع"

        static let roomCaption = "غرفة"
        static let copy = "نسخ"
        static let copied = "تم النسخ"
        static let copyAccessibilityLabel = "نسخ رمز الغرفة"
        /// Accessibility label for the icon-only kebab button.
        static let moreAccessibilityLabel = "المزيد"
        static let leaveRoom = "مغادرة الغرفة"

        // Copied from the mockup verbatim, missing hamza included.
        static let ownerSelfCaption = "انت صاحب الغرفة"
        static let selfCaption = "أنت"
        static let ownerCaption = "مالك الغرفة"
        static let ready = "جاهز"
        static let waiting = "في الانتظار"
        static let emptySlot = "بانتظار لاعب"

        static let markReady = "جاهز الآن"
        static let cancelReady = "إلغاء الجاهزية"
        static let startGame = "ابدأ اللعبة"
        static let startingGame = "جارٍ بدء اللعبة…"
        static let startHint = "يلزم ٣ لاعبين على الأقل لبدء اللعبة"
        static let durationTitle = "مدة الجولة"
        static let autoStartCaption = "تبدأ اللعبة تلقائيًا عندما يجهز الجميع"

        /// "4 من 6 جاهزين": out of the players present, never the capacity.
        static func readyCount(ready: Int, total: Int) -> String { "\(ready) من \(total) جاهزين" }
        static func removeAccessibilityLabel(name: String) -> String { "إزالة \(name)" }
    }

    enum JoinRoom {
        static let title = "انضم إلى غرفة"
        /// Accessibility label for the icon-only back button (RoundedChevronButton).
        static let backAccessibilityLabel = "رجوع"

        static let codePrompt = "أدخل رمز الغرفة"
        static let codeCaption = "اطلب الرمز من صاحب الغرفة"
        static let deleteKey = "حذف"
        static let confirmKey = "تم"

        // Copied from the mockups verbatim, spelling and punctuation included.
        static let invalidCodeMessage = "رمز غير صحيح - تأكد من الرمز وحاول مرة أخرى"
        static let roomFullTitle = "الغرفة ممتلئة"
        static let roomFullSubtitle = "وصلت للحد الأقصى من اللاعبين"
        static let retryButton = "جرّب رمزاً اخر"
        static let homeButton = "الرئيسية"

        /// The room's capacity is the joined room's own fact, not a constant.
        static func roomFullBadge(capacity: Int) -> String { "\(capacity)/\(capacity)" }
        static func roomFullMessage(capacity: Int) -> String {
            "الحد الاقصى \(capacity) لاعبين. انتظر خروج احد اللاعبين أو اطلب رمز غرفة أخرى."
        }

        /// VoiceOver name and empty value of a code box ("box 1 of 4" / "empty").
        static func boxLabel(position: Int, of count: Int) -> String { "الخانة \(position) من \(count)" }
        static let boxEmptyValue = "فارغة"
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
