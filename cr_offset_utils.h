#import <Foundation/Foundation.h>
#import <mach-o/dyld.h>
#import <dlfcn.h>

extern intptr_t cr_client_id_offset;
extern intptr_t cr_client_secret_offset;

bool cr_find_offsets();

intptr_t cr_get_ref_addr();