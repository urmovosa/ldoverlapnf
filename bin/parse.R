#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
library(data.table)
library(arrow)
library(stringr)

input_file <- args[1]

pheno <- str_replace(args[1], "\\.parquet.snappy", "")
pheno <- str_replace(pheno, ".*_", "")

output_file <- paste0(pheno, "_processed.txt")

# Read the input parquet file
sumstats <- read_parquet(input_file)
message("Input read!")
# Convert to a data.table and calculate P from LOG10P
sumstats <- data.table(SNP = sumstats$ID, P = 10^-sumstats$LOG10P)

# Write the processed data to a text file
fwrite(sumstats, output_file, sep = "\t")
message("Output written!")