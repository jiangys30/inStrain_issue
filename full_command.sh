species=$1
outdir="../instrain_result/${species}"
mkdir -p ${outdir}
:<<!
parse_stb.py --reverse -f ${outdir}/reference_database/*.fna.gz -o ${outdir}/reference_database.stb

mkdir -p ${outdir}/reference_genes

while read genome fasta
do
        prodigal -i $fasta -o ${outdir}/reference_genes/$genome.genes -a ${outdir}/reference_genes/$genome.gene.faa -d ${outdir}/reference_genes/$genome.gene.fna -m -p single
done < ${outdir}/reference_database_list.txt

cat ${outdir}/reference_genes/*.gene.fna > ${outdir}/reference_genes.fna
cat ${outdir}/reference_genes/*.gene.faa > ${outdir}/reference_genes.faa

zcat ${outdir}/reference_database/*.fna.gz > ${outdir}/reference_database.fasta

mkdir -p ${outdir}/bt2
bowtie2-build ${outdir}/reference_database.fasta ${outdir}/bt2/reference_database.fasta.bt2 --large-index --threads 20
!
mkdir -p ${outdir}/bowtie2_result
while read sample f1 f2
do
bowtie2 -p 20 -x ${outdir}/bt2/reference_database.fasta.bt2 -1 ${f1} -2 ${f2} > ${outdir}/bowtie2_result/${sample}.sam
inStrain profile ${outdir}/bowtie2_result/${sample}.sam ${outdir}/reference_database.fasta -o ${outdir}/${sample}.IS -p 20 -g ${outdir}/reference_genes.fna -s ${outdir}/reference_database.stb --database_mode
done < sample_list.txt
