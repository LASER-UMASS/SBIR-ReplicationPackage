# The purpose of this script is to compare the quality of 3 repair tools (Arja, SequenceR, and SimFix)
# by comparing the correct patches produced by them using different FL techniques, and to
# analyze and compare the effect of fault localization error on the repair quality. 
# This script uses the patches produced by the repair tools stored in $patches_dir directory.
# cmd to run: bash compareAPRquality.sh

#!/bin/bash

patches_dir=$1

# compute results for Arja

arja_sbfl=$(ls $patches_dir/arja/correct_patches/sbfl/ | wc -l)
arja_blues=$(ls $patches_dir/arja/correct_patches/blues/ | wc -l)
ls $patches_dir/arja/correct_patches/sbfl/ | cut -d '_' -f 1,2 > tmp
ls $patches_dir/arja/correct_patches/blues/ | cut -d '_' -f 1,2 >> tmp
arja_union=$(cat tmp | sort | uniq | wc -l)
rm tmp
arja_sbir=$(ls $patches_dir/arja/correct_patches/sbir/ | wc -l)
arja_pf=$(ls $patches_dir/arja/correct_patches/perfectFL/ | wc -l)
ls $patches_dir/arja/correct_patches/sbfl/ | cut -d '_' -f 1,2 > tmp
ls $patches_dir/arja/correct_patches/blues/ | cut -d '_' -f 1,2 >> tmp
ls $patches_dir/arja/correct_patches/sbir/ | cut -d '_' -f 1,2 >> tmp
ls $patches_dir/arja/correct_patches/perfectFL/ | cut -d '_' -f 1,2 >> tmp
arja_ub=$(cat tmp | sort | uniq | wc -l)
#rm tmp
arja_sbfl_le=$((arja_ub - arja_sbfl))
arja_blues_le=$((arja_ub - arja_blues))
arja_sbir_le=$((arja_ub - arja_sbir))
exit 
# compute results for SequenceR

seqr_sbfl=$(ls $patches_dir/sequencer/correct_patches/sbfl/ | wc -l)
seqr_blues=$(ls $patches_dir/sequencer/correct_patches/blues/ | wc -l)
ls $patches_dir/sequencer/correct_patches/sbfl/ | cut -d '_' -f 1,2 > tmp
ls $patches_dir/sequencer/correct_patches/blues/ | cut -d '_' -f 1,2 >> tmp
seqr_union=$(cat tmp | sort | uniq | wc -l)
rm tmp
seqr_sbir=$(ls $patches_dir/sequencer/correct_patches/sbir/ | wc -l)
seqr_pf=$(ls $patches_dir/sequencer/correct_patches/perfectFL/ | wc -l)
ls $patches_dir/sequencer/correct_patches/sbfl/ | cut -d '_' -f 1,2 > tmp
ls $patches_dir/sequencer/correct_patches/blues/ | cut -d '_' -f 1,2 >> tmp
ls $patches_dir/sequencer/correct_patches/sbir/ | cut -d '_' -f 1,2 >> tmp
ls $patches_dir/sequencer/correct_patches/perfectFL/ | cut -d '_' -f 1,2 >> tmp
seqr_ub=$(cat tmp | sort | uniq | wc -l)
rm tmp
seqr_sbfl_le=$((seqr_ub - seqr_sbfl))
seqr_blues_le=$((seqr_ub - seqr_blues))
seqr_sbir_le=$((seqr_ub - seqr_sbir))


# compute results for SimFix

simfix_sbfl=$(ls $patches_dir/simfix/correct_patches/sbfl/ | wc -l)
simfix_blues=$(ls $patches_dir/simfix/correct_patches/blues/ | wc -l)
ls $patches_dir/simfix/correct_patches/sbfl/ | cut -d '_' -f 1,2 > tmp
ls $patches_dir/simfix/correct_patches/blues/ | cut -d '_' -f 1,2 >> tmp
simfix_union=$(cat tmp | sort | uniq | wc -l)
rm tmp
simfix_sbir=$(ls $patches_dir/simfix/correct_patches/sbir/ | wc -l)
simfix_pf=$(ls $patches_dir/simfix/correct_patches/perfectFL/ | wc -l)
ls $patches_dir/simfix/correct_patches/sbfl/ | cut -d '_' -f 1,2 > tmp
ls $patches_dir/simfix/correct_patches/blues/ | cut -d '_' -f 1,2 >> tmp
ls $patches_dir/simfix/correct_patches/sbir/ | cut -d '_' -f 1,2 >> tmp
ls $patches_dir/simfix/correct_patches/perfectFL/ | cut -d '_' -f 1,2 >> tmp
simfix_ub=$(cat tmp | sort | uniq | wc -l)
rm tmp
simfix_sbfl_le=$((simfix_ub - simfix_sbfl))
simfix_blues_le=$((simfix_ub - simfix_blues))
simfix_sbir_le=$((simfix_ub - simfix_sbir))

# print all the results

printf "             \t\t Arja \t   SequenceR \t SimFix \n"
printf "             \t   (689 defects) (129 defects) (689 defects) \n"
printf "                         repair quality assessment              \n"
printf "SBFL         \t\t $arja_sbfl \t    $seqr_sbfl \t\t  $simfix_sbfl \n"
printf "Blues        \t\t $arja_blues \t    $seqr_blues \t\t  $simfix_blues \n"
printf "SBFL U Blues \t\t $arja_union \t    $seqr_union \t\t  $simfix_union \n"
printf "SBIR         \t\t $arja_sbir \t    $seqr_sbir \t\t  $simfix_sbir \n"
printf "                        localization error assessment              \n"
printf "perfect FL   \t\t $arja_pf \t    $seqr_pf \t\t  $simfix_pf \n"
printf "upper bound  \t\t $arja_ub \t    $seqr_ub \t\t  $simfix_ub \n"
printf "       # of defects not correctly patched due to localization error   \n"
printf "SBFL         \t\t $arja_sbfl_le \t    $seqr_sbfl_le \t\t  $simfix_sbfl_le \n" 
printf "Blues        \t\t $arja_blues_le \t    $seqr_blues_le \t\t  $simfix_blues_le \n"
printf "SBIR         \t\t $arja_sbir_le \t    $seqr_sbir_le \t\t  $simfix_sbir_le \n"


