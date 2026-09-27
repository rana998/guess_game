/// The game's secret words by difficulty: easy ones are everyday objects and
/// animals, medium ones compound or less common, hard ones people, places and
/// ideas that are harder to show in pictures. Written without diacritics.
enum ArabicWordList {
    static let easy = [
        "قطة", "كلب", "شمس", "قمر", "تفاحة", "سيارة", "بيت", "شجرة",
        "كرة", "سمكة", "وردة", "كتاب", "ساعة", "طائرة", "حصان", "جمل",
    ]

    static let medium = [
        "وحيد القرن", "فرس النهر", "زرافة", "بطريق", "مظلة", "منارة", "قوس قزح", "رجل الثلج",
        "بركان", "غواصة", "تلسكوب", "فانوس", "خيمة", "صبار", "نظارة شمسية", "قلعة",
    ]

    static let hard = [
        "رائد فضاء", "مستشفى", "مكتبة", "إطفائي", "صحراء", "ديناصور", "مهرجان", "ذكريات",
        "حرية", "صداقة", "شلال", "متحف", "مطار", "ساعي البريد", "عاصفة", "زلزال",
    ]
}
