# ForexKit

Swift package to fetch and convert currencies.

- [Examples](#examples)
- [Installation](#installation)
- [Documentation](#documentation)
- [License](./LICENSE)

## Examples

### Retrieving exchange rates

```swift
import ForexKit

let forexKit = ForexKit()

let preferredCurrency: Currencies = .JPY
let result = await forexKit.getLatest(base: preferredCurrency, symbols: Currencies.allCases)
switch result {
case .failure(let failure):
    // Handle errors accordingly
case .success(let success):
    // Successfully retrieved exchange rates.
}
```

### Converting currencies.

```swift
import ForexKit

let forexKit = ForexKit()

let base = (22.0, Currencies.TRY)
// `exchangeRates` fetched in example of # Retrieving exchange rates
let convertedValue = forexKit.convert(from: base, to: .CAD, withRatesFrom: exchangeRates)
```

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is the easiest way to install and manage **ForexKit** as a dependency.  
Simply add **ForexKit** to your dependencies in your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/kamaal111/ForexKit.git", .upToNextMajor(from: "3.1.0")),
]
```

Alternatively, you can also use Xcode to add **ForexKit** to your existing project, by using `File > Swift Packages > Add Package Dependency...`.

## Documentation

Make sure you have **ForexKit** installed, if not follow these steps [here](#installation).

While Xcode is open with your project select `Product > Build Documentation`, then when the documentation window pops up, select **ForexKit**
