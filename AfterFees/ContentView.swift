import SwiftUI
import UIKit

struct ContentView: View {
    @State private var itemPrice = ""
    @State private var shippingPrice = ""
    @State private var selectedCategory = "Most Categories"
    @State private var selectedState = "Choose State"
    @State private var over250Listings = false
    @State private var promotedEnabled = false
    @State private var promotedRate = 5.0
    @State private var internationalBuyer = false
    @State private var showBreakdown = false
    @State private var showCopiedMessage = false
    @FocusState private var focusedField: Field?
    @State private var secretTapCount = 0

    enum Field {
        case price, shipping
    }

    let haptic = UIImpactFeedbackGenerator(style: .rigid)

    let stateTaxes: [String: Double] = [
        "Choose State": 0.0, "Alabama": 4.0, "Alaska": 0.0, "Arizona": 5.6, "Arkansas": 6.5, "California": 7.25,
        "Colorado": 2.9, "Connecticut": 6.35, "Delaware": 0.0, "District of Columbia": 6.0, "Florida": 6.0, "Georgia": 4.0,
        "Hawaii": 4.0, "Idaho": 6.0, "Illinois": 6.25, "Indiana": 7.0, "Iowa": 6.0, "Kansas": 6.5, "Kentucky": 6.0,
        "Louisiana": 4.45, "Maine": 5.5, "Maryland": 6.0, "Massachusetts": 6.25, "Michigan": 6.0, "Minnesota": 6.875,
        "Mississippi": 7.0, "Missouri": 4.225, "Montana": 0.0, "Nebraska": 5.5, "Nevada": 6.85, "New Hampshire": 0.0,
        "New Jersey": 6.625, "New Mexico": 5.125, "New York": 4.0, "North Carolina": 4.75, "North Dakota": 5.0,
        "Ohio": 5.75, "Oklahoma": 4.5, "Oregon": 0.0, "Pennsylvania": 6.0, "Rhode Island": 7.0, "South Carolina": 6.0,
        "South Dakota": 4.2, "Tennessee": 7.0, "Texas": 6.25, "Utah": 6.1, "Vermont": 6.0, "Virginia": 5.3,
        "Washington": 6.5, "West Virginia": 6.0, "Wisconsin": 5.0, "Wyoming": 4.0
    ]

    let categories = [
        ("Most Categories", "tray.fill", Color.blue),
        ("Books / Movies / Music / Media", "book.fill", Color.purple),
        ("Women's Bags", "bag.fill", Color.pink),
        ("Musical Instruments", "guitars.fill", Color.green),
        ("Trading Cards / Collectibles", "star.fill", Color.orange),
        ("NFTs", "hexagon.fill", Color.teal)
    ]

    var itemValue: Double { Double(itemPrice) ?? 0 }
    var shippingValue: Double { Double(shippingPrice) ?? 0 }

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

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    headerSection
                    inputSection
                    categoryGrid
                    settingsSection
                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 40)
            }

            floatingBottomBar
        }
        .onAppear { haptic.prepare() }
        .onChange(of: itemPrice) { _, _ in sanitizeInput(&itemPrice) }
        .onChange(of: shippingPrice) { _, _ in sanitizeInput(&shippingPrice) }
        .sheet(isPresented: $showBreakdown) {
            BreakdownView(calculator: calculator)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Estimated Payout")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            
            Text(String(format: "$%.2f", calculator.payout))
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(calculator.payout >= 0 ? .primary : .red)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .contentTransition(.numericText(countsDown: false))
                .animation(.snappy, value: calculator.payout)
                .onTapGesture { handleSecretTap() }
                .onLongPressGesture { copyToClipboard() }

            if showCopiedMessage {
                Text("Copied.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.green)
            } else {
                wittyRemarks
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    var inputSection: some View {
        HStack(spacing: 16) {
            inputField(title: "Item Price", text: $itemPrice, field: .price)
            inputField(title: "Shipping", text: $shippingPrice, field: .shipping)
        }
    }

    var categoryGrid: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(categories, id: \.0) { cat in
                    Button(action: {
                        haptic.impactOccurred()
                        withAnimation(.spring) { selectedCategory = cat.0 }
                    }) {
                        VStack(alignment: .leading, spacing: 12) {
                            Image(systemName: cat.1)
                                .font(.system(size: 24))
                                .foregroundColor(cat.2)
                            Text(cat.0.components(separatedBy: " / ").first ?? cat.0)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 110)
                        .background(selectedCategory == cat.0 ? cat.2.opacity(0.15) : Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(selectedCategory == cat.0 ? cat.2.opacity(0.4) : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    var settingsSection: some View {
        VStack(spacing: 16) {
            pickerCard(title: "Buyer State", selection: $selectedState, options: ["Choose State"] + stateTaxes.keys.filter { $0 != "Choose State" }.sorted())
            
            VStack(spacing: 0) {
                Toggle("Promoted Listing", isOn: $promotedEnabled)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .padding()
                
                if promotedEnabled {
                    Divider().padding(.horizontal)
                    VStack(spacing: 16) {
                        HStack {
                            Text("Ad Rate")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("\(promotedRate, specifier: "%.1f")%")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                        Slider(value: $promotedRate, in: 1...20, step: 0.5)
                            .tint(.blue)
                    }
                    .padding()
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))

            Toggle("250+ Listings Used", isOn: $over250Listings)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))

            Toggle("International Buyer", isOn: $internationalBuyer)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    var floatingBottomBar: some View {
        VStack {
            Spacer()
            HStack(spacing: 0) {
                Button(action: clearAllFields) {
                    Image(systemName: "trash")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                }
                
                Divider().frame(height: 24)
                
                Button(action: { haptic.impactOccurred() }) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                }
                
                Divider().frame(height: 24)
                
                Button(action: { showBreakdown = true }) {
                    Text("Breakdown")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 64)
            .padding(.horizontal, 8)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .shadow(color: Color.black.opacity(0.1), radius: 20, y: 10)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
        }
    }

    func inputField(title: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.secondary)
            HStack(spacing: 4) {
                Text("$").foregroundColor(.secondary)
                TextField("0.00", text: text)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: field)
            }
            .font(.system(size: 24, weight: .bold, design: .rounded))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(focusedField == field ? Color.blue : Color.clear, lineWidth: 2)
        )
    }

    func pickerCard(title: String, selection: Binding<String>, options: [String]) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            Spacer()
            Picker("", selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(.primary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }

    @ViewBuilder
    var wittyRemarks: some View {
        VStack(alignment: .leading, spacing: 4) {
            if calculator.payout < 0 {
                Text("Maksat eBaylle että ne ottaa sun romut.")
            } else if calculator.payout < 5 && itemValue > 0 {
                Text("Miksi ees myyt tätä paskaa?")
            } else if itemValue > 10000 {
                Text("Rahanpesu on taitolaji.")
            } else if selectedCategory == "NFTs" {
                Text("Kuvittele myyväsi jotain vitun jpeggejä vuonna 2026.")
            } else if over250Listings && calculator.payout < 10 && itemValue > 0 {
                Text("250+ listausta ja oot silti täysin perseauki.")
            } else if selectedState == "California" && calculator.estimatedTax > 50 {
                Text("Kalifornian verot vie sut katuojaan.")
            } else if selectedCategory == "Trading Cards / Collectibles" && !promotedEnabled {
                Text("Onnea pahvin myymiseen ilman mainoksia.")
            } else if calculator.sellerFees > 50 {
                Text("eBay lähettää terveisiä lompakollesi.")
            } else if shippingValue > itemValue && itemValue > 0 {
                Text("Mitä vittua sä lähetät, jääkaapin?")
            } else if promotedRate > 15 && promotedEnabled {
                Text("Ostat käytännössä vaan saatanasti mainostilaa.")
            } else if internationalBuyer && calculator.sellerFees > 50 {
                Text("Globaali taloudellinen tuho.")
            } else {
                Text("Bitetheapple on ainoa joka vetää tästä välistä.")
            }
        }
        .font(.system(size: 14, weight: .medium, design: .rounded))
        .foregroundColor(.secondary)
    }

    func handleSecretTap() {
        secretTapCount += 1
        if secretTapCount >= 3 && secretTapCount < 10 {
            haptic.impactOccurred(intensity: CGFloat(Double(secretTapCount) / 10.0))
        }
        if secretTapCount >= 10 {
            fatalError("LOPETA SE VITUN NAKUTUS TAI KAADAN TÄN PASKAN")
        }
    }

    func clearAllFields() {
        haptic.impactOccurred(intensity: 1.0)
        withAnimation {
            itemPrice = ""
            shippingPrice = ""
            selectedCategory = "Most Categories"
            selectedState = "Choose State"
            over250Listings = false
            promotedEnabled = false
            promotedRate = 5.0
            internationalBuyer = false
            focusedField = nil
            secretTapCount = 0
        }
    }

    func copyToClipboard() {
        haptic.impactOccurred(intensity: 0.8)
        UIPasteboard.general.string = String(format: "%.2f", calculator.payout)
        withAnimation { showCopiedMessage = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopiedMessage = false }
        }
    }

    func sanitizeInput(_ input: inout String) {
        if input.count > 1 && input.hasPrefix("0") && !input.hasPrefix("0.") {
            input.removeFirst()
        }
    }
}
