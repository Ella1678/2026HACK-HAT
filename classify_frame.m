#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
#import <Vision/Vision.h>

int main(int argc, const char **argv) {
    @autoreleasepool {
        if (argc < 2) return 1;
        for (int a = 1; a < argc; a++) {
            NSString *path = [NSString stringWithUTF8String:argv[a]];
            NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithContentsOfFile:path];
            CGImageRef cg = rep.CGImage;
            if (!cg) { NSLog(@"no image %@", path); continue; }
            VNClassifyImageRequest *req = [[VNClassifyImageRequest alloc] init];
            VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:cg options:@{}];
            NSError *err = nil;
            [handler performRequests:@[req] error:&err];
            if (err) { NSLog(@"classify err %@ %@", path.lastPathComponent, err); continue; }
            NSArray *res = req.results;
            NSLog(@"== %@", path.lastPathComponent);
            for (VNClassificationObservation *o in [res subarrayWithRange:NSMakeRange(0, MIN(12, res.count))]) {
                NSLog(@"  %@ %.3f", o.identifier, o.confidence);
            }
        }
    }
    return 0;
}
