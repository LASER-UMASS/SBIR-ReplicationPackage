package us.msu.cse.repair.external.junit;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


import org.junit.runner.JUnitCore;
import org.junit.runner.Request;
import org.junit.runner.Result;

import us.msu.cse.repair.external.util.Util;

public class JUnitTestRunner {
	public static void main(String args[]) throws Exception {
		List<String> tests;
		if (args[1].startsWith("@")) {
			String path = args[1].trim().substring(1);
			tests = Util.readLines(new File(path));
		} else {
			String testStrs[] = args[1].trim().split(File.pathSeparator);
			tests = Arrays.asList(testStrs);
		}

		String gzoltarDataDir = args[0].trim();
		runTests(tests, gzoltarDataDir);
		System.exit(0);
	}

	private static void runTests(List<String> tests, String gzoltarDataDir) throws ClassNotFoundException, IOException {
		List<String> failedTests = new ArrayList<String>();
		List<String> passedTests = new ArrayList<String>();
		System.out.println("RUNNING ALL TESTS:"+ tests.toString());
		for (String test : tests) {
			String strs[] = test.split("#");
			String className = strs[0];
			String methodName = strs[1];
			
			Request request = Request.method(Class.forName(className), methodName);
			Result res = new JUnitCore().run(request);
			if (!res.wasSuccessful())
				failedTests.add(test);
			else
				passedTests.add(test);
		}

		printPassedTests(passedTests, gzoltarDataDir);
		printFailedTests(failedTests, gzoltarDataDir);
	}

		
	private static void printFailedTests(List<String> failedTests, String gzoltarDataDir) throws IOException {
		BufferedWriter writer = new BufferedWriter(new FileWriter(gzoltarDataDir + "/failingtests.out"));
		System.out.println("FailureCount: " + failedTests.size());
		writer.write("FailureCount: " + failedTests.size() + "\n");
		for (String test : failedTests) {
			System.out.println("FailedTest: " + test);
			writer.write("FailedTest: " + test + "\n");
		}
		  writer.close();
	}
	
	private static void printPassedTests(List<String> passedTests, String gzoltarDataDir) throws IOException {
		BufferedWriter writer = new BufferedWriter(new FileWriter(gzoltarDataDir + "/passingtests.out"));
		System.out.println("PassCount: " + passedTests.size());
		writer.write("PassCount: " + passedTests.size() + "\n");
		for (String test : passedTests) {
			System.out.println("PassedTest: " + test);
			writer.write("PassedTest: " + test + "\n");
		}
		writer.close();
	}
}
