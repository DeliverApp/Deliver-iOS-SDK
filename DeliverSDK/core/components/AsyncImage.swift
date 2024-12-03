//
//  AsyncImage.swift
//  Deliver-Store
//
//  Created by Benjamin FROLICHER on 23/11/2024.
//

import SwiftUI
import Combine

internal struct AsyncImage<Placeholder: View, ErrorImage: View>: View {
    @StateObject private var loader: ImageLoader
    private let placeholder: Placeholder
    private let errorImage: ErrorImage
    private let image: (UIImage) -> AnyView
    
    init(
        url: URL,
        @ViewBuilder placeholder: () -> Placeholder,
        errorImage: () -> ErrorImage,
        @ViewBuilder image: @escaping (UIImage) -> some View = Image.init(uiImage:)
    ) {
        self.placeholder = placeholder()
        self.errorImage = errorImage()
        self.image = { uiImage in AnyView(image(uiImage)) }
        _loader = StateObject(wrappedValue: ImageLoader(url: url, cache: TemporaryImageCache.shared))
    }
    
    var body: some View {
        content
            .onAppear(perform: loader.load)
    }
    
    @ViewBuilder
    private var content: some View {
        if let imageToShow = loader.image {
            image(imageToShow)  // Display the image
        } else if loader.hasError {
            errorImage
        } else {
            placeholder  // Display placeholder while loading
        }
    }
}

//
//
//struct ImageCacheKey: EnvironmentKey {
//    static let defaultValue: ImageCache = TemporaryImageCache()
//}
//
//extension EnvironmentValues {
//    
//    var imageCache: ImageCache {
//        get { self[ImageCacheKey.self] }
//        set { self[ImageCacheKey.self] = newValue }
//    }
//}


internal protocol ImageCache {
    subscript(_ url: URL) -> UIImage? { get set }
}

internal struct TemporaryImageCache: ImageCache {
    
    static let shared: TemporaryImageCache = .init()
    
    private let cache: NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 100 // 100 items
        cache.totalCostLimit = 1024 * 1024 * 100 // 100 MB
        return cache
    }()
    
    subscript(_ key: URL) -> UIImage? {
        get { cache.object(forKey: key as NSURL) }
        set { newValue == nil ? cache.removeObject(forKey: key as NSURL) : cache.setObject(newValue!, forKey: key as NSURL) }
    }
}

internal class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var hasError = false  // Track errors
    
    private(set) var isLoading = false
    
    private let url: URL
    private var cache: ImageCache?
    private var cancellable: AnyCancellable?
    
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    init(url: URL, cache: ImageCache? = nil) {
        self.url = url
        self.cache = cache
    }
    
    deinit {
        cancel()
    }
    
    func load() {
        guard !isLoading else { return }
        
        if let cachedImage = cache?[url] {
            self.image = cachedImage
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.cache($0) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .subscribe(on: Self.imageProcessingQueue)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.image = $0
                if $0 == nil { self?.hasError = true }  // Set error state if image is nil
            }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func cache(_ image: UIImage?) {
        image.map { cache?[url] = $0 }
    }
}
