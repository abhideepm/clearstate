import Foundation

/// Helper to read widget data from UserDefaults App Group shared with Flutter app
struct SharedData {
    
    // MARK: - App Group Configuration
    
    private static let appGroupID = "group.com.truestate.truestate"
    
    private static var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let batteryProgress = "battery_progress"
        static let batteryMode = "battery_mode"
        static let stoicQuote = "stoic_quote"
        static let stoicAuthor = "stoic_author"
        static let biostateLabel = "biostate_label"
        static let biostateValue = "biostate_value"
    }
    
    // MARK: - Default Values
    
    private enum Defaults {
        static let batteryProgress: Double = 0.0
        static let batteryMode: String = "charging"
        static let stoicQuote: String = "The obstacle is the way."
        static let stoicAuthor: String = "Marcus Aurelius"
        static let biostateLabel: String = "Rest Score"
        static let biostateValue: Double = 0.0
    }
    
    // MARK: - Battery Widget Data
    
    /// Progress value from 0.0 to 1.0 representing sobriety progress
    static var batteryProgress: Double {
        userDefaults?.double(forKey: Keys.batteryProgress) ?? Defaults.batteryProgress
    }
    
    /// Battery mode: "charging", "full", or "draining"
    static var batteryMode: String {
        userDefaults?.string(forKey: Keys.batteryMode) ?? Defaults.batteryMode
    }
    
    // MARK: - Stoic Widget Data
    
    /// Current stoic quote to display
    static var stoicQuote: String {
        userDefaults?.string(forKey: Keys.stoicQuote) ?? Defaults.stoicQuote
    }
    
    /// Author attribution for the quote
    static var stoicAuthor: String {
        userDefaults?.string(forKey: Keys.stoicAuthor) ?? Defaults.stoicAuthor
    }
    
    // MARK: - BioState Widget Data
    
    /// Label for the health metric (stealth display name)
    static var biostateLabel: String {
        userDefaults?.string(forKey: Keys.biostateLabel) ?? Defaults.biostateLabel
    }
    
    /// Value from 0.0 to 1.0 representing the metric progress
    static var biostateValue: Double {
        userDefaults?.double(forKey: Keys.biostateValue) ?? Defaults.biostateValue
    }
    
    // MARK: - Convenience Methods
    
    /// Battery progress as percentage (0-100)
    static var batteryPercentage: Int {
        Int(batteryProgress * 100)
    }
    
    /// BioState value as percentage (0-100)
    static var biostatePercentage: Int {
        Int(biostateValue * 100)
    }
}
