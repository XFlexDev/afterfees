//
//  AfterFeesCalculator.swift
//  AfterFees
//
//  Created by dylan on 5/23/26.
//

import Foundation

struct AfterFeesCalculator {

    let itemValue: Double
    let shippingValue: Double
    let selectedCategory: String
    let selectedState: String
    let listingsUsed: Int
    let promotedEnabled: Bool
    let promotedRate: Double
    let internationalBuyer: Bool

    let stateTaxes: [String: Double]
    
    var estimatedTax: Double {
        let taxRate = stateTaxes[selectedState] ?? 0
        return itemValue * (taxRate / 100)
    }

    var fixedFee: Double {
        itemValue > 10 ? 0.40 : 0.30
    }

    var insertionFee: Double {
        listingsUsed >= 250 ? 0.35 : 0.0
    }

    var promotedFee: Double {
        if promotedEnabled {
            return (itemValue + shippingValue + estimatedTax) * (promotedRate / 100)
        }
        return 0
    }

    var internationalFee: Double {
        if internationalBuyer {
            return (itemValue + shippingValue) * 0.0165
        }
        return 0
    }

    var sellerFees: Double {
        switch selectedCategory {

        case "Most Categories":
            if itemValue <= 7500 {
                return (itemValue * 0.1325) + fixedFee
            }
            return (7500 * 0.1325) + ((itemValue - 7500) * 0.0235) + fixedFee

        case "Books / Movies / Music / Media":
            if itemValue <= 7500 {
                return (itemValue * 0.153) + fixedFee
            }
            return (7500 * 0.153) + ((itemValue - 7500) * 0.0235) + fixedFee

        case "Women's Bags":
            if itemValue <= 2000 {
                return (itemValue * 0.15) + fixedFee
            }
            return (2000 * 0.15) + ((itemValue - 2000) * 0.09) + fixedFee

        case "Musical Instruments":
            if itemValue <= 7500 {
                return (itemValue * 0.067) + fixedFee
            }
            return (7500 * 0.067) + ((itemValue - 7500) * 0.0235) + fixedFee

        case "Trading Cards / Collectibles":
            if itemValue <= 7500 {
                return (itemValue * 0.1325) + fixedFee
            }
            return (7500 * 0.1325) + ((itemValue - 7500) * 0.0235) + fixedFee

        case "NFTs":
            return (itemValue * 0.05) + fixedFee

        default:
            return (itemValue * 0.1325) + fixedFee
        }
    }

    var totalFees: Double {
        sellerFees + insertionFee + promotedFee + internationalFee
    }

    var payout: Double {
        itemValue - totalFees - shippingValue
    }

    var displayedFeeRate: String {
        switch selectedCategory {
        case "Most Categories":
            return itemValue > 7500 ? "13.25% → 2.35%"
                : "13.25%"
        case "Books / Movies / Music / Media":
            return itemValue > 7500 ? "15.3% → 2.35%"
                : "15.3%"
        case "Women's Bags":
            return itemValue > 2000 ? "15% → 9%"
                : "15%"
        case "Musical Instruments":
            return itemValue > 7500 ? "6.7% → 2.35%"
                : "6.7%"
        case "Trading Cards / Collectibles":
            return itemValue > 7500 ? "13.25% → 2.35%"
                : "13.25%"
        case "NFTs":
            return "5%"
        default:
            return "13.25%"
        }
    }
}
