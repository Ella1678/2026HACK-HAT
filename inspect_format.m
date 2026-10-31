#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>

static NSString *fourcc(OSType t) {
    char buf[5] = {0};
    buf[0] = (char)((t >> 24) & 0xff);
    buf[1] = (char)((t >> 16) & 0xff);
    buf[2] = (char)((t >> 8) & 0xff);
    buf[3] = (char)(t & 0xff);
    return [NSString stringWithFormat:@"%s (0x%08x)", buf, (unsigned)t];
}

int main(int argc, const char **argv) {
    @autoreleasepool {
        for (int i = 1; i < argc; i++) {
            NSString *path = [NSString stringWithUTF8String:argv[i]];
            NSURL *url = [NSURL fileURLWithPath:path];
            AVURLAsset *asset = [AVURLAsset assetWithURL:url];
            NSLog(@"=== %@", path.lastPathComponent);
            NSArray *vids = [asset tracksWithMediaType:AVMediaTypeVideo];
            NSArray *auds = [asset tracksWithMediaType:AVMediaTypeAudio];
            NSLog(@"video tracks %lu audio tracks %lu", (unsigned long)vids.count, (unsigned long)auds.count);
            for (AVAssetTrack *tr in vids) {
                NSLog(@"track dur %.2f fps %.3f nominal %.3f", CMTimeGetSeconds(tr.timeRange.duration), tr.nominalFrameRate, tr.nominalFrameRate);
                for (id fdObj in tr.formatDescriptions) {
                    CMFormatDescriptionRef fd = (__bridge CMFormatDescriptionRef)fdObj;
                    CMVideoCodecType codec = CMFormatDescriptionGetMediaSubType(fd);
                    NSLog(@"  codec %@", fourcc(codec));
                    NSDictionary *dict = (__bridge NSDictionary *)CMFormatDescriptionGetExtension(fd, (__bridge CFStringRef)@"FormatName");
                    NSLog(@"  formatname %@", dict);
                    CFStringRef name = (CFStringRef)CMFormatDescriptionGetExtension(fd, CFSTR("FormatName"));
                    if (name) { NSLog(@"  fname %@", name); }
                    if (codec == kCMVideoCodecType_HEVC || codec == kCMVideoCodecType_HEVCWithAlpha) {
                        CMVideoDimensions dims = CMVideoFormatDescriptionGetDimensions(fd);
                        NSLog(@"  dims %dx%d", dims.width, dims.height);
                        NSDictionary *ext = (__bridge NSDictionary *)CMFormatDescriptionGetExtensions(fd);
                        NSLog(@"  ext %@", ext);
                    }
                }
            }
        }
    }
    return 0;
}
