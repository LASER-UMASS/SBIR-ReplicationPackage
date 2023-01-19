# SBIR-Replication Package Artifact (ICSE 2023)

This repository contains the source code, data, and results described in the paper titled: 

**Better Automatic Program Repair by Using Bug Reports and Tests Together**, in Proceedings of the 45th International Conference on Software Engineering (ICSE), 2023
by Manish Motwani and Yuriy Brun.

This artifact facilitates the use of:
- [**Blues**](https://github.com/LASER-UMASS/Blues),  a novel unsupervised information-Retrieval-based fault localization technique that uses bug reports to rank suspicious program statements.
- [**RAFL**](https://github.com/LASER-UMASS/RAFL), a novel unsupervised Rank Aggregation-based fault localization technique to combine results of multiple fault localization techniques.

## What is included in this artifact?

Our artifact includes the following:

1. Blues: the first information-retrieval-based, statement-level FL technique
	that requires no training data.
2. RAFL: the first unsupervised method for combining multiple FL techniques.
3. SBFL: the implementation of spectrum-based FL technique using GZoltar~v1.7.2 
	and Ochiai ranking strategy. 
4. SBIR: Using RAFL to combine Blues and SBFL using the cross-entropy monte carlo 
	algorithm and the Spearman footrule distance. 
5. Evaluation of SBFL, Blues, and SBIR on 815 defects from Defects4J~v2.0.
6. Comparison of Blues with the state-of-the-art and baseline.
7. Comparison of SBIR with the underlying SBFL and Blues, and with the state-of-the-art. 
8. Scripts to run three existing program repair tools (Arja, SequenceR, and SimFix) customized 
to use precomputed FL results obtained from different FL~techniques (SBFL, Blues,
	SBIR, and perfect FL) to repair Defects4J defects. 
9. Script to generate held-out evaluation test suites usin EvoSuite, which we use 
	to assess the correctness of patches produced by the repair tools. 
10. The held-out test evaluation suites generated using 10 seeds for all the defects 
	in Defects4J that are patched using any of the three repair tools. 
11. Script to evaluate the quality of the produced patches using held-out test suites.  
12. Manual correctness analysis of the patches produced by the three repair tools
that passed all the tests in the held-out evaluation test suites.
13. Correct patches produced by the three repair tools by using different FL~techniques
	when attempted to repair 689 (129 for SequenceR) defects in Defects4J.
  
## Where can I obtain the artifact components?

All the above listed artifacts, with the exception of the virtual machine file, are located in this repository.

Artifacts 1-7 in the list above are availble under [FaultLocalization](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/tree/main/FaultLocalization) directory.
Artifacts 8-13 in the list above are availble under [AutomatedProgramRepair](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/tree/main/AutomatedProgramRepair) directory.

## How do I execute artifacts and replicate results?

Please follow the instructions described in [artifact_documentation](https://github.com/LASER-UMASS/SBIR-ReplicationPackage/tree/main/artifact_documentation).
