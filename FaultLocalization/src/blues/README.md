## Blues

This directory contains executable version of Blues to replicate published results.
The open-source version of Blues is available at https://github.com/LASER-UMASS/Blues.  

To execute Blues do the following:
1. Unzip file `indri-5.3/obj/libindri.zip` using cmd: `unzip indri-5.3/obj/libindri.zip -d indri-5.3/obj/`.
2. Replace `<path-to-blues>` with the absolute path to the current directory in the following files:
        
- `blues.settings`
        
- `indri-5.3/site-search/crawl-index`
        
- `indri-5.3/site-search/build.param`
        
- `indri-5.3/config.status`

3. To execute on single defects4j defect, run cmd: `java -jar Blues.jar Chart_1` (to execue on Chart 1 defect)
4. To compute results for all 815 defects, run cmd: `java -jar Blues.jar all`. 
5. The results are stored in the six sub-folders created under `blues_configuration_results` directory. 
Five corresponding to `m` = {1, 25, 50, 100, All} and `ScoreFn=high` and one corresponding to `m=all`, `ScoreFn=wted`)

NOTE: The precomputed results of six Blues configurations for all 815 defects in Defects4J V2.0 are stored 
in [`SBIR-ReplicationPackage/FaultLocalization/data/blues_configuration_results`](https://github.com/manishmotwani3/SBIR-ReplicationPackage/tree/main/FaultLocalization/data/blues_configuration_results) directory.

6. To combine the six Blues configuration results into Blues ensemble use the following cmd:
 `python combineBluesUsingMaxScoreConsensus.py ../../data/815defects.txt <path-to-blues_configuration_results> <path-to-blues_results>`
 
NOTE: The precomputed results of Blues ensemble for all 815 defects in Defects4J V2.0 are stored 
in [`SBIR-ReplicationPackage/FaultLocalization/data/blues_results`](https://github.com/manishmotwani3/SBIR-ReplicationPackage/tree/main/FaultLocalization/data/blues_results) directory.
