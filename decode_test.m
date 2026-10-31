#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

int main(int argc, const char **argv) {
    @autoreleasepool {
        NSString *path = [NSString stringWithUTF8String:argv[1]];
        NSURL *url = [NSURL fileURLWithPath:path];
        AVURLAsset *asset = [AVURLAsset assetWithURL:url];
        NSError *err = nil;
        AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:&err];
        if (!reader) { NSLog(@"reader fail %@", err); return 1; }
        NSArray *vids = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack *track = vids[0];
        NSDictionary *settings = @{
            (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)
        };
        AVAssetReaderTrackOutput *out = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:track outputSettings:settings];
        [reader addOutput:out];
        BOOL ok = [reader startReading];
        NSLog(@"start ok %d status %ld err %@", ok, (long)reader.status, err);
        int count = 0;
        while (ok && count < 8 && reader.status == AVAssetReaderStatusReading) {
            CMSampleBufferRef sb = [out copyNextSampleBuffer];
            if (!sb) { NSLog(@"no sample status %ld", (long)reader.status); break; }
            CVImageBufferRef img = CMSampleBufferGetImageBuffer(sb);
            NSLog(@"sample %d image %@ size %d", count, img ? @"yes" : @"no", img ? (int)CVPixelBufferGetWidth(img) : 0);
            if (img) { CFRelease(sb); count++; continue; }
            CFRelease(sb);
        }
        NSLog(@"final status %ld", (long)reader.status);
        return 0;
    }
}
