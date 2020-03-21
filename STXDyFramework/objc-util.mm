//
//  Test.m
//  STXDyFramework
//
//  Created by Yiming XIA on 2020/3/21.
//  Copyright © 2020 steinx. All rights reserved.
//

#import "objc-util.h"
#import <mach-o/getsect.h>

static struct loadable_class *loadable_classes = nil;
static int loadable_classes_used = 0;
static int loadable_classes_allocated = 0;

template <typename T>
T* getDataSection(const headerType *mhdr, const char *sectname,
                  size_t *outBytes, size_t *outCount)
{
    unsigned long byteCount = 0;
    T* data = (T*)getsectiondata(mhdr, "__DATA", sectname, &byteCount);
    if (!data) {
        data = (T*)getsectiondata(mhdr, "__DATA_CONST", sectname, &byteCount);
    }
    if (!data) {
        data = (T*)getsectiondata(mhdr, "__DATA_DIRTY", sectname, &byteCount);
    }
    if (outBytes) *outBytes = byteCount;
    if (outCount) *outCount = byteCount / sizeof(T);
    return data;
}

#define GETSECT(name, type, sectname)                               \
type *name(const headerType *mhdr, size_t *outCount) {              \
    return getDataSection<type>(mhdr, sectname, nil, outCount);     \
}                                                                   \

GETSECT(_getObjc2CategoryList,        category_t * const,    "__objc_catlist");
GETSECT(_getObjc2CategoryList2,       category_t * const,    "__objc_catlist2");


void add_class_to_loadable_list(Class cls, load_method_t load_method)
{
    if (loadable_classes_used == loadable_classes_allocated) {
        loadable_classes_allocated = loadable_classes_allocated*2 + 16;
        loadable_classes = (struct loadable_class *)
            realloc(loadable_classes,
                              loadable_classes_allocated *
                              sizeof(struct loadable_class));
    }
    
    loadable_classes[loadable_classes_used].cls = cls;
    loadable_classes[loadable_classes_used].method = load_method;
    loadable_classes_used++;
}

struct loadable_class * const get_loadable_list() {
    return loadable_classes;
}

int nb_loadable_item() {
    return loadable_classes_used;
}

void free_loadable_list() {
    if (loadable_classes == nil) {
        return;
    }
    
    free(loadable_classes);
}
