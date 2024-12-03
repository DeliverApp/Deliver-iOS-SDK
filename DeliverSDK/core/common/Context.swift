//
//  Context.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 23/11/2024.
//

import Foundation

/// A singleton class that provides access to the application's context, including user information,
/// API base URL, session details, and various state flags. It manages the application's shared state
/// and provides a centralized location for configuration and runtime data.
internal class Context: ObservableObject {
    
    /// The shared instance of the `Context` class.
    /// This is a singleton object, and all references to the application's context will use this instance.
    static let shared = Context()
    
    /// The base URL for the API the app communicates with.
    /// The URL is different for the debug and release environments.
    /// - In debug mode: "https://store.deliverapp.io/api" (or a local address can be used, e.g., "http://bfrolicher.local:4100/api")
    /// - In production mode: "https://store.deliverapp.io/api"
    let apiBaseUrl: String = {
#if DEBUG
        return "https://store.deliverapp.io/api" // Or "http://bfrolicher.local:4100/api" for local testing
#else
        return "https://store.deliverapp.io/api"
#endif
    }()
    
    /// The access token used for authenticating API requests.
    /// This is set after the user logs in and is used to authorize the user's API requests.
    var acccessToken: String?
    
    /// The current authenticated user object.
    /// This holds the details of the currently authenticated user, such as their name, email, etc.
    var user: User?
    
    /// A key used for identifying or differentiating instances of the app.
    /// This can be used for various configuration or session-related purposes.
    var key: String = ""
    
    /// The build object representing the current version and build of the application.
    /// This object may hold information related to the app's version, deployment, or update state.
    var build: Build?
    
    /// The build number of the application, typically used for version tracking.
    /// This value is fetched from the app's `Info.plist` under the key `"CFBundleVersion"`.
    var buildNumber: String? = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    /// A unique session ID generated for each app session.
    /// This ID is used to track and identify the user's session in the app.
    var sessionId = UUID().uuidString
    
    /// A flag indicating whether the log activity is currently active.
    /// This is published to allow other parts of the app to reactively update when the log state changes.
    @Published internal var isLogActive: Bool = false
    
    /// A flag indicating whether the network is currently active (e.g., a network request is ongoing).
    /// This is published to allow other parts of the app to reactively update when the network state changes.
    @Published internal var isNetworkActive: Bool = false
    
    /// Initializes a new instance of `Context`.
    ///
    /// - Note: This class uses a singleton pattern, so this initializer is only called once when the `shared` instance is accessed.
    required init() {}
}

