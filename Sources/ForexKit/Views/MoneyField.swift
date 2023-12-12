//
//  MoneyField.swift
//
//
//  Created by Kamaal M Farah on 02/12/2023.
//

import SwiftUI
import KamaalUI

/// Picker and text field with bindable ``Currencies`` and `String` values.
public struct MoneyField: View {
    @State private var valueIsValid = true

    @Binding var currency: Currencies
    @Binding var value: String

    let title: String
    let currencies: [Currencies]
    let fixButtonTitle: String
    let fixMessage: String

    /// Initialzer for ``MoneyField``.
    /// - Parameters:
    ///   - currency: Binded ``Currencies``.
    ///   - value: Binded text value.
    ///   - title: Field title.
    ///   - currencies: The ``Currencies``s to pick.
    ///   - fixButtonTitle: Title to show user when the value is invalid.
    ///   - fixMessage: Message to show user when the value is invalid.
    public init(
        currency: Binding<Currencies>,
        value: Binding<String>,
        title: String,
        currencies: [Currencies],
        fixButtonTitle: String,
        fixMessage: String
    ) {
            self._currency = currency
            self._value = value
            self.title = title
            self.currencies = currencies
            self.fixButtonTitle = fixButtonTitle
            self.fixMessage = fixMessage
        }

    public var body: some View {
        VStack(alignment: .leading) {
            KTitledView(title: title) {
                HStack {
                    Picker("", selection: $currency) {
                        ForEach(currencies, id: \.self) { currency in
                            Text(currency.rawValue)
                                .tag(currency)
                        }
                    }
                    .labelsHidden()
                    #if os(macOS)
                    .frame(width: 80)
                    #endif
                    TextField("", text: $value)
                    if !valueIsValid {
                        Button(action: fixValue) {
                            HStack(spacing: 0) {
                                Image(systemName: "hammer.fill")
                                Text(fixButtonTitle)
                                    .textCase(.uppercase)
                            }
                            .foregroundColor(.accentColor)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            if !valueIsValid {
                Text(fixMessage)
                    .font(.subheadline)
                    .foregroundColor(.red)
            }
        }
        .onChange(of: value, perform: handleValueChange)
        .onAppear(perform: handleOnAppear)
    }

    private func handleOnAppear() {
        handleValueChange(value)
    }

    private func handleValueChange(_ newValue: String) {
        let doubleValue = Double(value)
        if valueIsValid != (doubleValue != nil) {
            withAnimation { valueIsValid = (doubleValue != nil) }
        }
    }

    private func fixValue() {
        guard !valueIsValid else { return }

        let sanitizedValue = value.sanitizedDouble
        value = String(sanitizedValue)
    }
}

extension String {
    fileprivate var sanitizedDouble: Double {
        let splittedString = split(separator: ".", omittingEmptySubsequences: false)
        guard !splittedString.isEmpty else { return 0 }

        var processedFirstComponent = splittedString[0].filter(\.isNumber)
        if processedFirstComponent.isEmpty {
            processedFirstComponent = "0"
        }
        var components = [processedFirstComponent]
        if splittedString.count > 1 {
            components.append(splittedString[1].filter(\.isNumber))
        }

        return Double(components.joined(separator: ".")) ?? 0
    }
}

//struct MoneyField_Previews: PreviewProvider {
//    static var previews: some View {
//        MoneyField()
//    }
//}
