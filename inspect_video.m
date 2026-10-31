#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AppKit/AppKit.h>

static NSString *strFromTrans(CGAffineTransform t) {
    return [NSString stringWithFormat:@"[%.4f,%.4f,%.4f,%.4f,%.4f,%.4f]", t.a, t.b, t.c, t.d, t.tx, t.ty];
}

static void inspect(NSString *path) {
    @autoreleasepool {
        NSURL *url = [NSURL fileURLWithPath:path];
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        double dur = CMTimeGetSeconds(asset.duration);
        NSArray *vids = [asset tracksWithMediaType:AVMediaTypeVideo];
        if (vids.count == 0) {
            NSLog(@"%@\tNO_VIDEO", path.lastPathComponent);
            return;
        }
        AVAssetTrack *track = vids[0];
        CGSize size = track.naturalSize;
        NSLog(@"%@\tdur=%.2f\tsize=%dx%d\ttf=%@",
              path.lastPathComponent, dur, (int)size.width, (int)size.height,
              strFromTrans(track.preferredTransform));

        AVAssetImageGenerator *gen = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        gen.requestedTimeToleranceBefore = kCMTimeZero;
        gen.requestedTimeToleranceAfter = CMTimeMakeWithSeconds(0.2, 600);
        NSArray *times = @[
            @(0.03), @(MAX(0.1, dur*0.2)), @(MAX(0.1, dur*0.45)), @(MAX(0.1, dur*0.7)), @(MAX(0.1, dur-0.15))
        ];
        NSString *base = path.lastPathComponent.stringByDeletingPathExtension;
        for (int i = 0; i < times.count; i++) {
            CMTime t = CMTimeMakeWithSeconds([times[i] doubleValue], 600);
            NSError *err = nil;
            CGImageRef cg = [gen copyCGImageAtTime:t actualTime:NULL error:&err];
            if (!cg) {
                NSLog(@"  frame %d fail: %@", i, err);
                continue;
            }
            NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:cg];
            NSData *png = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
            CGImageRelease(cg);
            NSString *out = [NSString stringWithFormat:@"/Users/ziki/Documents/Codex/2026-09-05/s-f/work/frames/%@_%d.png", base, i];
            [png writeToFile:out atomically:YES];
        }
    }
}

int main(int argc, const char **argv) {
    @autoreleasepool {
        for (int i = 1; i < argc; i++) {
            inspect([NSString stringWithUTF8String:argv[i]]);
        }
    }
    return 0;
}
