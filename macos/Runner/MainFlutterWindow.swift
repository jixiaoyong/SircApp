import Cocoa
import FlutterMacOS
import ObjectiveC.runtime

// Application-side mitigation for Flutter's wrong-size macOS back-buffer cache.
// Remove after the SDK includes https://github.com/flutter/flutter/pull/192522.
// Keep Impeller enabled; reject only mismatched cached surfaces so the engine
// allocates a fresh one through its existing nil fallback.
private enum BackBufferSizeGuard {
  private static let installation: Void = {
    guard let cacheClass = NSClassFromString("FlutterBackBufferCache"),
          let surfaceClass = NSClassFromString("FlutterSurface"),
          let take = class_getInstanceMethod(cacheClass, NSSelectorFromString("removeSurfaceForSize:")),
          let size = class_getInstanceMethod(surfaceClass, NSSelectorFromString("size")),
          method_getNumberOfArguments(take) == 3,
          method_getNumberOfArguments(size) == 2 else {
      NSLog("BackBufferSizeGuard: engine API unavailable; protection not installed")
      return
    }
    typealias Take = @convention(c) (AnyObject, Selector, CGSize) -> Unmanaged<AnyObject>?
    typealias GetSize = @convention(c) (AnyObject, Selector) -> CGSize
    let original = unsafeBitCast(method_getImplementation(take), to: Take.self)
    let getSize = unsafeBitCast(method_getImplementation(size), to: GetSize.self)
    let selector = NSSelectorFromString("removeSurfaceForSize:")
    let sizeSelector = NSSelectorFromString("size")
    let replacement: @convention(block) (AnyObject, CGSize) -> AnyObject? = { cache, requested in
      guard let surface = original(cache, selector, requested)?.takeUnretainedValue() else {
        return nil
      }
      guard getSize(surface, sizeSelector) == requested else {
        NSLog("BackBufferSizeGuard: discarded cached surface with mismatched size")
        return nil
      }
      return surface
    }
    method_setImplementation(take, imp_implementationWithBlock(replacement))
    NSLog("BackBufferSizeGuard: installed")
  }()

  static func install() { _ = installation }
}

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    BackBufferSizeGuard.install()
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
