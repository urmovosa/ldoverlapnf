#!/bin/bash

#SBATCH -J ldoverlap-nextflow
#SBATCH -t 1:00:00
#SBATCH --mem=6G
#SBATCH --cpus-per-task=1

inputDir=[Input path to the folder with all GWAS summary statistics in SAMPO .parquet format]
outputDir=[Path to output folder]
RefDir=[Path to genotype reference in .bed/.bim/.fam]
snplist=[File with SNP ID list used in the original GWAS]

gwascat=[GWAS Catalogue file]
opentargets=[Folder with all Open Targets v2d parquet files]

module load nextflow/23.09.3-edge
module load singularity/3.8.5
module load squashfs/4.4

NXF_VER=23.09.3-edge nextflow run main.nf  \
--inputDir ${inputDir} \
--outputDir ${outputDir} \
--ref ${RefDir} \
--extract ${snplist} \
--gwascat ${gwascat} \
--opentargets ${opentargets} \
-profile singularity,local_vm \
-resume 
