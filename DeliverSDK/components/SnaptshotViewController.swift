//
//  SnaptshotViewController.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 18/12/2023.
//

import UIKit
import QuickLook


/// Simple class to view and Edit a snapshot image
internal class SnaptshotViewController: QLPreviewController {
        
    fileprivate let snapshot: PreviewItem
    
    private var onEndEditingHandler: ((URL) -> Void)?
    
    internal init(snapshot: URL) {
        
        self.snapshot = PreviewItem(url: snapshot, title: "Snapshot")
        super.init(nibName: nil, bundle: nil)
        self.isEditing = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        
     
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.titleView = nil
        self.navigationController?.navigationItem.titleView = nil
        self.title = "Hello"
        self.setEditing(true, animated: true)
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.leftBarButtonItems = nil
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.rightBarButtonItems = nil
        
        
    }
    
    @discardableResult
    func onEndEditing(_ handler: @escaping (URL) -> Void) -> Self {
        onEndEditingHandler = handler
        return self
    }
}

extension SnaptshotViewController: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
   
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return snapshot
    }
    
    func previewController(_ controller: QLPreviewController, editingModeFor previewItem: QLPreviewItem) -> QLPreviewItemEditingMode {
        return .updateContents
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        guard let url = snapshot.previewItemURL else {return }
        onEndEditingHandler?(url)
    }
    
    func previewController(_ controller: QLPreviewController, didSaveEditedCopyOf previewItem: QLPreviewItem, at modifiedContentsURL: URL) {
        try! FileManager.default.removeItem(at: snapshot.previewItemURL!)
        try! FileManager.default.moveItem(at: modifiedContentsURL, to: snapshot.previewItemURL!)
    }
}

internal class PreviewItem: NSObject, QLPreviewItem {
    
    var previewItemURL: URL?
    var previewItemTitle: String?
    
    init(url: URL, title: String? = nil) {
        previewItemURL = url
        previewItemTitle = title
    }
}
