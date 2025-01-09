//
//  EditIssueViewModel.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 02/01/2024.
//

import Foundation

/// ViewModel responsible for handling the editing of an issue, including the issue's title,
/// description, and associated media (such as logs or network files).
/// It communicates with the `IssueAPI` to post the issue to the server.
class EditIssueViewModel: ObservableObject {
    
    /// The title of the issue.
    @Published var issueTitle: String = ""
    
    /// The description of the issue.
    @Published var description: String = ""
    
    /// Flag indicating whether network logs should be attached to the issue.
    @Published var attachNetwork: Bool = true
    
    /// Flag indicating whether device logs should be attached to the issue.
    @Published var attachLogs: Bool = true
    
    /// The handler function that is called when the close action is triggered.
    private var onCloseHandler: (() -> Void)?
    
    /// The build associated with the issue.
    @Published var build: Build? = Context.shared.build
    
    /// The media (file URL) to be attached to the issue, such as a log or screenshot.
    var media: URL?
    
    /// Initializes the view model with an optional media URL.
    ///
    /// - Parameter media: An optional URL representing the file (e.g., screenshot or log file) to attach to the issue.
    init(media: URL?) {
        self.media = media
    }
    
    /// Sets the handler to be called when the view is closed.
    ///
    /// - Parameter handler: The closure that will be called when the `close()` method is triggered.
    /// - Returns: The `EditIssueViewModel` instance itself for chaining.
    @discardableResult
    func onClose(_ handler: (() -> Void)?) -> Self {
        onCloseHandler = handler
        return self
    }
    
    // MARK: - Actions
    
    /// Triggers the close action, calling the `onCloseHandler` if set.
    func close() {
        self.onCloseHandler?()
    }
    
    /// Posts the issue to the API.
    ///
    /// This method creates a new issue using the title, description, and optional media file (e.g., logs or screenshots).
    /// It uses the `IssueAPI` to send the issue details to the server, and upon successful submission, the view is closed.
    func postIssue() {
        Task {
            let api = IssueAPI()
            // Create the issue DTO and report it to the API.
            try await api.report(issue: IssueAPI.CreateIssueDTO(title: self.issueTitle, description: self.description, criticality: "LOW"),
                                 fileURL: self.media)
            // Close the view after posting the issue.
            DispatchQueue.main.async { self.close() }
        }
    }
}

