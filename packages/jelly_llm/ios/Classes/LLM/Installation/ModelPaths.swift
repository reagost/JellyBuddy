import Foundation

// MARK: - ModelPaths
//
// 静态路径解析: bundle 路径优先, 否则落到 Documents/models/<directoryName>。
// 从 MLXLocalLLMService.swift L278-332 原样迁移。

enum ModelPaths {

    static func resolve(for model: BundledModelOption) -> URL {
        if let bundled = bundled(for: model) {
            return bundled
        }
        return downloaded(for: model)
    }

    static func documentsRoot() -> URL {
        let documentsPath = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first!
        return documentsPath.appendingPathComponent("models", isDirectory: true)
    }

    static func downloaded(for model: BundledModelOption) -> URL {
        documentsRoot().appendingPathComponent(model.directoryName, isDirectory: true)
    }

    static func partial(for model: BundledModelOption) -> URL {
        documentsRoot().appendingPathComponent("\(model.directoryName).partial", isDirectory: true)
    }

    static func bundled(for model: BundledModelOption) -> URL? {
        guard let resourceURL = Bundle.main.resourceURL else { return nil }

        let directBundleDir = resourceURL.appendingPathComponent(
            model.directoryName,
            isDirectory: true
        )
        if hasRequiredFiles(model, at: directBundleDir) {
            return directBundleDir
        }

        let nestedBundleDir = resourceURL
            .appendingPathComponent("Models", isDirectory: true)
            .appendingPathComponent(model.directoryName, isDirectory: true)
        if hasRequiredFiles(model, at: nestedBundleDir) {
            return nestedBundleDir
        }

        return nil
    }

    static func hasRequiredFiles(_ model: BundledModelOption, at directory: URL) -> Bool {
        let fm = FileManager.default
        var isDirectory: ObjCBool = false
        guard fm.fileExists(atPath: directory.path, isDirectory: &isDirectory),
              isDirectory.boolValue else {
            return false
        }
        return model.requiredFiles.allSatisfy { file in
            fm.fileExists(atPath: directory.appendingPathComponent(file).path)
        }
    }

    /// Check if a model is available (bundled or downloaded with all required files).
    static func isAvailable(for model: BundledModelOption) -> Bool {
        if bundled(for: model) != nil { return true }
        return hasRequiredFiles(model, at: downloaded(for: model))
    }

    /// Delete downloaded model files (does not affect bundled models).
    static func deleteDownloaded(for model: BundledModelOption) {
        let dir = downloaded(for: model)
        try? FileManager.default.removeItem(at: dir)
        // Also clean up any partial download
        let partialDir = partial(for: model)
        try? FileManager.default.removeItem(at: partialDir)
    }
}
