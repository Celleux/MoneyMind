import Foundation

nonisolated struct CurrencyInfo: Identifiable, Sendable {
    let code: String
    let symbol: String
    let name: String
    let flag: String

    var id: String { code }

    static let popular: [CurrencyInfo] = [
        CurrencyInfo(code: "USD", symbol: "$", name: "US Dollar", flag: "🇺🇸"),
        CurrencyInfo(code: "EUR", symbol: "€", name: "Euro", flag: "🇪🇺"),
        CurrencyInfo(code: "GBP", symbol: "£", name: "British Pound", flag: "🇬🇧"),
        CurrencyInfo(code: "THB", symbol: "฿", name: "Thai Baht", flag: "🇹🇭"),
        CurrencyInfo(code: "JPY", symbol: "¥", name: "Japanese Yen", flag: "🇯🇵"),
        CurrencyInfo(code: "AUD", symbol: "A$", name: "Australian Dollar", flag: "🇦🇺"),
        CurrencyInfo(code: "CAD", symbol: "C$", name: "Canadian Dollar", flag: "🇨🇦"),
        CurrencyInfo(code: "INR", symbol: "₹", name: "Indian Rupee", flag: "🇮🇳"),
    ]

    static let all: [CurrencyInfo] = [
        CurrencyInfo(code: "USD", symbol: "$", name: "US Dollar", flag: "🇺🇸"),
        CurrencyInfo(code: "EUR", symbol: "€", name: "Euro", flag: "🇪🇺"),
        CurrencyInfo(code: "GBP", symbol: "£", name: "British Pound", flag: "🇬🇧"),
        CurrencyInfo(code: "THB", symbol: "฿", name: "Thai Baht", flag: "🇹🇭"),
        CurrencyInfo(code: "JPY", symbol: "¥", name: "Japanese Yen", flag: "🇯🇵"),
        CurrencyInfo(code: "AUD", symbol: "A$", name: "Australian Dollar", flag: "🇦🇺"),
        CurrencyInfo(code: "CAD", symbol: "C$", name: "Canadian Dollar", flag: "🇨🇦"),
        CurrencyInfo(code: "INR", symbol: "₹", name: "Indian Rupee", flag: "🇮🇳"),
        CurrencyInfo(code: "CHF", symbol: "CHF", name: "Swiss Franc", flag: "🇨🇭"),
        CurrencyInfo(code: "CNY", symbol: "¥", name: "Chinese Yuan", flag: "🇨🇳"),
        CurrencyInfo(code: "SEK", symbol: "kr", name: "Swedish Krona", flag: "🇸🇪"),
        CurrencyInfo(code: "NZD", symbol: "NZ$", name: "New Zealand Dollar", flag: "🇳🇿"),
        CurrencyInfo(code: "MXN", symbol: "MX$", name: "Mexican Peso", flag: "🇲🇽"),
        CurrencyInfo(code: "SGD", symbol: "S$", name: "Singapore Dollar", flag: "🇸🇬"),
        CurrencyInfo(code: "HKD", symbol: "HK$", name: "Hong Kong Dollar", flag: "🇭🇰"),
        CurrencyInfo(code: "NOK", symbol: "kr", name: "Norwegian Krone", flag: "🇳🇴"),
        CurrencyInfo(code: "KRW", symbol: "₩", name: "South Korean Won", flag: "🇰🇷"),
        CurrencyInfo(code: "TRY", symbol: "₺", name: "Turkish Lira", flag: "🇹🇷"),
        CurrencyInfo(code: "BRL", symbol: "R$", name: "Brazilian Real", flag: "🇧🇷"),
        CurrencyInfo(code: "ZAR", symbol: "R", name: "South African Rand", flag: "🇿🇦"),
        CurrencyInfo(code: "DKK", symbol: "kr", name: "Danish Krone", flag: "🇩🇰"),
        CurrencyInfo(code: "PLN", symbol: "zł", name: "Polish Zloty", flag: "🇵🇱"),
        CurrencyInfo(code: "TWD", symbol: "NT$", name: "Taiwan Dollar", flag: "🇹🇼"),
        CurrencyInfo(code: "MYR", symbol: "RM", name: "Malaysian Ringgit", flag: "🇲🇾"),
        CurrencyInfo(code: "IDR", symbol: "Rp", name: "Indonesian Rupiah", flag: "🇮🇩"),
        CurrencyInfo(code: "PHP", symbol: "₱", name: "Philippine Peso", flag: "🇵🇭"),
        CurrencyInfo(code: "CZK", symbol: "Kč", name: "Czech Koruna", flag: "🇨🇿"),
        CurrencyInfo(code: "ILS", symbol: "₪", name: "Israeli Shekel", flag: "🇮🇱"),
        CurrencyInfo(code: "CLP", symbol: "CL$", name: "Chilean Peso", flag: "🇨🇱"),
        CurrencyInfo(code: "AED", symbol: "د.إ", name: "UAE Dirham", flag: "🇦🇪"),
        CurrencyInfo(code: "COP", symbol: "COL$", name: "Colombian Peso", flag: "🇨🇴"),
        CurrencyInfo(code: "SAR", symbol: "﷼", name: "Saudi Riyal", flag: "🇸🇦"),
        CurrencyInfo(code: "RON", symbol: "lei", name: "Romanian Leu", flag: "🇷🇴"),
        CurrencyInfo(code: "ARS", symbol: "AR$", name: "Argentine Peso", flag: "🇦🇷"),
        CurrencyInfo(code: "VND", symbol: "₫", name: "Vietnamese Dong", flag: "🇻🇳"),
        CurrencyInfo(code: "NGN", symbol: "₦", name: "Nigerian Naira", flag: "🇳🇬"),
        CurrencyInfo(code: "EGP", symbol: "E£", name: "Egyptian Pound", flag: "🇪🇬"),
        CurrencyInfo(code: "PKR", symbol: "₨", name: "Pakistani Rupee", flag: "🇵🇰"),
        CurrencyInfo(code: "BDT", symbol: "৳", name: "Bangladeshi Taka", flag: "🇧🇩"),
        CurrencyInfo(code: "KES", symbol: "KSh", name: "Kenyan Shilling", flag: "🇰🇪"),
    ]
}
