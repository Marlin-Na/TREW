---
output: 
html_document:
css: ./www/Yeti.css
self_contained: no
---

<h1 align = center>
What is TREW database?
</h1>

<div align = center>
<img src="./fig1.png" width = "700" height = "388" alt= "aaa">
</div>

**TREW** is an acronym for the epitranscriptomic **T**arget of **R**eader, **E**raser and **W**riter. It is a project of online service providing the query, visualization, and downloading of the epitranscriptomic target information from high throughput evidences. The TREW database collects 602230 genomic evidences for the genomic locations of epitranscriptomic target sites of 14 regulators on 5 different modifications. 

<section>

<h4 id="top" >Contents:</h4>
<hr/>
<div>1.<a href="#section1">Use the database query function.</a></div>
 - <a href="#section1.1"> <div>Information in the left table</div> </a>
 - <a href="#section1.2"> <div>Information in the right table</div> </a>
 
<div>2.<a href="#section2">Apply specific filters on the query.</a></div>

<div>3.<a href="#section3">Download the complete table returned by the query.</a></div>

<div>4.<a href="#section4">Use the original SQL database.</a></div>

 - <a href="#section4.1"> <div>Table Genome_Location.</div> </a>
 - <a href="#section4.2"> <div>Table Sites_Info.</div> </a>
 - <a href="#section4.3"> <div>Table Source_Info.</div> </a>
 - <a href="#section4.4"> <div>Table Raw_data_records.</div> </a>

<hr/>

<section id="section1">
<h3>
1.Instructions of query function.
</h3>
</section>

<div align = left>
<img src="./fig4.png" width = "563" height = "102" alt= "aaa">
</div>

The database query can be simply used by inputting the **gene symbol from NCBI** into the query bar. A fuzzy match of the gene symbol will be conducted by default. The server will return 2 tables. The first table on the left contains the summary information of the relationship between the queried genes and the epitranscriptomic regulators. Each row in the left table represents the existence of recorded evidence between the gene and regulator. The rows of the left table can be selected, and the selected rows will show their detailed genomic information in the table on the right.

<section id="section1.1">

<br/>

<h4>
The explanation of the column information in the left table.
</h4>
</section>

- `Regulator`: The regulator of the epitranscriptomic target.

- `Target_Gene`: The gene targeted by the regulator.

- `Type`: The regulation type of the regulator, which can be reader, writer, or eraser.

- `Mark`: The type of modification that the regulator acts on.

- `Positive_#`: The number of positive sites recorded in the database. For MeRIP and RNA Bisulfite data, the positive evidence is defined by the significant differential methylated (fisher exact p value < .05) sites between control and perturbation group in the direction of theoretical expectation.  For other data types, all the recorded sites are considered to be positive. Users can apply more rigorous filters(ex. by fdr) on the statistical significance to tackle with the multiple hypothesis test issues.

- `Reliability`: The Positive_# divided by the total number of sites that has the perturbation in the expected direction.

<br/>

<section id="section1.2">
<h4>
The explanation of the column information in the right table.
</h4>
</section>

- `Meth_Site_ID`: The id of the methylation target sites used in the database.

- `Meth_Range_ID`: The id of the ranges used in the database.

P.S. Each target sites could include multiple ranges in the MeRIP data in which the peak is called from exomePeak, and each row in this table represents one genomic range. So, for a given site, it can correspond to multiple rows in the right table. For other data forms, the relashionships between sites and ranges are one-to-one.

For the rest of column information in the right table, please refer to the documentation of <a href="#section4">the SQL database</a>.

<br/>

- **If you need to query the result of all the genes, please input a dot (“.”) in the query bar or just leave it blank. Then click Search.**

<hr/>

<section id="section2">
<h3>
2. Apply specific filters on the query.
</h3>
</section>

<div align = left>
<img src="./fig3.png" width = "535" height = "107" alt= "aaa">
</div>

**12 select bars** can be shown after clicking the `More options` button. Users can define their filters and add restrictions to the returned query results. The following are is the explanations for the contents of each of the select bars. 

- `Marks`: The types of RNA modifications.

- `Regulators`: The roles or names of the regulators.

- `Species`: The species of the sample source.

- `Include liftover`: Whether include the liftOver sites from mm10 to hg19 (default: include).

- `RNA types`: The type of RNA that the target resides.

- `RNA regions`: The local region of the targeted RNA.

- `Cell lines`: The cell line of the source sample.

- `Technique`:  Select 5 categories of the high throughput experiments applied in this database.

- `Statistical significance`: Select the filter used for the statistical significance of the differential methylation in MeRIP and RNA bisulfite samples; by selecting any filter, only positive results will be reported in the tables below.

- `Consistency`: Whether select the sites that are consistent between multiple technical/biological replicates. The definition of consistent is that the methylation fold change direction is consistent between pairs of biological/technical replicate.

For sample with no biological/technical replicate, their reported sites are considered to be inconsistent.

- `Motif restriction`: Whether to choose sites that are only approximate (within 10 nt) to the consensus motif. This argument is only effective for 2 types of methylations: m6A and hmrC, which have reported motifs DRACH and UCUCC.

- `Stop codon restriction` : Whether to choose sites that only approximate (within 10 nt) to the stop codon. 

<hr/>

<section id="section3">
<h3>
3. Download the complete table returned by the query.
</h3>
</section>

<div align = left>
<img src="./fig2.png" width = "536" height = "79" alt= "aaa">
</div>

The information of the returned tables can be downloaded by clicking a download button. The download button is visible under the tables after click the search button. The downloaded table is in csv format.

The downloaded table contains merged information of the left table and the right table. Each row of the downloaded table represents a range on the genome. The scope of the sites contained in the download can be tailored by the select bar filters.

For more download supports, please visit <a id="download.page" href="#" class="action-button">here</a>.

<hr/>

<section id="section4">
<h3>
4. Use the original SQL database.
</h3>
</section>

<div align = center>
<img src="./fig5.png" width = "573" height = "346" alt= "aaa">
</div>

The TREW database is public accessible through **MySQL** and **sqlite** forms. The diagram above demonstrates the structure of the database. The information contained under each field is explained below.

<br/>

<h4 id="section4.1">
<ol style="list-style-type: decimal">
<li>Table Genome_Location.</li>
</ol>
</h4>
<table style="width:94%;" class = "table">
<colgroup>
<col width="30%" />
<col width="63%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Field names</th>
<th align="left">description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><code>Meth_Range_ID</code></td>
<td align="left">The unique ID given each genomic ranges in this database.</td>
</tr>
<tr class="even">
<td align="left"><code>Meth_Site_ID</code></td>
<td align="left">The unique ID given each modification sites.</td>
</tr>
<tr class="odd">
<td align="left"><code>Range_start</code></td>
<td align="left">The start of the range.</td>
</tr>
<tr class="even">
<td align="left"><code>Range_width</code></td>
<td align="left">The width of the range.</td>
</tr>
<tr class="odd">
<td align="left"><code>Strand</code></td>
<td align="left">The strand type of the range.</td>
</tr>
<tr class="even">
<td align="left"><code>Chromosome</code></td>
<td align="left">The chromosome of the range.</td>
</tr>
<tr class="odd">
<td align="left"><code>Note_t1</code></td>
<td align="left">Note for table 1.</td>
</tr>
</tbody>
</table>
<p><br/></p>
<h4 id="section4.2">
<ol start="2" style="list-style-type: decimal">
<li>Table Sites_Info.</li>
</ol>
</h4>
<table style="width:94%;" class = "table">
<colgroup>
<col width="30%" />
<col width="63%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Field names</th>
<th align="left">description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><code>Methylation_ID</code></td>
<td align="left">Reference on the <code>Meth_Site_ID</code> of the first table.</td>
</tr>
<tr class="even">
<td align="left"><code>Diff_p_value</code></td>
<td align="left">The p value returned by the inference of differential methylation in MeRIP and RNA bisulfite samples.</td>
</tr>
<tr class="odd">
<td align="left"><code>Diff_fdr</code>:</td>
<td align="left">The false discovery rate computed based on Benjamini-Hochberg method within each sample.</td>
</tr>
<tr class="even">
<td align="left"><code>Diff_log2FoldChange</code></td>
<td align="left">The log2 transformation of the methylation level fold changes.</td>
</tr>
<tr class="odd">
<td align="left"><code>Gene_ID</code></td>
<td align="left">The NCBI gene symbol for the methylated genes.</td>
</tr>
<tr class="even">
<td align="left"><code>Source_ID</code></td>
<td align="left">The unique ID given by each set of high throughput experiment used in this database.</td>
</tr>
<tr class="odd">
<td align="left"><code>Consistency</code></td>
<td align="left">Whether the fold change directions are consistent between multiple biological/technical replicates.</td>
</tr>
<tr class="even">
<td align="left"><code>Log2_RPKM_wt</code></td>
<td align="left">Expression level (RPKM in input data) for the genes under wt condition.</td>
</tr>
<tr class="odd">
<td align="left"><code>Log2_RPKM_Treated</code></td>
<td align="left">Expression level for the genes under treated condition.</td>
</tr>
<tr class="even">
<td align="left"><code>Overlap_UTR5</code></td>
<td align="left">Whether the site overlapped with 5’UTR (5’untranslated region).</td>
</tr>
<tr class="odd">
<td align="left"><code>Overlap_CDS</code></td>
<td align="left">Whether the site overlapped with CDS (protein coding sequence).</td>
</tr>
<tr class="even">
<td align="left"><code>Overlap_UTR3</code></td>
<td align="left">Whether the site overlapped with 3’UTR (3’untranslated region).</td>
</tr>
<tr class="odd">
<td align="left"><code>Distance_ConsensusMotif</code></td>
<td align="left">The distance from the site to its nearest consensus motif.</td>
</tr>
<tr class="even">
<td align="left"><code>Distance_StartCodon</code></td>
<td align="left">The distance from the site to its nearest start codon.</td>
</tr>
<tr class="odd">
<td align="left"><code>Distance_StopCodon</code></td>
<td align="left">The distance from the site to its nearest stop codon.</td>
</tr>
<tr class="even">
<td align="left"><code>Note_t2</code></td>
<td align="left">Note for table 2.</td>
</tr>
</tbody>
</table>
<p><br/></p>
<h4 id="section4.3">
<ol start="3" style="list-style-type: decimal">
<li>Table Source_Info.</li>
</ol>
</h4>
<table style="width:94%;" class = "table">
<colgroup>
<col width="30%" />
<col width="63%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Field names</th>
<th align="left">description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><code>DataSet_ID</code></td>
<td align="left">Reference on the <code>Source_ID</code> of the second table.</td>
</tr>
<tr class="even">
<td align="left"><code>Genome_assembly</code></td>
<td align="left">The reference genome.</td>
</tr>
<tr class="odd">
<td align="left"><code>Modification</code></td>
<td align="left">The type of modification or marks.</td>
</tr>
<tr class="even">
<td align="left"><code>Technique</code></td>
<td align="left">The high throughput method.</td>
</tr>
<tr class="odd">
<td align="left"><code>Target</code></td>
<td align="left">The protein regulator act on the modification.</td>
</tr>
<tr class="even">
<td align="left"><code>Target_type</code></td>
<td align="left">The type of the protein regulator (either writer, eraser or reader).</td>
</tr>
<tr class="odd">
<td align="left"><code>Perturbation</code></td>
<td align="left">The method of the perturbation of the protein for the treated group.</td>
</tr>
<tr class="even">
<td align="left"><code>Date_of_process</code></td>
<td align="left">The date when the raw data was processed.</td>
</tr>
<tr class="odd">
<td align="left"><code>Paper</code></td>
<td align="left">The publication which generated the sample.</td>
</tr>
<tr class="even">
<td align="left"><code>Cell_line</code></td>
<td align="left">The cell line used by the sample.</td>
</tr>
<tr class="odd">
<td align="left"><code>Treatment</code></td>
<td align="left">The additional treatment exepts protein perturbation.</td>
</tr>
<tr class="even">
<td align="left"><code>Species</code></td>
<td align="left">The species of the sample.</td>
</tr>
<tr class="odd">
<td align="left"><code>LiftOver</code></td>
<td align="left">Indicate the data is liftOver from other species to human.</td>
</tr>
<tr class="even">
<td align="left"><code>Computation_pepline</code></td>
<td align="left">The computational pipeline used to process the raw data.</td>
</tr>
<tr class="odd">
<td align="left"><code>Note_t3</code></td>
<td align="left">Note for table 3.</td>
</tr>
</tbody>
</table>
<h4 id="section4.4">
<ol start="4" style="list-style-type: decimal">
<li>Table Raw_data_records.</li>
</ol>
</h4>
<table style="width:93%;" class = "table">
<colgroup>
<col width="29%" />
<col width="63%" />
</colgroup>
<thead>
<tr class="header">
<th align="left">Field names</th>
<th align="left">description</th>
</tr>
</thead>
<tbody>
<tr class="odd">
<td align="left"><code>GEO_RUN</code></td>
<td align="left">The GEO accession for the individual fastq data.</td>
</tr>
<tr class="even">
<td align="left"><code>Data_ID</code></td>
<td align="left">Reference on the <code>Source_ID</code> of the second table.</td>
</tr>
<tr class="odd">
<td align="left"><code>IP_Input</code></td>
<td align="left">Whether the sample is Input or IP for MeRIP.</td>
</tr>
<tr class="even">
<td align="left"><code>Genotype</code></td>
<td align="left">Whether the sample is control or treated.</td>
</tr>
<tr class="odd">
<td align="left"><code>Replicate</code></td>
<td align="left">How many biological/technical replicates does the sample involve.</td>
</tr>
</tbody>
</table>
<hr/>
<p align="center">
Xi’an Jiaotong-Liverpool University 2016 © Copyright
</p>
