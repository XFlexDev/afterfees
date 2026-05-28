//
//  ResultsSection.swift
//  AfterFees
//
//  Created by dylan on 5/23/26.
//

import SwiftUI

struct ResultsSection: View {
    let calculator: AfterFeesCalculator
    @Binding var showBreakdown: Bool
    var animation: Namespace.ID

    var totalSaleText: String { String(format: "$%.2f", calculator.itemValue) }
    var shippingText: String { String(format: "$%.2f", calculator.shippingValue) }
    var estimatedTaxText: String { String(format: "$%.2f", calculator.estimatedTax) }
    
    var totalBuyerCost: Double {
        calculator.itemValue + calculator.shippingValue + calculator.estimatedTax
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showBreakdown.toggle()
                }
            }) {
                HStack {
                    Text("FEE BREAKDOWN")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Spacer()
                    Image(systemName: showBreakdown ? "chevron.up" : "chevron.down")
                        .foregroundColor(Color(white: 0.5))
                }
                .padding()
                .background(Color(white: 0.11))
            }
            .buttonStyle(PlainButtonStyle())
            
            if showBreakdown {
                VStack(spacing: 16) {
                    Group {
                        receiptRow(label: "Total Sale", value: totalSaleText, color: .white)
                        receiptRow(label: "Shipping Cost", value: shippingText, color: .white)
                        receiptRow(label: "Estimated Tax", value: estimatedTaxText, color: Color(white: 0.6))
                        Divider().background(Color(white: 0.2))
                        receiptRow(label: "Total Buyer Cost", value: String(format: "$%.2f", totalBuyerCost), color: .green, bold: true)
                    }
                    
                    Group {
                        receiptRow(label: "Base Fee (\(calculator.displayedFeeRate))", value: String(format: "-$%.2f", calculator.sellerFees), color: .red)
                        
                        if calculator.insertionFee > 0 {
                            receiptRow(label: "Insertion Fee", value: String(format: "-$%.2f", calculator.insertionFee), color: .red)
                        }
                        if calculator.promotedFee > 0 {
                            receiptRow(label: "Promoted Fee", value: String(format: "-$%.2f", calculator.promotedFee), color: .red)
                        }
                        if calculator.internationalFee > 0 {
                            receiptRow(label: "International Fee", value: String(format: "-$%.2f", calculator.internationalFee), color: .red)
                        }
                        Divider().background(Color(white: 0.2))
                        receiptRow(label: "Total Seller Fees", value: String(format: "-$%.2f", calculator.totalFees), color: .red, bold: true)
                    }
                }
                .padding()
                .background(Color(white: 0.11))
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func receiptRow(label: String, value: String, color: Color, bold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 13, weight: .regular, design: .monospaced))
                .foregroundColor(Color(white: 0.6))
            Spacer()
            Text(value)
                .font(.system(size: 13, weight: bold ? .bold : .regular, design: .monospaced))
                .foregroundColor(color)
        }
    }
}
