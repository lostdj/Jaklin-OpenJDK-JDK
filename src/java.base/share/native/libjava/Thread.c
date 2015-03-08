/*
 * Copyright (c) 1994, 2012, Oracle and/or its affiliates. All rights reserved.
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
 *      Stuff for dealing with threads.
 *      originally in threadruntime.c, Sun Sep 22 12:09:39 1991
 */

#include "jni.h"
#include "jvm.h"

#include "java_lang_Thread.h"

#define THD "Ljava/lang/Thread;"
#define OBJ "Ljava/lang/Object;"
#define STE "Ljava/lang/StackTraceElement;"
#define STR "Ljava/lang/String;"

#define ARRAY_LENGTH(a) (sizeof(a)/sizeof(a[0]))

static JNINativeMethod methods[] = {
    {"start0",           "()V",        (void *)&JVM_StartThread},
    {"stop0",            "(" OBJ ")V", (void *)&JVM_StopThread},
    {"isAlive",          "()Z",        (void *)&JVM_IsThreadAlive},
    {"suspend0",         "()V",        (void *)&JVM_SuspendThread},
    {"resume0",          "()V",        (void *)&JVM_ResumeThread},
    {"setPriority0",     "(I)V",       (void *)&JVM_SetThreadPriority},
    {"yield",            "()V",        (void *)&JVM_Yield},
    {"sleep",            "(J)V",       (void *)&JVM_Sleep},
    {"currentThread",    "()" THD,     (void *)&JVM_CurrentThread},
    {"countStackFrames", "()I",        (void *)&JVM_CountStackFrames},
    {"interrupt0",       "()V",        (void *)&JVM_Interrupt},
    {"isInterrupted",    "(Z)Z",       (void *)&JVM_IsInterrupted},
    {"holdsLock",        "(" OBJ ")Z", (void *)&JVM_HoldsLock},
    {"getThreads",        "()[" THD,   (void *)&JVM_GetAllThreads},
    {"dumpThreads",      "([" THD ")[[" STE, (void *)&JVM_DumpThreads},
    {"setNativeName",    "(" STR ")V", (void *)&JVM_SetNativeThreadName},
};

#undef THD
#undef OBJ
#undef STE
#undef STR

//mymod
JNIEXPORT void JNICALL
Java_java_lang_Thread_registerNatives(JNIEnv *env, jclass cls)
{
    // (*env)->RegisterNatives(env, cls, methods, ARRAY_LENGTH(methods));
}

JNIEXPORT void JNICALL Java_java_lang_Thread_setNativeName
  (JNIEnv *e, jobject o, jstring a1)
{
    JVM_SetNativeThreadName(e, o, a1);
}

JNIEXPORT jobjectArray JNICALL Java_java_lang_Thread_dumpThreads
  (JNIEnv *e, jclass o, jobjectArray a1)
{
    return JVM_DumpThreads(e, o, a1);
}

JNIEXPORT jobjectArray JNICALL Java_java_lang_Thread_getThreads
  (JNIEnv *e, jclass o)
{
    return JVM_GetAllThreads(e, o);
}

JNIEXPORT jboolean JNICALL Java_java_lang_Thread_holdsLock
  (JNIEnv *e, jclass o, jobject a1)
{
    return JVM_HoldsLock(e, o, a1);
}

JNIEXPORT jboolean JNICALL Java_java_lang_Thread_isInterrupted
  (JNIEnv *e, jobject o, jboolean a1)
{
    return JVM_IsInterrupted(e, o, a1);
}

JNIEXPORT void JNICALL Java_java_lang_Thread_interrupt0
  (JNIEnv *e, jobject o)
{
    JVM_Interrupt(e, o);
}

JNIEXPORT jint JNICALL Java_java_lang_Thread_countStackFrames
  (JNIEnv * e, jobject o)
{
    return JVM_CountStackFrames(e, o);
}

JNIEXPORT jobject JNICALL Java_java_lang_Thread_currentThread
  (JNIEnv *e, jclass o)
{
    return JVM_CurrentThread(e, o);
}

JNIEXPORT void JNICALL Java_java_lang_Thread_sleep
  (JNIEnv * e, jclass o, jlong a1)
{
    JVM_Sleep(e, o, a1);
}

JNIEXPORT void JNICALL Java_java_lang_Thread_yield
  (JNIEnv *e, jclass o)
{
    JVM_Yield(e, o);
}

JNIEXPORT void JNICALL Java_java_lang_Thread_start0
  (JNIEnv *e, jobject o)
{
    JVM_StartThread(e, o);
}

JNIEXPORT void JNICALL Java_java_lang_Thread_stop0
  (JNIEnv *e, jobject o, jobject o1)
{
    JVM_StopThread(e, o, o1);
}

JNIEXPORT jboolean JNICALL Java_java_lang_Thread_isAlive
  (JNIEnv *e, jobject o)
{
    return JVM_IsThreadAlive(e, o);
}

JNIEXPORT void JNICALL Java_java_lang_Thread_suspend0
  (JNIEnv *e, jobject o)
{
    JVM_SuspendThread(e, o);
}

JNIEXPORT void JNICALL Java_java_lang_Thread_resume0
  (JNIEnv *e, jobject o)
{
    JVM_ResumeThread(e, o);
}

JNIEXPORT void JNICALL Java_java_lang_Thread_setPriority0
  (JNIEnv * e, jobject o, jint a1)
{
    JVM_SetThreadPriority(e, o, a1);
}

///mymod

