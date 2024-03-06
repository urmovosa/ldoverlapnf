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

} else {

res <- data.table(
pheno = NA, 
lead_SNP = NA,
lead_SNP_chr = NA,
lead_SNP_bp = NA,
proxy_SNP = NA,
proxy_SNP_chr = NA,
proxy_SNP_bp = NA,
R2 = NA)[-1, ]

}

fwrite(res, paste0(pheno_name, ".proxies"), sep = "\t")
