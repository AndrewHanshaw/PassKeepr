import CoreImage

// One CIContext for the whole app. Creating a CIContext is expensive, and a shared one lets
// Core Image reuse its GPU resources across renders. Used by the barcode generators and the
// pass background image cache. Thread safe.
enum SharedCIContext {
    static let context = CIContext()
}
