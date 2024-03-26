#import "CRCredentialsLoader.h"
#import "ZipArchive/SSZipArchive/SSZipArchive.h"

static NSString* cr_cached_working_directory_path = nil;

@implementation CRCredentialsLoader
    + (void) runWithUpdateBlock:(CRCredentialsLoaderUpdateBlock)updateBlock {
        NSLog(@"[Crunchyrold] Starting run");
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self deleteWorkingDirectory];
            [self createWorkingDirectory];
            dispatch_async(dispatch_get_main_queue(), ^{
                updateBlock(@"Downloading APK...", false);
            });
            if (![self downloadAPK]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    updateBlock(@"APK download failed.\n\nRestart the app to try again.", true);
                });
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                updateBlock(@"Unzipping APK...", false);
            });
            [self unzipAPK];
            dispatch_async(dispatch_get_main_queue(), ^{
                updateBlock(@"Extracting credentials...", false);
            });
            if (![self extractCredentials]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    updateBlock(@"Extracting credentials failed.\n\nRestart the app to try again.", true);
                });
                return;
            }
            [self deleteWorkingDirectory];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                updateBlock(@"Successfully obtained credentials.\n\nRestarting the app is required.", true);
            });
        });
    }
    
    + (NSString*) getWorkingDirectoryPath {
        if (cr_cached_working_directory_path) {
            return cr_cached_working_directory_path;
        }
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex: 0];
        cr_cached_working_directory_path = [NSString stringWithFormat: @"%@/crunchyrold", documentsDirectory];
        
        return cr_cached_working_directory_path;
    }
    
    + (void) createWorkingDirectory {
        [[NSFileManager defaultManager]
            createDirectoryAtPath: [self getWorkingDirectoryPath]
            withIntermediateDirectories: true
            attributes: @{}
            error: nil
        ];
    }
    
    + (void) deleteWorkingDirectory {
        [[NSFileManager defaultManager]
            removeItemAtPath: [self getWorkingDirectoryPath]
            error: nil
        ];
    }
    
    + (bool) downloadAPK {
        NSLog(@"[Crunchyrold] Downloading APK");
        
        NSURL* url = [NSURL URLWithString: @"https://d.apkpure.com/b/APK/com.crunchyroll.crunchyroid?versionCode=741"];
        NSData* urlData = [NSData dataWithContentsOfURL: url];
        if (urlData) {
            NSString* apkFilePath = [NSString stringWithFormat: @"%@/crunchyroll-apk.zip", [self getWorkingDirectoryPath]];
            
            [urlData writeToFile: apkFilePath atomically: true];
            
            NSLog(@"[Crunchyrold] Downloaded APK to path: %@", apkFilePath);
            return true;
        } else {
            NSLog(@"[Crunchyrold] APK download failed because URL data is nil");
            return false;
        }
    }
    
    + (void) unzipAPK {
        NSLog(@"[Crunchyrold] Unzipping APK");
        
        NSString* apkFilePath = [NSString stringWithFormat: @"%@/crunchyroll-apk.zip", [self getWorkingDirectoryPath]];
        NSString* apkFileContentsDirectoryPath = [NSString stringWithFormat: @"%@/crunchyroll-apk-contents", [self getWorkingDirectoryPath]];
        
        [SSZipArchive
            unzipFileAtPath: apkFilePath
            toDestination: apkFileContentsDirectoryPath
        ];
        
        NSLog(@"[Crunchyrold] Unzipped APK to path: %@", apkFileContentsDirectoryPath);
    }
    
    + (bool) extractCredentials {
        NSLog(@"[Crunchyrold] Extracting credentials");
        
        NSString* dexFilePath = [NSString stringWithFormat: @"%@/crunchyroll-apk-contents/classes2.dex", [self getWorkingDirectoryPath]];
        NSData* dexFileData = [NSData dataWithContentsOfFile: dexFilePath options: NSDataReadingMappedIfSafe error: nil];
        
        if (!dexFileData) {
            NSLog(@"[Crunchyrold] Failed to read dex file");
            return false;
        }
        
        NSData* clientIdData = [dexFileData subdataWithRange: NSMakeRange(0x65a25d, 20)];
        NSData* clientSecretData = [dexFileData subdataWithRange: NSMakeRange(0x5fc958, 32)];
        
        NSString* clientId = [[NSString alloc] initWithData: clientIdData encoding: NSUTF8StringEncoding];
        NSString* clientSecret = [[NSString alloc] initWithData: clientSecretData encoding: NSUTF8StringEncoding];
        
        NSLog(@"[Crunchyrold] Got client id: %@", clientId);
        NSLog(@"[Crunchyrold] Got client secret: %@", clientSecret);
        
        [[NSUserDefaults standardUserDefaults] setObject: clientId forKey: @"crunchyrold-client-id"];
        [[NSUserDefaults standardUserDefaults] setObject: clientSecret forKey: @"crunchyrold-client-secret"];
        
        return true;
    }
@end