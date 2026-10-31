#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Vision/Vision.h>

int main(int argc, const char **argv) {
    @autoreleasepool {
        if (argc < 2) return 1;
        for (int a = 1; a < argc; a++) {
            NSString *path = [NSString stringWithUTF8String:argv[a]];
            NSImage *img = [[NSImage alloc] initWithContentsOfFile:path];
            CGImageRef cg = [img CGImageForProposedRect:nil context:nil hints:nil];
            if (!cg) { NSLog(@"no image %@", path); continue; }
            VNRecognizeTextRequest *req = [[VNRecognizeTextRequest alloc] init];
            req.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
            req.recognitionLanguages = @[@"zh-Hans", @"en-US"];
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:cg options:@{}];
            NSError *err = nil;
            [handler performRequests:@[req] error:&err];
            if (err) { NSLog(@"ocr err %@", err); continue; }
            NSLog(@"== %@", path.lastPathComponent);
            for (VNRecognizedTextObservation *obs in req.results) {
                VNRecognizedText *cand = [obs topCandidates:1].firstObject;
                CGRect b = obs.boundingBox;
                NSLog(@"  text=%@ bbox=(%.3f,%.3f,%.3f,%.3f) conf=%.2f", cand.string, b.origin.x, b.origin.y, b.size.width, b.size.height, cand.confidence);
            }
        }
    }
    return 0;
}
