import SwiftUI

struct MatchedTransitionSourceModifier<ID: Hashable>: ViewModifier {
    let id: ID
    let namespace: Namespace.ID

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.matchedTransitionSource(id: id, in: namespace)
        } else {
            content
        }
    }
}

extension View {
    func matchedTransitionSourceIfAvailable<ID: Hashable>(id: ID, in namespace: Namespace.ID) -> some View {
        modifier(MatchedTransitionSourceModifier(id: id, namespace: namespace))
    }
}

struct ZoomNavigationTransitionModifier<ID: Hashable>: ViewModifier {
    let sourceID: ID
    let namespace: Namespace.ID

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.navigationTransition(.zoom(sourceID: sourceID, in: namespace))
        } else {
            content
        }
    }
}

extension View {
    func zoomNavigationTransitionIfAvailable<ID: Hashable>(sourceID: ID, in namespace: Namespace.ID) -> some View {
        modifier(ZoomNavigationTransitionModifier(sourceID: sourceID, namespace: namespace))
    }
}
