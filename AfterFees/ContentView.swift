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

    @Namespace private var animation

    enum Field {
        case price, shipping
    }

    let haptic = UIImpactFeedbackGenerator(style: .light)

    let stateTaxes: [String: Double] = [
        "Choose State": 0.0,
        "Alabama": 4.0, "Alaska": 0.0, "Arizona": 5.6, "Arkansas": 6.5, "California": 7.25,
        "Colorado": 2.9, "Connecticut": 6.35, "Delaware": 0.0, "District of Columbia": 6.0,
        "Florida": 6.0, "Georgia": 4.0, "Hawaii": 4.0, "Idaho": 6.0, "Illinois": 6.25,
        "Indiana": 7.0, "Iowa": 6.0, "Kansas": 6.5, "Kentucky": 6.0, "Louisiana": 4.45,
        "Maine": 5.5, "Maryland": 6.0, "Massachusetts": 6.25, "Michigan": 6.0, "Minnesota": 6.875,
        "Mississippi": 7.0, "Missouri": 4.225, "Montana": 0.0, "Nebraska": 5.5, "Nevada": 6.85,
        "New Hampshire": 0.0, "New Jersey": 6.625, "New Mexico": 5.125, "New York": 4.0,
        "North Carolina": 4.75, "North Dakota": 5.0, "Ohio": 5.75, "Oklahoma": 4.5, "Oregon": 0.0,
        "Pennsylvania": 6.0, "Rhode Island": 7.0, "South Carolina": 6.0, "South Dakota": 4.2,
        "Tennessee": 7.0, "Texas": 6.25, "Utah": 6.1, "Vermont": 6.0, "Virginia": 5.3,
        "Washington": 6.5, "West Virginia": 6.0, "Wisconsin": 5.0, "Wyoming": 4.0
    ]

    let categories = [
        "Most Categories",
        "Books / Movies / Music / Media",
        "Women's Bags",
        "Musical Instruments",
        "Trading Cards / Collectibles",
        "NFTs"
    ]

    let adRatePresets: [Double] = [2.0, 5.0, 10.0, 15.0]

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
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // --- PAYOUT HEADER ---
                    VStack(spacing: 8) {
                        Text("Payout")
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundColor(Color(white: 0.5))
                            .textCase(.uppercase)
                        
                        Text(String(format: "$%.2f", calculator.payout))
                            .font(.system(size: 64, weight: .bold, design: .monospaced))
                            .foregroundColor(calculator.payout >= 0 ? .green : .red)
                            .lineLimit(1)
                            .minimumScaleFactor(0.4)
                            .contentTransition(.numericText(countsDown: false))
                            .animation(.snappy(duration: 0.3, extraBounce: 0.1), value: calculator.payout)
                            .onTapGesture {
                                handleSecretTap()
                            }
                            .onLongPressGesture(minimumDuration: 0.5) {
                                copyToClipboard()
                            }
                        
                        if showCopiedMessage {
                            Text("copied to clipboard.")
                                .font(.system(size: 12, weight: .regular, design: .monospaced))
                                .foregroundColor(.green)
                                .transition(.opacity)
                        } else {
                            wittyRemarks
                        }
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)

                    // --- INPUT GRIDS ---
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            inputCard(title: "ITEM PRICE", text: $itemPrice, field: .price)
                            inputCard(title: "SHIPPING", text: $shippingPrice, field: .shipping)
                        }
                        
                        pickerCard(title: "CATEGORY", selection: $selectedCategory, options: categories)
                        pickerCard(title: "BUYER STATE", selection: $selectedState, options: ["Choose State"] + stateTaxes.keys.filter { $0 != "Choose State" }.sorted())
                    }
                    
                    // --- TOGGLES AND SETTINGS ---
                    VStack(spacing: 16) {
                        toggleCard(title: "250+ listings used this month?", isOn: $over250Listings)
                        
                        VStack(spacing: 0) {
                            toggleCard(title: "Promoted Listing", isOn: $promotedEnabled)
                            
                            if promotedEnabled {
                                VStack(spacing: 16) {
                                    HStack {
                                        Text("Ad Rate")
                                            .foregroundColor(Color(white: 0.5))
                                            .font(.system(size: 15, weight: .regular, design: .monospaced))
                                        Spacer()
                                        
                                        HStack(spacing: 8) {
                                            ForEach(adRatePresets, id: \.self) { preset in
                                                Button(action: {
                                                    haptic.impactOccurred()
                                                    withAnimation(.spring) {
                                                        promotedRate = preset
                                                    }
                                                }) {
                                                    Text("\(preset, specifier: "%.0f")%")
                                                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                                                        .padding(.vertical, 4)
                                                        .padding(.horizontal, 8)
                                                        .background(promotedRate == preset ? Color.white : Color(white: 0.2))
                                                        .foregroundColor(promotedRate == preset ? .black : .white)
                                                        .cornerRadius(4)
                                                }
                                            }
                                        }
                                        
                                        Text("\(promotedRate, specifier: "%.1f")%")
                                            .foregroundColor(.white)
                                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                                            .frame(width: 50, alignment: .trailing)
                                    }
                                    Slider(value: $promotedRate, in: 1...20, step: 0.5)
                                        .accentColor(.white)
                                }
                                .padding()
                                .background(Color(white: 0.11))
                                .cornerRadius(8)
                                .padding(.top, 4)
                                .transition(.move(edge: .top).combined(with: .opacity))
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: promotedEnabled)
                        
                        toggleCard(title: "International Buyer", isOn: $internationalBuyer)
                    }

                    // --- CLEAR ALL BUTTON (CLEAN FLAT STYLE) ---
                    Button(action: clearAllFields) {
                        HStack {
                            Spacer()
                            Text("CLEAR ALL INPUTS")
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .foregroundColor(Color(white: 0.4))
                            Spacer()
                        }
                        .padding()
                        .background(Color(white: 0.05))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(white: 0.15), lineWidth: 1)
                        )
                    }

                    ResultsSection(calculator: calculator, showBreakdown: $showBreakdown, animation: animation)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            haptic.prepare()
        }
        .onChange(of: itemPrice) { oldValue, newValue in sanitizeInput(&itemPrice) }
        .onChange(of: shippingPrice) { oldValue, newValue in sanitizeInput(&shippingPrice) }
        .onChange(of: promotedEnabled) { oldValue, newValue in haptic.impactOccurred() }
        .onChange(of: internationalBuyer) { oldValue, newValue in haptic.impactOccurred() }
        .onChange(of: over250Listings) { oldValue, newValue in haptic.impactOccurred() }
    }

    private func handleSecretTap() {
        secretTapCount += 1
        
        if secretTapCount >= 3 && secretTapCount < 10 {
            // Give an increasingly heavy vibration on every tap after 3
            haptic.impactOccurred(intensity: CGFloat(Double(secretTapCount) / 10.0))
        }
        
        if secretTapCount >= 10 {
            fatalError("OH ONE MORE FUCKING TIME AND ILL CRASH THIS APP")
        }
    }

    private func clearAllFields() {
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
            showBreakdown = false
            focusedField = nil
            secretTapCount = 0
        }
    }
    
    private func copyToClipboard() {
        haptic.impactOccurred(intensity: 0.8)
        UIPasteboard.general.string = String(format: "%.2f", calculator.payout)
        withAnimation { showCopiedMessage = true }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation { showCopiedMessage = false }
        }
    }
    
    private func sanitizeInput(_ input: inout String) {
        if input.count > 1 && input.hasPrefix("0") && !input.hasPrefix("0.") {
            input.removeFirst()
        }
    }
    
    private func inputCard(title: String, text: Binding<String>, field: Field) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(Color(white: 0.5))
            
            HStack(spacing: 4) {
                Text("$")
                    .foregroundColor(Color(white: 0.3))
                    .font(.system(size: 22, weight: .regular, design: .monospaced))
                TextField("0.00", text: text)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 22, weight: .regular, design: .monospaced))
                    .foregroundColor(.white)
                    .focused($focusedField, equals: field)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(white: 0.11))
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(focusedField == field ? Color.white : Color.clear, lineWidth: 1.5)
                .padding(-1)
        )
        .animation(.easeInOut(duration: 0.2), value: focusedField)
    }

    private func pickerCard(title: String, selection: Binding<String>, options: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .regular, design: .monospaced))
                .foregroundColor(Color(white: 0.5))
            
            Picker("", selection: selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.menu)
            .tint(.white)
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(white: 0.11))
        .cornerRadius(8)
    }
    
    private func toggleCard(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.system(size: 15, weight: .regular, design: .monospaced))
                .foregroundColor(.white)
        }
        .tint(.white)
        .padding()
        .background(Color(white: 0.11))
        .cornerRadius(8)
    }
    
    @ViewBuilder
    var wittyRemarks: some View {
        VStack(spacing: 4) {
            if calculator.payout < 0 {
                Text("congratulations, you paid eBay to take your item")
            } else if calculator.payout < 5 && itemValue > 0 {
                Text("why are you selling this lol")
            } else if itemValue > 10000 {
                Text("money laundering at its finest")
            } else if selectedCategory == "NFTs" {
                Text("bro still trying to sell jpegs in 2026")
            } else if over250Listings && calculator.payout < 10 && itemValue > 0 {
                Text("250+ listings and you're still broke")
            } else if selectedState == "California" && calculator.estimatedTax > 50 {
                Text("california taxes hitting harder than reality")
            } else if selectedCategory == "Trading Cards / Collectibles" && !promotedEnabled {
                Text("good luck selling cardboard without ads")
            } else if calculator.sellerFees > 50 {
                Text("eBay sends their regards")
            } else if shippingValue > itemValue && itemValue > 0 {
                Text("what are you shipping, a refrigerator?")
            } else if promotedRate > 15 && promotedEnabled {
                Text("you're just buying acres of ad now")
            } else if internationalBuyer && calculator.sellerFees > 50 {
                Text("global financial devastation")
            } else {
                Text("app and witty remarks written by bitetheapple")
            }
        }
        .font(.system(size: 12, weight: .regular, design: .monospaced))
        .foregroundColor(Color(white: 0.4))
        .animation(.easeInOut, value: calculator.payout)
    }
}
