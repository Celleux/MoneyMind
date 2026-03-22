import Foundation
import SwiftData

nonisolated enum TransactionType: String, Codable, Sendable, CaseIterable {
    case expense
    case income
}

nonisolated enum TransactionCategory: String, Codable, Sendable, CaseIterable {
    case food = "Food"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case transport = "Transport"
    case housing = "Housing"
    case utilities = "Utilities"
    case health = "Health"
    case education = "Education"
    case savings = "Savings"
    case salary = "Salary"
    case freelance = "Freelance"
    case gift = "Gift"
    case other = "Other"

    var icon: String {
        switch self {
        case .food: "fork.knife"
        case .shopping: "bag.fill"
        case .entertainment: "tv.fill"
        case .transport: "car.fill"
        case .housing: "house.fill"
        case .utilities: "bolt.fill"
        case .health: "heart.fill"
        case .education: "book.fill"
        case .savings: "banknote.fill"
        case .salary: "briefcase.fill"
        case .freelance: "laptopcomputer"
        case .gift: "gift.fill"
        case .other: "ellipsis.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .food: "FF6B6B"
        case .shopping: "A55EEA"
        case .entertainment: "FF9F43"
        case .transport: "54A0FF"
        case .housing: "5F27CD"
        case .utilities: "01A3A4"
        case .health: "FF6348"
        case .education: "2ED573"
        case .savings: "00D2FF"
        case .salary: "00E676"
        case .freelance: "6C5CE7"
        case .gift: "FFD700"
        case .other: "64748B"
        }
    }

    static var expenseCategories: [TransactionCategory] {
        [.food, .shopping, .entertainment, .transport, .housing, .utilities, .health, .education, .other]
    }

    static var incomeCategories: [TransactionCategory] {
        [.salary, .freelance, .gift, .savings, .other]
    }
}

@Model
class Transaction {
    var amount: Double
    var category: String
    var note: String
    var date: Date
    var type: String
    var moodEmoji: String

    init(
        amount: Double,
        category: TransactionCategory,
        note: String = "",
        type: TransactionType,
        moodEmoji: String = ""
    ) {
        self.amount = amount
        self.category = category.rawValue
        self.note = note
        self.date = Date()
        self.type = type.rawValue
        self.moodEmoji = moodEmoji
    }

    var transactionType: TransactionType {
        TransactionType(rawValue: type) ?? .expense
    }

    var transactionCategory: TransactionCategory {
        TransactionCategory(rawValue: category) ?? .other
    }
}
