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

    /// The difficulty names shown on the picker cards and the word card's chip.
    enum Difficulties {
        static let easy = "سهل"
        static let medium = "متوسط"
        static let hard = "صعب"

        static func points(_ points: Int) -> String { "+\(points)" }
        /// "متوسط +2"
        static func chip(name: String, points: Int) -> String { "\(name) +\(points)" }
        static func accessibilityLabel(name: String, points: Int) -> String {
            switch points {
            case 1: "\(name)، نقطة واحدة"
            case 2: "\(name)، نقطتان"
            default: "\(name)، \(points) نقاط"
            }
        }
    }

    /// The three image tags, named for what they mean (the tag picker's labels).
    enum ClueTags {
        static let mainIdea = "الفكرة الرئيسية"
        static let detail = "تفصيل إضافي"
        static let secondaryIdea = "فكرة فرعية"
    }

    /// Shared by both round boards.
    enum Round {
        static let timerLabel = "الوقت المتبقي"
    }

    enum WordCard {
        static let title = "انت الواصف"
        static let secretCaption = "كلمتك السرية"
        static let mainIdeaRule = "الفكرة الرئيسية (صورة واحدة)"
        static func detailRule(limit: Int) -> String { "تفصيل إضافي للفكرة الرئيسية (\(limit) مكعبات)" }
        static let secondaryRule = "فكرة فرعية (واحدة، اختيارية)"
        static let start = "ابدأ الوصف"
    }

    enum DifficultyPicker {
        static let title = "أنت الواصف في هذه الجولة"
        static let subtitle = "اختر مستوى الصعوبة - الأصعب يعطي نقاطاً أكثر"
        static let draw = "اسحب الكلمة"
    }

    /// Worded without the describer's gender, which the game doesn't know.
    enum WaitingForWord {
        static func describerPill(name: String) -> String { "بانتظار كلمة \(name)" }
        static func message(describerName: String) -> String {
            "لم يبدأ العدّ بعد. سيبدأ المؤقت لحظة ضغط \(describerName) على \"ابدأ الوصف\""
        }
        static func turnBadge(roundsAway: Int) -> String {
            switch roundsAway {
            case 1: "دورك في الوصف في الجولة التالية"
            case 2: "دورك في الوصف بعد جولتين"
            default: "دورك في الوصف بعد \(roundsAway) جولات"
            }
        }
        static func guessersReady(count: Int) -> String {
            count == 2 ? "مخمنان جاهزان" : "\(count) مخمنين جاهزين"
        }
    }

    enum DescriberBoard {
        static let wordCaption = "الكلمة"
        static let endRound = "إنهاء جولة"
        static let backAccessibilityLabel = "مغادرة اللعبة"
        static let detailCounterLabel = "التفاصيل الإضافية المتبقية"
        /// "7/10": cubes left out of the round's limit.
        static func detailCounter(remaining: Int, limit: Int) -> String { "\(remaining)/\(limit)" }
        static func tileLabel(number: Int) -> String { "الصورة \(number)" }
        static let untagged = "بدون شعار"
        static let tileHint = "اضغط لاختيار شعار"
    }

    enum BadgePicker {
        static let title = "اختر الشعار لهذي الصورة"
        static func subtitle(number: Int, total: Int) -> String { "الصورة \(number) من \(total)" }
        static let mainIdeaAvailable = "صورة واحدة"
        static let secondaryAvailable = "اختيارية"
        static let used = "استُخدمت"
        static let cancel = "إلغاء"
    }

    enum GuesserBoard {
        /// "الجولة 3/6"
        static func round(number: Int, total: Int) -> String { "الجولة \(number)/\(total)" }
        static let describingNow = "يصف الآن"
        static let emptyTitle = "لا توجد تخمينات بعد"
        static let emptySubtitle = "يمكنك التخمين في أي وقت عند ظهور اول صورة"
        static let emptyReadySubtitle = "ظهرت أول صورة. اكتب تخمينك الآن"
        static let placeholder = "اكتب تخمينك..."
        static let send = "إرسال التخمين"
        static let waitingFirstTile = "بانتظار اول صورة"
        /// Worded by the user, with its hamzas, over the mockup's "اذا اضافها".
        static let secondaryPlaceholder = "تظهر الفكرة الفرعية هنا إذا أضافها الواصف"
        static let secondaryCaption = "فكرة فرعية واحدة كحد اقصى"
        /// Worded without the describer's gender, which the game doesn't know.
        static func waitingForFirstTile(name: String) -> String { "بانتظار أول صورة من \(name)…" }
        static let correct = "تخمين صحيح"
        static func newClueAnnouncement(tagName: String) -> String { "صورة جديدة: \(tagName)" }
        static func guessLabel(name: String, text: String) -> String { "\(name): \(text)" }
        static func slotLabel(number: Int) -> String { "الصورة \(number)" }
    }
}
