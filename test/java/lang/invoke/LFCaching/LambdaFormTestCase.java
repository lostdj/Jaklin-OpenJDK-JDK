/*
 * Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
 * DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS FILE HEADER.
 *
 * This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.
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

import com.oracle.testlibrary.jsr292.Helper;
import com.sun.management.HotSpotDiagnosticMXBean;
import java.lang.management.ManagementFactory;
import java.lang.reflect.Method;
import java.util.Collection;
import java.util.function.Function;

/**
 * Lambda forms caching test case class. Contains all necessary test routines to
 * test lambda forms caching in method handles returned by methods of
 * MethodHandles class.
 *
 * @author kshefov
 */
public abstract class LambdaFormTestCase {

    private final static String METHOD_HANDLE_CLASS_NAME = "java.lang.invoke.MethodHandle";
    private final static String INTERNAL_FORM_METHOD_NAME = "internalForm";
    private static final double ITERATIONS_TO_CODE_CACHE_SIZE_RATIO
            = 45 / (128.0 * 1024 * 1024);

    /**
     * Reflection link to {@code j.l.i.MethodHandle.internalForm} method. It is
     * used to get a lambda form from a method handle.
     */
    protected final static Method INTERNAL_FORM;

    static {
        try {
            Class mhClass = Class.forName(METHOD_HANDLE_CLASS_NAME);
            INTERNAL_FORM = mhClass.getDeclaredMethod(INTERNAL_FORM_METHOD_NAME);
            INTERNAL_FORM.setAccessible(true);
        } catch (Exception ex) {
            throw new Error("Unexpected exception: ", ex);
        }
    }

    private final TestMethods testMethod;

    /**
     * Test case constructor. Generates test cases with random method types for
     * given methods form {@code j.l.i.MethodHandles} class.
     *
     * @param testMethod A method from {@code j.l.i.MethodHandles} class which
     * returns a {@code j.l.i.MethodHandle}.
     */
    protected LambdaFormTestCase(TestMethods testMethod) {
        this.testMethod = testMethod;
    }

    public TestMethods getTestMethod() {
        return testMethod;
    }

    /**
     * Routine that executes a test case.
     */
    public abstract void doTest();

    /**
     * Runs a number of test cases defined by the size of testCases list.
     *
     * @param ctor constructor of LambdaFormCachingTest or its child classes
     * object.
     * @param testMethods list of test methods
     */
    public static void runTests(Function<TestMethods, LambdaFormTestCase> ctor, Collection<TestMethods> testMethods) {
        boolean passed = true;
        int testCounter = 0;
        int failCounter = 0;
        long testCaseNum = testMethods.size();
        long iterations = Math.max(1, Helper.TEST_LIMIT / testCaseNum);
        System.out.printf("Number of iterations according to -DtestLimit is %d (%d cases)%n",
                iterations, iterations * testCaseNum);
        HotSpotDiagnosticMXBean hsDiagBean = ManagementFactory.getPlatformMXBean(HotSpotDiagnosticMXBean.class);
        long codeCacheSize = Long.parseLong(
                hsDiagBean.getVMOption("ReservedCodeCacheSize").getValue());
        System.out.printf("Code cache size is %d bytes%n", codeCacheSize);
        long iterationsByCodeCacheSize = (long) (codeCacheSize
                * ITERATIONS_TO_CODE_CACHE_SIZE_RATIO);
        long nonProfiledCodeCacheSize = Long.parseLong(
                hsDiagBean.getVMOption("NonProfiledCodeHeapSize").getValue());
        System.out.printf("Non-profiled code cache size is %d bytes%n", nonProfiledCodeCacheSize);
        long iterationsByNonProfiledCodeCacheSize = (long) (nonProfiledCodeCacheSize
                * ITERATIONS_TO_CODE_CACHE_SIZE_RATIO);
        System.out.printf("Number of iterations limited by code cache size is %d (%d cases)%n",
                iterationsByCodeCacheSize, iterationsByCodeCacheSize * testCaseNum);
        System.out.printf("Number of iterations limited by non-profiled code cache size is %d (%d cases)%n",
                iterationsByNonProfiledCodeCacheSize, iterationsByNonProfiledCodeCacheSize * testCaseNum);
        iterations = Math.min(iterationsByCodeCacheSize,
                Math.min(iterations, iterationsByNonProfiledCodeCacheSize));
        if (iterations == 0) {
            System.out.println("Warning: code cache size is too small to provide at"
                    + " least one iteration! Test will try to do one iteration.");
            iterations = 1;
        }
        System.out.printf("Number of iterations is set to %d (%d cases)%n",
                iterations, iterations * testCaseNum);
        System.out.flush();
        for (long i = 0; i < iterations; i++) {
            System.err.println(String.format("Iteration %d:", i));
            for (TestMethods testMethod : testMethods) {
                LambdaFormTestCase testCase = ctor.apply(testMethod);
                try {
                    System.err.printf("Tested LF caching feature with MethodHandles.%s method.%n",
                            testCase.getTestMethod().name);
                    testCase.doTest();
                    System.err.println("PASSED");
                } catch (Throwable t) {
                    t.printStackTrace();
                    System.err.println("FAILED");
                    passed = false;
                    failCounter++;
                }
                testCounter++;
            }
        }
        if (!passed) {
            throw new Error(String.format("%d of %d test cases FAILED! %n"
                    + "Rerun the test with the same \"-Dseed=\" option as in the log file!",
                    failCounter, testCounter));
        } else {
            System.err.println(String.format("All %d test cases PASSED!", testCounter));
        }
    }
}
