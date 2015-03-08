/*
 * Copyright (c) 1994, 2014, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.  Oracle designates this
 * particular file as subject to the "Classpath" exception as provided
 * by Oracle in the LICENSE file that accompanied this code.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 *
 * You should have received a copy of the GNU General Public License version
 * 2 along with this work; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA.
 *
 * Please contact Oracle, 500 Oracle Parkway, Redwood Shores, CA 94065 USA
 * or visit www.oracle.com if you need additional information or have any
 * questions.
 */

/*-
 *      Implementation of class Class
 *
 *      former threadruntime.c, Sun Sep 22 12:09:39 1991
 */

#include <string.h>
#include <stdlib.h>

#include "jni.h"
#include "jni_util.h"
#include "jvm.h"
#include "java_lang_Class.h"

/* defined in libverify.so/verify.dll (src file common/check_format.c) */
extern jboolean VerifyClassname(char *utf_name, jboolean arrayAllowed);
extern jboolean VerifyFixClassname(char *utf_name);

//mymod
// #define OBJ "Ljava/lang/Object;"
// #define CLS "Ljava/lang/Class;"
// #define CPL "Lsun/reflect/ConstantPool;"
// #define STR "Ljava/lang/String;"
// #define FLD "Ljava/lang/reflect/Field;"
// #define MHD "Ljava/lang/reflect/Method;"
// #define CTR "Ljava/lang/reflect/Constructor;"
// #define PD  "Ljava/security/ProtectionDomain;"
// #define BA  "[B"

// static JNINativeMethod methods[] = {
//     {"getName0",         "()" STR,          (void *)&JVM_GetClassName},
//     {"getSuperclass",    "()" CLS,          NULL},
//     {"getInterfaces0",   "()[" CLS,         (void *)&JVM_GetClassInterfaces},
//     {"isInterface",      "()Z",             (void *)&JVM_IsInterface},
//     {"getSigners",       "()[" OBJ,         (void *)&JVM_GetClassSigners},
//     {"setSigners",       "([" OBJ ")V",     (void *)&JVM_SetClassSigners},
//     {"isArray",          "()Z",             (void *)&JVM_IsArrayClass},
//     {"isPrimitive",      "()Z",             (void *)&JVM_IsPrimitiveClass},
//     {"getModifiers",     "()I",             (void *)&JVM_GetClassModifiers},
//     {"getDeclaredFields0","(Z)[" FLD,       (void *)&JVM_GetClassDeclaredFields},
//     {"getDeclaredMethods0","(Z)[" MHD,      (void *)&JVM_GetClassDeclaredMethods},
//     {"getDeclaredConstructors0","(Z)[" CTR, (void *)&JVM_GetClassDeclaredConstructors},
//     {"getProtectionDomain0", "()" PD,       (void *)&JVM_GetProtectionDomain},
//     {"getDeclaredClasses0",  "()[" CLS,      (void *)&JVM_GetDeclaredClasses},
//     {"getDeclaringClass0",   "()" CLS,      (void *)&JVM_GetDeclaringClass},
//     {"getGenericSignature0", "()" STR,      (void *)&JVM_GetClassSignature},
//     {"getRawAnnotations",      "()" BA,        (void *)&JVM_GetClassAnnotations},
//     {"getConstantPool",     "()" CPL,       (void *)&JVM_GetClassConstantPool},
//     {"desiredAssertionStatus0","("CLS")Z",(void *)&JVM_DesiredAssertionStatus},
//     {"getEnclosingMethod0", "()[" OBJ,      (void *)&JVM_GetEnclosingMethodInfo},
//     {"getRawTypeAnnotations", "()" BA,      (void *)&JVM_GetClassTypeAnnotations},
// };

// #undef OBJ
// #undef CLS
// #undef STR
// #undef FLD
// #undef MHD
// #undef CTR
// #undef PD

JNIEXPORT void JNICALL
Java_java_lang_Class_registerNatives(JNIEnv *env, jclass cls)
{
    // methods[1].fnPtr = (void *)(*env)->GetSuperclass;
    // (*env)->RegisterNatives(env, cls, methods,
    //                         sizeof(methods)/sizeof(JNINativeMethod));
}

//mymod: jdk8 backport.
void* JNICALL JVM_GetComponentType(void*, void*);
JNIEXPORT jclass JNICALL Java_java_lang_Class_getComponentType
  (JNIEnv *e, jobject o)
{
    return JVM_GetComponentType(e, o);
}
///mymod

JNIEXPORT jbyteArray JNICALL Java_java_lang_Class_getRawTypeAnnotations
  (JNIEnv *e, jobject o)
{
    return JVM_GetClassTypeAnnotations(e, o);
}

JNIEXPORT jobjectArray JNICALL Java_java_lang_Class_getEnclosingMethod0
  (JNIEnv *e, jobject o)
{
    return JVM_GetEnclosingMethodInfo(e, o);
}

JNIEXPORT jboolean JNICALL Java_java_lang_Class_desiredAssertionStatus0
  (JNIEnv *e, jclass o, jclass a1)
{
    return JVM_DesiredAssertionStatus(e, o, a1);
}

JNIEXPORT jobject JNICALL Java_java_lang_Class_getConstantPool
  (JNIEnv *e, jobject o)
{
    return JVM_GetClassConstantPool(e, o);
}

JNIEXPORT jbyteArray JNICALL Java_java_lang_Class_getRawAnnotations
  (JNIEnv *e, jobject o)
{
    return JVM_GetClassAnnotations(e, o);
}

JNIEXPORT jstring JNICALL Java_java_lang_Class_getGenericSignature0
  (JNIEnv *e, jobject o)
{
    return JVM_GetClassSignature(e, o);
}

JNIEXPORT jclass JNICALL Java_java_lang_Class_getDeclaringClass0
  (JNIEnv *e, jobject o)
{
    return JVM_GetDeclaringClass(e, o);
}

JNIEXPORT jobjectArray JNICALL Java_java_lang_Class_getDeclaredClasses0
  (JNIEnv *e, jobject o)
{
    return JVM_GetDeclaredClasses(e, o);
}

JNIEXPORT jobject JNICALL Java_java_lang_Class_getProtectionDomain0
  (JNIEnv *e, jobject o)
{
    return JVM_GetProtectionDomain(e, o);
}

JNIEXPORT jobjectArray JNICALL Java_java_lang_Class_getDeclaredConstructors0
  (JNIEnv *e, jobject o, jboolean a1)
{
    return JVM_GetClassDeclaredConstructors(e, o, a1);
}

JNIEXPORT jobjectArray JNICALL Java_java_lang_Class_getDeclaredMethods0
  (JNIEnv *e, jobject o, jboolean a1)
{
    return JVM_GetClassDeclaredMethods(e, o, a1);
}

JNIEXPORT jobjectArray JNICALL Java_java_lang_Class_getDeclaredFields0
  (JNIEnv *e, jobject o, jboolean a1)
{
    return JVM_GetClassDeclaredFields(e, o, a1);
}

JNIEXPORT jint JNICALL Java_java_lang_Class_getModifiers
  (JNIEnv *e, jobject o)
{
    return JVM_GetClassModifiers(e, o);
}

JNIEXPORT jboolean JNICALL Java_java_lang_Class_isPrimitive
  (JNIEnv *e, jobject o)
{
    return JVM_IsPrimitiveClass(e, o);
}

JNIEXPORT jboolean JNICALL Java_java_lang_Class_isArray
  (JNIEnv *e, jobject o)
{
    return JVM_IsArrayClass(e, o);
}

JNIEXPORT void JNICALL Java_java_lang_Class_setSigners
  (JNIEnv *e, jobject o, jobjectArray a1)
{
    JVM_SetClassSigners(e, o, a1);
}

JNIEXPORT jobjectArray JNICALL Java_java_lang_Class_getSigners
  (JNIEnv * e, jobject o)
{
    return JVM_GetClassSigners(e, o);
}

JNIEXPORT jboolean JNICALL Java_java_lang_Class_isInterface
  (JNIEnv * e, jobject o)
{
    return JVM_IsInterface(e, o);
}

JNIEXPORT jobjectArray JNICALL Java_java_lang_Class_getInterfaces0
  (JNIEnv * e, jobject o)
{
    return JVM_GetClassInterfaces(e, o);
}

JNIEXPORT jclass JNICALL Java_java_lang_Class_getSuperclass
  (JNIEnv *e, jobject o)
{
    return (*e)->GetSuperclass(e, o);
}

JNIEXPORT jstring JNICALL Java_java_lang_Class_getName0
  (JNIEnv *e, jobject o)
{
    return JVM_GetClassName(e, o);
}
///mymod

JNIEXPORT jclass JNICALL
Java_java_lang_Class_forName0(JNIEnv *env, jclass this, jstring classname,
                              jboolean initialize, jobject loader, jclass caller)
{
    char *clname;
    jclass cls = 0;
    char buf[128];
    jsize len;
    jsize unicode_len;

    if (classname == NULL) {
        JNU_ThrowNullPointerException(env, 0);
        return 0;
    }

    len = (*env)->GetStringUTFLength(env, classname);
    unicode_len = (*env)->GetStringLength(env, classname);
    if (len >= (jsize)sizeof(buf)) {
        clname = malloc(len + 1);
        if (clname == NULL) {
            JNU_ThrowOutOfMemoryError(env, NULL);
            return NULL;
        }
    } else {
        clname = buf;
    }
    (*env)->GetStringUTFRegion(env, classname, 0, unicode_len, clname);

    if (VerifyFixClassname(clname) == JNI_TRUE) {
        /* slashes present in clname, use name b4 translation for exception */
        (*env)->GetStringUTFRegion(env, classname, 0, unicode_len, clname);
        JNU_ThrowClassNotFoundException(env, clname);
        goto done;
    }

    if (!VerifyClassname(clname, JNI_TRUE)) {  /* expects slashed name */
        JNU_ThrowClassNotFoundException(env, clname);
        goto done;
    }

    cls = JVM_FindClassFromCaller(env, clname, initialize, loader, caller);

 done:
    if (clname != buf) {
        free(clname);
    }
    return cls;
}

JNIEXPORT jboolean JNICALL
Java_java_lang_Class_isInstance(JNIEnv *env, jobject cls, jobject obj)
{
    if (obj == NULL) {
        return JNI_FALSE;
    }
    return (*env)->IsInstanceOf(env, obj, (jclass)cls);
}

JNIEXPORT jboolean JNICALL
Java_java_lang_Class_isAssignableFrom(JNIEnv *env, jobject cls, jobject cls2)
{
    if (cls2 == NULL) {
        JNU_ThrowNullPointerException(env, 0);
        return JNI_FALSE;
    }
    return (*env)->IsAssignableFrom(env, cls2, cls);
}

JNIEXPORT jclass JNICALL
Java_java_lang_Class_getPrimitiveClass(JNIEnv *env,
                                       jclass cls,
                                       jstring name)
{
    const char *utfName;
    jclass result;

    if (name == NULL) {
        JNU_ThrowNullPointerException(env, 0);
        return NULL;
    }

    utfName = (*env)->GetStringUTFChars(env, name, 0);
    if (utfName == 0)
        return NULL;

    result = JVM_FindPrimitiveClass(env, utfName);

    (*env)->ReleaseStringUTFChars(env, name, utfName);

    return result;
}
