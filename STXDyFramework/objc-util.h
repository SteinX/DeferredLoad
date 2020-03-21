//
//  Test.h
//  STXDyFramework
//
//  Created by Yiming XIA on 2020/3/21.
//  Copyright © 2020 steinx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "objc-define.h"

#ifndef OBJC_UTIL_h
#define OBJC_UTIL_h

category_t * const *_getObjc2CategoryList(const headerType *hi, size_t *count);
category_t * const *_getObjc2CategoryList2(const headerType *hi, size_t *count);

int nb_loadable_item();
struct loadable_class * const get_loadable_list();
void add_class_to_loadable_list(Class cls, load_method_t load_method);
void free_loadable_list();

#endif
