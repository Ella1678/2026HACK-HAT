import AVFoundation
import AppKit

func inspect(_ path: String) throws {
    let url = URL(fileURLWithPath: path)
    let asset = AVURLAsset(url: url)
    let dur = CMTimeGetSeconds(asset.duration)
    guard let track = asset.tracks(withMediaType: .video).first else {
        print("\(path)\tNO_VIDEO")
        return
    }
    let size = track.naturalSize
    let tf = track.preferredTransform
    let name = (path as NSString).lastPathComponent
    print("\(name)\tdur=\(String(format: "%.2f", dur))s\tsize=\(Int(size.width))x\(Int(size.height))\ttf=[\(tf.a),\(tf.b),\(tf.c),\(tf.d),\(tf.tx),\(tf.ty)]")

    let gen = AVAssetImageGenerator(asset: asset)
    gen.appliesPreferredTrackTransform = true
    gen.requestedTimeToleranceBefore = .zero
    gen.requestedTimeToleranceAfter = CMTime(seconds: 0.2, preferredTimescale: 600)
    let times: [Double] = [0.03, max(0.1, dur * 0.2), max(0.1, dur * 0.45), max(0.1, dur * 0.7), max(0.1, dur - 0.15)]
    let stem = (path as NSString).deletingPathExtension as NSString
    let base = stem.lastPathComponent
    for (idx, t) in times.enumerated() {
        do {
            let cg = try gen.copyCGImage(at: CMTime(seconds: t, preferredTimescale: 600), actualTime: nil)
            let rep = NSBitmapImageRep(cgImage: cg)
            if let data = rep.representation(using: .png, properties: [:]) {
                let out = "/Users/ziki/Documents/Codex/2026-09-05/s-f/work/frames/\(base)_\(idx).png"
                try data.write(to: URL(fileURLWithPath: out))
            }
        } catch {
            print("  frame fail \(t): \(error)")
        }
    }
    print("\(path)\tOK")
}

let paths = CommandLine.arguments.dropFirst()
for p in paths {
    do { try inspect(String(p)) }
    catch { print("ERR \(p): \(error)") }
}
