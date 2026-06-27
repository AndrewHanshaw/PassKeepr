import CoreLocation
import LocationPicker
import MapKit
import SwiftUI

@Observable
private final class UserLocationProvider: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    var coordinate: CLLocationCoordinate2D? = nil

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }

    func requestIfNeeded() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        coordinate = locations.last?.coordinate
        manager.stopUpdatingLocation()
    }

    func locationManager(_: CLLocationManager, didFailWithError _: Error) {}

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
}

struct LocationSelection: View {
    @Binding var passObject: PassObject
    var disableControl: Bool

    @State private var showLocationSection: Bool = false
    @State private var editingIndex: Int? = nil
    @State private var pickerCoordinates: CLLocationCoordinate2D = .init()
    @State private var showPickerSheet = false
    @State private var removingIDs: Set<UUID> = []
    @State private var newIDs: Set<UUID> = []
    @State private var locationProvider = UserLocationProvider()

    private var hasLocations: Bool { !passObject.locations.isEmpty }
    private var atLimit: Bool { passObject.locations.count >= 10 }
    private var allLocationsSet: Bool { passObject.locations.allSatisfy { $0.latitude != 0 || $0.longitude != 0 } }

    private func addLocation() {
        let loc = PassLocation()
        newIDs.insert(loc.id)
        passObject.locations.append(loc)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Toggle("Location Alert", isOn: Binding(
                get: { hasLocations },
                set: { on in
                    if on {
                        locationProvider.requestIfNeeded()
                        addLocation()
                        showLocationSection = true
                    } else {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            passObject.locations.removeAll()
                            showLocationSection = false
                        }
                    }
                }
            ))
            .padding([.top, .bottom], 14)
            .overlay(alignment: .bottom) {
                if showLocationSection { Divider() }
            }
            .padding([.leading, .trailing], 14)
            .disabled(disableControl)

            if showLocationSection {
                ForEach(passObject.locations) { location in
                    let index = passObject.locations.firstIndex(where: { $0.id == location.id }) ?? 0
                    let isLast = location.id == passObject.locations.last?.id
                    let isRemoving = removingIDs.contains(location.id)
                    let isNew = newIDs.contains(location.id)

                    LocationRow(
                        location: location,
                        index: index,
                        isLast: isLast,
                        isRemoving: isRemoving,
                        isNew: isNew,
                        disableControl: disableControl,
                        onEdit: {
                            editingIndex = index
                            if location.latitude != 0 || location.longitude != 0 {
                                pickerCoordinates = CLLocationCoordinate2D(
                                    latitude: location.latitude,
                                    longitude: location.longitude
                                )
                            } else {
                                pickerCoordinates = locationProvider.coordinate ?? CLLocationCoordinate2D()
                            }
                            showPickerSheet = true
                        },
                        onDelete: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                removingIDs.insert(location.id)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                passObject.locations.removeAll { $0.id == location.id }
                                removingIDs.remove(location.id)
                            }
                        },
                        onDidAppear: {
                            newIDs.remove(location.id)
                        },
                        relevantText: Binding(
                            get: { location.relevantText },
                            set: { newValue in
                                if let i = passObject.locations.firstIndex(where: { $0.id == location.id }) {
                                    passObject.locations[i].relevantText = newValue
                                }
                            }
                        )
                    )
                }

                if !atLimit && allLocationsSet {
                    Divider().padding(.horizontal, 14)
                    Button(action: addLocation) {
                        Label("Add Location", systemImage: "plus.circle.fill")
                    }
                    .padding([.top, .leading], 14)
                    .padding(.bottom, 18)
                    .disabled(disableControl)
                }
            }
        }
        .listSectionBackgroundModifier()
        .onAppear {
            showLocationSection = hasLocations
        }
        .onChange(of: passObject.locations.isEmpty) { _, isEmpty in
            if isEmpty { showLocationSection = false }
        }
        .sheet(isPresented: $showPickerSheet) {
            NavigationStack {
                LocationPicker(coordinates: $pickerCoordinates, zoomLevel: 4000, showCoordinatesOverlay: true, ignoreSafeArea: true)
                    .navigationTitle("Set Location")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                if let i = editingIndex {
                                    passObject.locations[i].latitude = pickerCoordinates.latitude
                                    passObject.locations[i].longitude = pickerCoordinates.longitude
                                }
                                showPickerSheet = false
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                showPickerSheet = false
                            }
                        }
                    }
            }
        }
    }
}

private struct LocationRow: View {
    let location: PassLocation
    let index: Int
    let isLast: Bool
    let isRemoving: Bool
    let isNew: Bool
    let disableControl: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onDidAppear: () -> Void
    @Binding var relevantText: String

    @State private var isExpanded: Bool = false

    private var hasCoordinates: Bool {
        location.latitude != 0 || location.longitude != 0
    }

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
                Text(hasCoordinates
                    ? String(format: "%.5f, %.5f", location.latitude, location.longitude)
                    : "No location set")
                    .padding(.top, 14)

                TextField("Alert Text", text: $relevantText)
                    .padding(.bottom, 14)
                    .disabled(disableControl)
            }

            Spacer()

            Button(hasCoordinates ? "Change Location" : "Set Location") {
                onEdit()
            }
            .disabled(disableControl)

            Button(role: .destructive, action: onDelete) {
                Image(systemName: "minus.circle.fill")
            }
            .disabled(disableControl)
            .padding(.trailing, 8)
        }
        .frame(height: isRemoving ? 0 : (isNew && !isExpanded ? 0 : nil), alignment: .top)
        .clipped()
        .onAppear {
            if isNew {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded = true
                }
                // Clean up after animation so this row is no longer tracked as new
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    onDidAppear()
                }
            }
        }
        .overlay(alignment: .bottom) {
            if !isLast { Divider() }
        }
        .padding(.horizontal, 14)
    }
}

#Preview {
    LocationSelection(passObject: .constant(MockModelData().passObjects[0]), disableControl: false)
}
