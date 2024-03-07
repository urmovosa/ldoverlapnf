library(data.table)

args <- commandArgs(trailingOnly = TRUE)

res <- fread(args[1])
pheno_name <- args[2]

if (nrow(res) > 0){

res <- data.table(
pheno = pheno_name, 
lead_SNP = res$SNP_A,
lead_SNP_chr = res$CHR_A,
lead_SNP_bp = res$BP_A,
proxy_SNP = res$SNP_B,
proxy_SNP_chr = res$CHR_B,
proxy_SNP_bp = res$BP_B,
R2 = res$R2)

pvalues <- fread(args[3])
res <- merge(res, pvalues, by.x = "lead_SNP", by.y = "SNP")
res <- res[, c(2, 1, 3, 4, 9, 5:8), with = FALSE] 

} else {

res <- data.table(
pheno = NA, 
lead_SNP = NA,
lead_SNP_chr = NA,
lead_SNP_bp = NA,
lead_SNP_P = NA,
proxy_SNP = NA,
proxy_SNP_chr = NA,
proxy_SNP_bp = NA,
R2 = NA)[-1, ]

}

fwrite(res, paste0(pheno_name, ".proxies"), sep = "\t")
