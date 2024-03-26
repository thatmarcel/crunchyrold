#import <substrate.h>
#import "cr_hooking_utils.h"
#import "cr_offset_utils.h"

void cr_setup_hooks(const char* new_client_id, const char* new_client_secret) {
    bool has_found_offsets = cr_find_offsets();
    
    if (!has_found_offsets) {
        return;
    }
    
    intptr_t ref_addr = cr_get_ref_addr();
    
    void* client_id_offset_pointer = (void*) (ref_addr + cr_client_id_offset);
    void* client_secret_offset_pointer = (void*) (ref_addr + cr_client_secret_offset);
    
    MSHookMemory(client_id_offset_pointer, new_client_id, 20);
    MSHookMemory(client_secret_offset_pointer, new_client_secret, 32);
}

bool cr_load_credentials_and_setup_hooks() {
    NSString *clientId = [[NSUserDefaults standardUserDefaults] stringForKey: @"crunchyrold-client-id"];
    NSString *clientSecret = [[NSUserDefaults standardUserDefaults] stringForKey: @"crunchyrold-client-secret"];
    
    if (clientId && clientSecret) {
        cr_setup_hooks([clientId UTF8String], [clientSecret UTF8String]);
        return true;
    }
    
    return false;
}