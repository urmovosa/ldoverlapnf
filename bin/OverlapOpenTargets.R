library(arrow)
library(data.table)
library(tidyverse)

setDTthreads(8)

args <- commandArgs(trailingOnly = TRUE)

proxies <- fread(args[1])
proxies$proxy_ID <- paste(proxies$proxy_SNP_chr, proxies$proxy_SNP_bp, sep = "_")

opentargets <- open_dataset(args[2]) %>%
  mutate(snp_ID = paste(lead_chrom, lead_pos, sep = "_")) %>%
  filter(tag_pos == lead_pos) %>%
  filter(snp_ID %in% !!proxies$proxy_ID) %>%
  collect()

# Collapse the elements of 'trait_efos' and 'ancestry_initial' into comma-separated strings
opentargets$trait_efos <- sapply(opentargets$trait_efos, function(x) paste(x, collapse = ", "))
opentargets$ancestry_initial <- sapply(opentargets$ancestry_initial, function(x) paste(x, collapse = ", "))
opentargets$ancestry_replication <- sapply(opentargets$ancestry_replication, function(x) paste(x, collapse = ", "))

comb <- merge(proxies, as.data.table(opentargets), by.x = "proxy_ID", by.y = "snp_ID", all.x = TRUE)
comb <- comb[, -1, with = FALSE]

comb <- comb[order(comb$pheno), ]

comb_summary <- comb[, c(1, 2, 9:ncol(comb)), with = FALSE]

comb_summary2 <- comb_summary %>%
filter(!is.na(trait_efos)) %>%
group_by(lead_SNP) %>%
reframe(pheno = pheno, phenotypes = paste(unique(trait_reported), collapse = "; "),
efos = paste(unique(trait_efos), collapse = "; "),
ontologies = paste(unique(trait_category), collapse = "; ")) %>%
unique()

novel_variants <- unique(comb[!comb$lead_SNP %in% comb_summary2$lead_SNP, c(1, 2), with = FALSE])

#print(apply(comb, 2, class)[1:10])
comb <- comb[, lapply(.SD, as.character)]

fwrite(novel_variants, "OpenTargets_overlap_novel.txt", sep = "\t")
fwrite(comb_summary2, "OpenTargets_overlap_summary.txt", sep = "\t")
fwrite(comb, "clumps_proxies_OpenTargets_overlap_detailed.txt", sep = "\t")
