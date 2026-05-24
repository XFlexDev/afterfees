//
//  ContentView.swift
//  AfterFees
//
//  Created by dylan on 5/23/26.
//

import SwiftUI
import UIKit

struct ResultRow: View {
    let label: String
    let value: String
    let color: Color
    let bold: Bool

    init(_ label: String, _ value: String, color: Color = .primary, bold: Bool = false) {
        self.label = label
        self.value = value
        self.color = color
        self.bold = bold
    }

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(color)
                .fontWeight(bold ? .bold : .regular)
        }
    }
}

struct ContentView: View {

    @State private var itemPrice = ""
    @State private var shippingPrice = ""
    @State private var selectedCategory = "Most Categories"
    @State private var selectedState = "Choose State"
    @State private var over250Listings = false
    @State private var promotedEnabled = false
    @State private var promotedRate = 5.0
    @State private var internationalBuyer = false

    let haptic = UIImpactFeedbackGenerator(style: .light)

    let stateTaxes: [String: Double] = [
        "Choose State": 0.0,
        "Alabama": 4.0,
        "Alaska": 0.0,
        "Arizona": 5.6,
        "Arkansas": 6.5,
        "California": 7.25,
        "Colorado": 2.9,
        "Connecticut": 6.35,
        "Delaware": 0.0,
        "District of Columbia": 6.0,
        "Florida": 6.0,
        "Georgia": 4.0,
        "Hawaii": 4.0,
        "Idaho": 6.0,
        "Illinois": 6.25,
        "Indiana": 7.0,
        "Iowa": 6.0,
        "Kansas": 6.5,
        "Kentucky": 6.0,
        "Louisiana": 4.45,
        "Maine": 5.5,
        "Maryland": 6.0,
        "Massachusetts": 6.25,
        "Michigan": 6.0,
        "Minnesota": 6.875,
        "Mississippi": 7.0,
        "Missouri": 4.225,
        "Montana": 0.0,
        "Nebraska": 5.5,
        "Nevada": 6.85,
        "New Hampshire": 0.0,
        "New Jersey": 6.625,
        "New Mexico": 5.125,
        "New York": 4.0,
        "North Carolina": 4.75,
        "North Dakota": 5.0,
        "Ohio": 5.75,
        "Oklahoma": 4.5,
        "Oregon": 0.0,
        "Pennsylvania": 6.0,
        "Rhode Island": 7.0,
        "South Carolina": 6.0,
        "South Dakota": 4.2,
        "Tennessee": 7.0,
        "Texas": 6.25,
        "Utah": 6.1,
        "Vermont": 6.0,
        "Virginia": 5.3,
        "Washington": 6.5,
        "West Virginia": 6.0,
        "Wisconsin": 5.0,
        "Wyoming": 4.0
    ]

    let categories = [
        "Most Categories",
        "Books / Movies / Music / Media",
        "Women's Bags",
        "Musical Instruments",
        "Trading Cards / Collectibles",
        "NFTs"
    ]

    var itemValue: Double {
        Double(itemPrice) ?? 0
    }

    var shippingValue: Double {
        Double(shippingPrice) ?? 0
    }
    
    var shippingText: String {
        String(format: "$%.2f", shippingValue)
    }

    var calculator: AfterFeesCalculator {
        AfterFeesCalculator(
            itemValue: itemValue,
            shippingValue: shippingValue,
            selectedCategory: selectedCategory,
            selectedState: selectedState,
            listingsUsed: over250Listings ? 250 : 0,
            promotedEnabled: promotedEnabled,
            promotedRate: promotedRate,
            internationalBuyer: internationalBuyer,
            stateTaxes: stateTaxes
        )
    }

    var totalSaleText: String {
        String(format: "$%.2f", itemValue)
    }

    var estimatedTaxText: String {
        String(format: "$%.2f", calculator.estimatedTax)
    }

    var sellerFeesText: String {
        String(format: "$%.2f", calculator.sellerFees)
    }

    var insertionFeeText: String {
        String(format: "$%.2f", calculator.insertionFee)
    }

    var promotedFeeText: String {
        String(format: "$%.2f", calculator.promotedFee)
    }

    var internationalFeeText: String {
        String(format: "$%.2f", calculator.internationalFee)
    }

    var payoutText: String {
        String(format: "$%.2f", calculator.payout)
    }
    
    var totalBuyerCostText: String {
        let total = itemValue + shippingValue + calculator.estimatedTax
        return String(format: "$%.2f", total)
    }

    var totalSellerCostText: String {
        return String(format: "$%.2f", calculator.totalFees)
    }

    var body: some View {
        NavigationView {
            Form {

                Section(header: Text("ITEM PRICE")) {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $itemPrice)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("SHIPPING COST")) {
                    HStack {
                        Text("$")
                        TextField("0.00", text: $shippingPrice)
                            .keyboardType(.decimalPad)
                    }
                }

                Section(header: Text("CATEGORY")) {
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category)
                        }
                    }
                }

                Section(header: Text("BUYER STATE")) {
                    Picker("State", selection: $selectedState) {
                        Text("Choose State").tag("Choose State")

                        ForEach(
                            stateTaxes.keys.filter { $0 != "Choose State" }.sorted(),
                            id: \.self
                        ) { state in
                            Text(state).tag(state)
                        }
                    }
                }

                Section(header: Text("SELLER SETTINGS")) {
                    Toggle("250+ listings used this month?", isOn: $over250Listings)

                    Toggle("Promoted Listing", isOn: $promotedEnabled)

                    if promotedEnabled {
                        VStack {
                            Slider(value: $promotedRate, in: 1...20, step: 0.5)

                            Text("\(promotedRate, specifier: "%.1f")% Ad Rate")
                                .font(.caption)
                        }
                    }

                    Toggle("International Buyer", isOn: $internationalBuyer)
                }

                ResultsSection(
                    totalSaleText: totalSaleText,
                    estimatedTaxText: estimatedTaxText,
                    totalBuyerCostText: totalBuyerCostText,
                    feeRate: calculator.displayedFeeRate,
                    sellerFeesText: sellerFeesText,
                    insertionFeeText: insertionFeeText,
                    promotedFeeText: promotedFeeText,
                    internationalFeeText: internationalFeeText,
                    totalSellerCostText: totalSellerCostText,
                    shippingText: shippingText,
                    payoutText: payoutText,
                    showInsertionFee: calculator.insertionFee > 0,
                    showPromotedFee: promotedEnabled,
                    showInternationalFee: internationalBuyer,
                    payout: calculator.payout,
                    sellerFees: calculator.sellerFees,
                    shippingValue: shippingValue,
                    itemValue: itemValue,
                    promotedRate: promotedRate,
                    listingsUsed: over250Listings ? 250 : 0,
                    internationalBuyer: internationalBuyer
                    )
                footerSection
            }
            .navigationBarTitle("AfterFees")
            .onAppear {
                haptic.prepare()
            }
        }
    }

    var footerSection: some View {
        Section {
            HStack {
                Spacer()
                Text("app and witty remarks written by bitetheapple")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
