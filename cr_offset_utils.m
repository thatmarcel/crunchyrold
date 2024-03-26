#import <substrate.h>
#import "cr_offset_utils.h"

intptr_t cr_client_id_offset = 0;
intptr_t cr_client_secret_offset = 0;

NSString* cr_get_image_name() {
    // e.g. when using palera1n with ellekit, the first dyld image
    // is libinjector.dylib so if that is the case we need to
    // try using the second dyld image, etc.
    
    for (int i = 0; i < 5; i += 1) {
        const char* image_name = _dyld_get_image_name(i);
        if (!image_name) { continue; }
        NSString* image_name_string = [[NSString alloc] initWithCString: image_name encoding: NSUTF8StringEncoding];
        
        if ([image_name_string containsString: @"Crunchyroll"]) {
            return image_name_string;
        }
    }
    
    return 0;
}

unsigned long cr_cached_image_file_size = 0;
unsigned long cr_get_image_file_size() {
    if (cr_cached_image_file_size) {
        return cr_cached_image_file_size;
    }
    
    NSURL *image_file_url = [NSURL fileURLWithPath: cr_get_image_name()];
    
    NSNumber *image_file_size = nil;
    NSError *image_file_size_retrieval_error = nil;
    
    [image_file_url
        getResourceValue: &image_file_size
        forKey: NSURLFileSizeKey
        error: &image_file_size_retrieval_error
    ];
    
    if (image_file_size_retrieval_error) {
        return 0;
    }
    
    cr_cached_image_file_size = [image_file_size longValue];
    return cr_cached_image_file_size;
}

intptr_t cr_cached_ref_addr = 0;
intptr_t cr_get_ref_addr() {
    // e.g. when using palera1n with ellekit, the first dyld image
    // is libinjector.dylib so if that is the case we need to
    // try using the second dyld image, etc.
    
    if (cr_cached_ref_addr) {
        return cr_cached_ref_addr;
    }
    
    for (int i = 0; i < 5; i += 1) {
        const char* image_name = _dyld_get_image_name(i);
        if (!image_name) { continue; }
        NSString* image_name_string = [[NSString alloc] initWithCString: image_name encoding: NSUTF8StringEncoding];
        
        if ([image_name_string containsString: @"Crunchyroll"]) {
            cr_cached_ref_addr = _dyld_get_image_vmaddr_slide(i) + 0x100000000;
            return cr_cached_ref_addr;
        }
    }
    
    return 0;
}

intptr_t cr_find_pattern_offset(const char* pattern, int pattern_length, int target_match_index, intptr_t start_offset, intptr_t max_offset_from_start_offset) {
    intptr_t ref_addr = cr_get_ref_addr();
    
    intptr_t current_start_addr = ref_addr;
    
    if (start_offset) {
        current_start_addr += start_offset;
    } else {
        current_start_addr += 0x000000004;
    }
    
    unsigned long search_limit = cr_get_image_file_size() - 200;
    
    intptr_t max_addr = start_offset + max_offset_from_start_offset;
    
    if (max_offset_from_start_offset && max_addr <= search_limit) {
        search_limit = max_addr;
    }
    
    int match_count = 0;
    
    for (int i = start_offset; i < search_limit; i += 1) {
        char value_at_start_addr = *((char*) current_start_addr);
        
        if (value_at_start_addr == pattern[0]) {
            bool has_failed = false;
            
            for (int current_pattern_index = 1; current_pattern_index < pattern_length; current_pattern_index += 1) {
                char value_at_current_pattern_addr = *((char*) (current_start_addr + current_pattern_index));
                
                if (value_at_current_pattern_addr != pattern[current_pattern_index]) {
                    has_failed = true;
                    break;
                }
            }
            
            if (!has_failed) {
                if (target_match_index == match_count) {
                    intptr_t offset_addr = current_start_addr - ref_addr;
                    
                    return offset_addr;
                } else {
                    match_count += 1;
                }
            }
        }
        
        current_start_addr += 1;
    }
    
    return 0;
}

bool cr_find_offsets() {
    // Start of the client id string
    NSString *client_id_string_content = @"tfdcxulg";
    
    cr_client_id_offset = cr_find_pattern_offset([client_id_string_content UTF8String], [client_id_string_content length], 0, 0, 0);
    
    if (!cr_client_id_offset) {
        return false;
    }
    
    // Start of the client secret string
    NSString *client_secret_string_content = @"A8aFeNIx";
    
    cr_client_secret_offset = cr_find_pattern_offset([client_secret_string_content UTF8String], [client_secret_string_content length], 0, 0, 0);
    
    if (!cr_client_secret_offset) {
        return false;
    }
    
    return true;
}