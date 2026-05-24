//
//  ResultsSection.swift
//  AfterFees
//
//  Created by dylan on 5/23/26.
//

import SwiftUI

struct ResultsSection: View {
    let totalSaleText: String
    let estimatedTaxText: String
    let totalBuyerCostText: String
    let feeRate: String
    let sellerFeesText: String
    let insertionFeeText: String
    let promotedFeeText: String
    let internationalFeeText: String
    let totalSellerCostText: String
    let shippingText: String
    let payoutText: String

    let showInsertionFee: Bool
    let showPromotedFee: Bool
    let showInternationalFee: Bool

    let payout: Double
    let sellerFees: Double
    let shippingValue: Double
    let itemValue: Double
    let promotedRate: Double
    let listingsUsed: Int
    let internationalBuyer: Bool

    var basicRows: some View {
        Group {
            HStack {
                Text("Total Sale (Before Shipping)")
                Spacer()
                Text(totalSaleText)
                    .foregroundColor(.green)
            }

            HStack {
                Text("Shipping Cost")
                Spacer()
                Text(shippingText)
                    .foregroundColor(.red)
            }

            HStack {
                Text("Estimated Sales Tax")
                Spacer()
                Text(estimatedTaxText)
                    .foregroundColor(.orange)
            }

            HStack {
                Text("Total Buyer Cost")
                Spacer()
                Text(totalBuyerCostText)
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            }
        }
    }
    var optionalFeeRows: some View {
        Group {
            HStack {
                Text("Fee Rate")
                Spacer()
                Text(feeRate)
                    .foregroundColor(.orange)
            }

            HStack {
                Text("Seller Fees")
                Spacer()
                Text(sellerFeesText)
                    .foregroundColor(.red)
            }

            if showInsertionFee {
                HStack {
                    Text("Insertion Fee")
                    Spacer()
                    Text(insertionFeeText)
                        .foregroundColor(.red)
                }
            }

            if showPromotedFee {
                HStack {
                    Text("Promoted Fee")
                    Spacer()
                    Text(promotedFeeText)
                        .foregroundColor(.red)
                }
            }

            if showInternationalFee {
                HStack {
                    Text("International Fee")
                    Spacer()
                    Text(internationalFeeText)
                        .foregroundColor(.red)
                }
            }

            HStack {
                Text("Total Seller Fee Cost")
                Spacer()
                Text(totalSellerCostText)
                    .foregroundColor(.red)
                    .fontWeight(.bold)
            }
        }
    }

    var wittyRemarks: some View {
        Group {
            if payout < 0 {
                Text("congratulations, you paid eBay to take your item")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if payout < 5 && itemValue > 0 {
                Text("why are you selling this lol")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if sellerFees > 50 {
                Text("eBay sends their regards")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if shippingValue > itemValue && itemValue > 0 {
                Text("what are you shipping, a refrigerator?")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if promotedRate > 15 && showPromotedFee {
                Text("you're just buying acres of ad now")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if internationalBuyer && sellerFees > 50 {
                Text("global financial devastation")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    var body: some View {
        Section(header: Text("RESULTS")) {

            Text("Buyer Costs")
                .font(.caption)
                .foregroundColor(.secondary)

            basicRows

            Text("Seller Costs")
                .font(.caption)
                .foregroundColor(.secondary)

            optionalFeeRows

            HStack {
                Text("You Make")
                Spacer()
                Text(payoutText)
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            }

            wittyRemarks
        }
    }
}
