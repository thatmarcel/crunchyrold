#import <UIKit/UIKit.h>
#import <substrate.h>
#import "cr_hooking_utils.h"
#import "CRCredentialsLoader.h"

@interface CrunchyrollForceUpgradeViewController: UIViewController
@end

%hook VSSubscriptionRegistrationCenter
    // When the app was sideloaded without the correct entitlements,
    // this might crash the app
    - (void) registerSubscription:(id)subscription { }
%end

void cr_show_manual_credentials_input_alert(UIViewController* presentingViewController) {
    UIAlertController* alertController = [UIAlertController
        alertControllerWithTitle: @"Manual input"
        message: @"You need to input the client id and client secret from a supported version of the app used for Basic authentication.\n\nTo change these values again, you need to reinstall or reset the app.\n\nRestarting the app is required to apply the new credentials."
        preferredStyle: UIAlertControllerStyleAlert
    ];
    
    [alertController addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
        textField.placeholder = @"Client identifier (username)";
    }];
    
    [alertController addTextFieldWithConfigurationHandler: ^(UITextField *textField) {
        textField.placeholder = @"Client secret (password)";
    }];
    
    UIAlertAction* saveButton = [UIAlertAction
        actionWithTitle: @"Save and close app"
        style: UIAlertActionStyleDefault
        handler: ^(UIAlertAction* action) {
            [[NSUserDefaults standardUserDefaults] setObject: alertController.textFields[0].text forKey: @"crunchyrold-client-id"];
            [[NSUserDefaults standardUserDefaults] setObject: alertController.textFields[1].text forKey: @"crunchyrold-client-secret"];
            
            exit(0);
        }
    ];
    
    UIAlertAction* cancelButton = [UIAlertAction
        actionWithTitle: @"Cancel"
        style: UIAlertActionStyleCancel
        handler: ^(UIAlertAction* action) { }
    ];
    
    [alertController addAction: cancelButton];
    [alertController addAction: saveButton];
    
    [presentingViewController presentViewController: alertController animated: true completion: nil];
}

void cr_do_automatic_extraction(UIViewController* presentingViewController) {
    UIAlertController* alertController = [UIAlertController
        alertControllerWithTitle: @"Automatic extraction"
        message: @"Preparing"
        preferredStyle: UIAlertControllerStyleAlert
    ];
    
    [presentingViewController presentViewController: alertController animated: true completion: nil];
    
    [CRCredentialsLoader runWithUpdateBlock: ^(NSString* currentStepDescription, bool isFinished) {
        [alertController setMessage: currentStepDescription];
        
        if (isFinished) {
            UIAlertAction* closeButton = [UIAlertAction
                actionWithTitle: @"Close app"
                style: UIAlertActionStyleDefault
                handler: ^(UIAlertAction* action) {
                    exit(0);
                }
            ];
            
            [alertController addAction: closeButton];
        }
    }];
}

void cr_show_info_alert(UIViewController* presentingViewController) {
    UIAlertController* alertController = [UIAlertController
        alertControllerWithTitle: @"Credentials missing"
        message: @"This tweak doesn't ship with the API credentials required to make the app work.\n\nIf you want, we can automatically download the Crunchyroll Android app from APKPure and extract the required credentials.\n\nAlternatively, you can input the credentials yourself."
        preferredStyle: UIAlertControllerStyleAlert
    ];
    
    UIAlertAction* automaticExtractionButton = [UIAlertAction
        actionWithTitle: @"Extract automatically"
        style: UIAlertActionStyleDefault
        handler: ^(UIAlertAction* action) {
            [alertController dismissViewControllerAnimated: true completion: nil];
            
            cr_do_automatic_extraction(presentingViewController);
        }
    ];
    
    UIAlertAction* manualInputButton = [UIAlertAction
        actionWithTitle: @"Input manually"
        style: UIAlertActionStyleDefault
        handler: ^(UIAlertAction* action) {
            [alertController dismissViewControllerAnimated: true completion: nil];
            
            cr_show_manual_credentials_input_alert(presentingViewController);
        }
    ];
    
    UIAlertAction* cancelButton = [UIAlertAction
        actionWithTitle: @"Cancel"
        style: UIAlertActionStyleCancel
        handler: ^(UIAlertAction* action) { }
    ];
    
    [alertController addAction: automaticExtractionButton];
    [alertController addAction: manualInputButton];
    [alertController addAction: cancelButton];
    
    [presentingViewController presentViewController: alertController animated: true completion: nil];
}

%hook CrunchyrollForceUpgradeViewController

    - (void) viewDidAppear:(BOOL)animated {
        %orig;
        
        cr_show_info_alert(self);
    }

%end

%ctor {
    NSLog(@"[Crunchyrold] Loaded");
    
    cr_load_credentials_and_setup_hooks();
    
    %init(CrunchyrollForceUpgradeViewController=objc_getClass("Crunchyroll.ForceUpgradeViewController"));
}