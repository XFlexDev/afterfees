import SwiftUI

struct BreakdownView: View {
    let calculator: AfterFeesCalculator
    @Environment(\.dismiss) var dismiss

    var totalBuyerCost: Double {
        calculator.itemValue + calculator.shippingValue + calculator.estimatedTax
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Sale Details")) {
                    receiptRow("Total Sale", String(format: "$%.2f", calculator.itemValue), .primary)
                    receiptRow("Shipping Cost", String(format: "$%.2f", calculator.shippingValue), .primary)
                    receiptRow("Estimated Tax", String(format: "$%.2f", calculator.estimatedTax), .secondary)
                    receiptRow("Total Buyer Cost", String(format: "$%.2f", totalBuyerCost), .green, bold: true)
                }

                Section(header: Text("eBay Fees")) {
                    receiptRow("Base Fee (\(calculator.displayedFeeRate))", String(format: "-$%.2f", calculator.sellerFees), .red)
                    if calculator.insertionFee > 0 {
                        receiptRow("Insertion Fee", String(format: "-$%.2f", calculator.insertionFee), .red)
                    }
                    if calculator.promotedFee > 0 {
                        receiptRow("Promoted Fee", String(format: "-$%.2f", calculator.promotedFee), .red)
                    }
                    if calculator.internationalFee > 0 {
                        receiptRow("International Fee", String(format: "-$%.2f", calculator.internationalFee), .red)
                    }
                    receiptRow("Total Seller Fees", String(format: "-$%.2f", calculator.totalFees), .red, bold: true)
                }
            }
            .navigationTitle("Fee Breakdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    func receiptRow(_ label: String, _ value: String, _ color: Color, bold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 16, weight: .medium, design: .rounded))
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: bold ? .bold : .medium, design: .rounded))
                .foregroundColor(color)
        }
    }
}
