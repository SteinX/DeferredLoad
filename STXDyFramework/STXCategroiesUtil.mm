//
//  STXCategroiesUtil.m
//  CategroriesTest
//
//  Created by steinx on 2020/3/20.
//  Copyright © 2020 steinx. All rights reserved.
//

#import "STXCategroiesUtil.h"
#import "objc-util.h"

#import <objc/runtime.h>
#import <mach-o/ldsyms.h>
#import <mach-o/dyld.h>

@implementation STXCategroiesUtil

+ (void)call {
    auto loadable_list = get_loadable_list();
    auto count = nb_loadable_item();
    
    for (int i = 0; i < count; i++) {
        struct loadable_class info = loadable_list[i];
        (*info.method)(info.cls, @selector(load));
    }
    
    free_loadable_list();
}

+ (void)_data {
    auto executableName = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"] UTF8String];
    uint32_t index = 0;
    uint32_t imageCount = _dyld_image_count();
    size_t count;
    
    for (int32_t i = 0; i < imageCount; i++) {
        auto name = _dyld_get_image_name(i);
        auto subname = strrchr(name, '/');
        if (subname == NULL) {
            continue;
        }
        
        subname++;
        if (strcmp(subname, executableName) == 0) {
            index = i;
            break;
        }
    }
    
    const headerType *mhdr = (headerType *)_dyld_get_image_header(index);
    
    Method stubMethod = class_getClassMethod(self, @selector(stubLoad));
    IMP stubIMP = method_getImplementation(stubMethod);
    
    auto processCatlist = [&](category_t * const *catlist) {
        for (int i = 0; i < count; i++) {
            category_t *cat = catlist[i];
            method_list_t *classMethods = cat->classMethods;
            
            if (classMethods == NULL) {
                continue;
            }
            
            auto it = classMethods->begin();
            while (it != classMethods->end()) {
                if(strcmp(sel_getName(it->name), "load") == 0 && strcmp(cat->name, "Test") == 0) {
                    add_class_to_loadable_list((__bridge Class)cat->cls, (load_method_t)it->imp);
                    method_setImplementation((Method)it.element, stubIMP);
                }
                it++;
            }
        }
    };
    
    processCatlist(_getObjc2CategoryList(mhdr, &count));
    processCatlist(_getObjc2CategoryList2(mhdr, &count));
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self call];
    });
}

+ (void)stubLoad {
    NSLog(@"STUB CALLED");
}

@end
