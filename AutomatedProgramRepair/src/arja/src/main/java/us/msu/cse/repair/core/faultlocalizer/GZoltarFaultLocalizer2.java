package us.msu.cse.repair.core.faultlocalizer;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.io.FileUtils;

import us.msu.cse.repair.core.parser.LCNode;

public class GZoltarFaultLocalizer2 implements IFaultLocalizer {
	Set<String> positiveTestMethods;
	Set<String> negativeTestMethods;

	Map<LCNode, Double> faultyLines;

	public GZoltarFaultLocalizer2(String gzoltarDataDir, String d4jinfoDir) throws IOException {
		positiveTestMethods = new HashSet<String>();
		negativeTestMethods = new HashSet<String>();
		
	/*	
		File testFile = new File(gzoltarDataDir, "tests");
		List<String> allTestMethods = FileUtils.readLines(testFile, "UTF-8");
		for (int i = 0; i < allTestMethods.size(); i++) {
			String info[] = allTestMethods.get(i).trim().split(",");
			if (info[1].trim().equals("PASS"))
				positiveTestMethods.add(info[0].trim());
			else if (info[1].trim().equals("FAIL"))
				negativeTestMethods.add(info[0].trim());
		}*/

		System.out.println("TEST FILE PATH:" +  d4jinfoDir);
		File failingTestFile = new File(d4jinfoDir, "failed_tests.txt");
		List<String> failingTestMethods = FileUtils.readLines(failingTestFile, "UTF-8");
		for (int i = 0; i < failingTestMethods.size(); i++) {
			String info = failingTestMethods.get(i).trim().replace("::", "#");
				System.out.println("FAILING TEST METHOD:" +  info);
				negativeTestMethods.add(info);
		}
		
		File passingTestFile = new File(d4jinfoDir, "all_tests.txt");
		List<String> passingTestMethods = FileUtils.readLines(passingTestFile, "UTF-8");
		for (int i = 0; i < passingTestMethods.size(); i++) {
			String info = passingTestMethods.get(i).trim();
//			System.out.println("PASSING TEST:" +  info);
			String testmethod = info.split("\\(")[0].trim();
//			System.out.println("PASSING TEST METHOD:" +  testmethod);
			String testclass = info.split("\\(")[1].trim().replace(")", "");
//			System.out.println("PASSING TEST CLASS:" +  testclass);
			String test = testclass + "#" + testmethod;
			//if (!negativeTestMethods.contains(test)){
			//	System.out.println("PASSING TEST ADDING:" +  test);
				positiveTestMethods.add(test);
			//}
		}

		faultyLines = new HashMap<LCNode, Double>();
		/*  
		 * customized by Manish Motwani to input 
		 * precomputed FL results stored in a file
		 * using format: Statement,Suspiciousness.
		 * e.g. org.jfree.chart.plot.XYPlot#5391,0.99625
		 */
		File spectraFile = new File(gzoltarDataDir, "stmt-susps.txt");
		List<String> fLines = FileUtils.readLines(spectraFile, "UTF-8");
		for (int i = 1; i < fLines.size(); i++) {
			String line = fLines.get(i).trim();
//			System.out.println("LINE: " + line);
			String className = line.split("#")[0].trim();
			String[] info = line.split("#")[1].split(",");
			int lineNumber = Integer.parseInt(info[0].trim());
			double suspValue = Double.parseDouble(info[1].trim());
			if (suspValue > 0.0){
				LCNode lcNode = new LCNode(className, lineNumber);
				faultyLines.put(lcNode, suspValue);
				System.out.println("CLASS NAME: " + className);
				System.out.println("LINE NO.: " + lineNumber);
				System.out.println("SUSP VAL.: " + suspValue);
			}
		}
		
//		File spectraFile = new File(gzoltarDataDir, "spectra");
//		List<String> fLines = FileUtils.readLines(spectraFile, "UTF-8");
//		for (int i = 1; i < fLines.size(); i++) {
//			String line = fLines.get(i).trim();
//
//			int startIndex = line.indexOf('<');
//			int endIndex = line.indexOf('{');
//			String className = line.substring(startIndex + 1, endIndex);
//
//			String[] info = line.split("#")[1].split(",");
//			int lineNumber = Integer.parseInt(info[0].trim());
//			double suspValue = Double.parseDouble(info[1].trim());
//
//			LCNode lcNode = new LCNode(className, lineNumber);
//			faultyLines.put(lcNode, suspValue);
//		}
	}

	@Override
	public Map<LCNode, Double> searchSuspicious(double thr) {
		// TODO Auto-generated method stub
		Map<LCNode, Double> partFaultyLines = new HashMap<LCNode, Double>();
		for (Map.Entry<LCNode, Double> entry : faultyLines.entrySet()) {
			if (entry.getValue() >= thr)
				partFaultyLines.put(entry.getKey(), entry.getValue());
		}
		return partFaultyLines;
	}

	@Override
	public Set<String> getPositiveTests() {
		// TODO Auto-generated method stub
		return this.positiveTestMethods;
	}

	@Override
	public Set<String> getNegativeTests() {
		// TODO Auto-generated method stub
		return this.negativeTestMethods;
	}
}
