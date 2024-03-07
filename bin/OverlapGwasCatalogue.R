library(data.table)
library(dplyr)

setDTthreads(8)

args <- commandArgs(trailingOnly = TRUE)

proxies <- fread(args[1])

gwas_cat <- fread(args[2])

proxies$proxy_ID <- paste(proxies$proxy_SNP_chr, proxies$proxy_SNP_bp, sep = "_")
gwas_cat$snp_ID <- paste(gwas_cat$CHR_ID, gwas_cat$CHR_POS, sep = "_")

comb <- merge(proxies, gwas_cat, by.x = "proxy_ID", by.y = "snp_ID", all.x = TRUE)
comb <- comb[, -1, with = FALSE]

comb <- comb[order(comb$pheno), ]

comb_summary <- unique(comb[, c(1, 2, 9:46), with = FALSE])

comb_summary2 <- comb_summary %>%
filter(!is.na(`DISEASE/TRAIT`)) %>%
group_by(lead_SNP) %>%
reframe(pheno = pheno, phenotypes = paste(unique(`DISEASE/TRAIT`), collapse = "; "),
ontologies = paste(unique(`MAPPED_TRAIT`), collapse = "; ")) %>%
unique()

novel_variants <- unique(comb[!comb$lead_SNP %in% comb_summary2$lead_SNP, c(1, 2), with = FALSE])

fwrite(novel_variants, "GWAS_catalogue_overlap_novel.txt", sep = "\t")
fwrite(comb_summary2, "GWAS_catalogue_overlap_summary.txt", sep = "\t")
fwrite(comb, "clumps_proxies_GWAS_catalogue_overlap_detailed.txt", sep = "\t")
