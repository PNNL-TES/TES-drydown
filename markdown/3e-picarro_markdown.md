Drydown - Fluxes
================

CO2 concentrations and/or fluxes from the Picarro and EGM-4.

# 1\. PICARRO DATA – CPCRW

### individual cores

![](images/markdown-picarro/cpcrw_co2_flux_cores-1.png)<!-- -->

![](images/markdown-picarro/cpcrw_co2_flux_cores2-1.png)<!-- -->

![](images/markdown-picarro/unnamed-chunk-1-1.png)<!-- -->

### tables – by core

CO2: nmol\_g\_s

### tables – by treatment

CO2: nmol\_g\_s

| drying          | length  |   drydown |   drought |       sat | sat\_incubation |
| :-------------- | :------ | --------: | --------: | --------: | --------------: |
| constant weight | 150 day | 0.0026968 | 0.0019097 | 0.0361922 |       0.0590331 |
| constant weight | 30 day  | 0.0050707 | 0.0005753 | 0.0535740 |       0.0072120 |
| forced          | 30 day  | 0.0017004 | 0.0051971 | 0.0367825 |       0.0468636 |
| constant weight | 90 day  | 0.0034668 | 0.0397379 | 0.0461793 |       0.0283589 |
| forced          | 90 day  | 0.0020630 | 0.0019100 | 0.0180914 |              NA |

### by treatment

![](images/markdown-picarro/cpcrw_co2_flux_trt-1.png)<!-- -->

![](images/markdown-picarro/cpcrw__co2_flux_trt2-1.png)<!-- -->

# 2\. PICARRO DATA – SR

### individual cores

![](images/markdown-picarro/sr_co2_flux_cores-1.png)<!-- -->

![](images/markdown-picarro/sr_co2_flux_cores2-1.png)<!-- -->

### by treatment

![](images/markdown-picarro/sr_co2_flux_trt-1.png)<!-- -->

![](images/markdown-picarro/sr_co2_flux_trt2-1.png)<!-- -->

### tables – by core

CO2: nmol\_g\_s

### tables – by treatment

CO2: nmol\_g\_s

| drying          | length  |   initial |   drydown |   drought |       sat | sat\_incubation |
| :-------------- | :------ | --------: | --------: | --------: | --------: | --------------: |
| constant weight | 150 day | 0.0989391 | 0.0105981 | 0.0021861 |        NA |              NA |
| forced          | 150 day | 0.1461563 | 0.0131859 | 0.0022645 |        NA |              NA |
| constant weight | 30 day  | 0.0220704 | 0.0090548 | 0.0018005 | 0.0013462 |              NA |
| forced          | 30 day  | 0.1477050 | 0.0165348 | 0.0013383 | 0.0296432 |       0.0127297 |
| constant weight | 90 day  | 0.0353427 | 0.0088140 | 0.0012004 | 0.0175935 |              NA |
| forced          | 90 day  | 0.0388691 | 0.0088061 | 0.0171287 | 0.0154657 |              NA |

# 3\. EGM DATA – CO2 concentrations

## ambient CO2

![](images/markdown-picarro/egm_ambient-1.png)<!-- -->

## all cores

![](images/markdown-picarro/egm_cores-1.png)<!-- -->![](images/markdown-picarro/egm_cores-2.png)<!-- -->

-----

<details>

<summary>Session Info</summary>

Date Run: 2020-07-15

    #> R version 4.0.1 (2020-06-06)
    #> Platform: x86_64-apple-darwin17.0 (64-bit)
    #> Running under: macOS Mojave 10.14.6
    #> 
    #> Matrix products: default
    #> BLAS:   /Library/Frameworks/R.framework/Versions/4.0/Resources/lib/libRblas.dylib
    #> LAPACK: /Library/Frameworks/R.framework/Versions/4.0/Resources/lib/libRlapack.dylib
    #> 
    #> locale:
    #> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    #> 
    #> attached base packages:
    #> [1] stats     graphics  grDevices utils     datasets  methods   base     
    #> 
    #> other attached packages:
    #>  [1] picarro.data_0.1.1 drake_7.12.4       dplyr_1.0.0        DescTools_0.99.36 
    #>  [5] multcomp_1.4-13    TH.data_1.0-10     MASS_7.3-51.6      survival_3.2-3    
    #>  [9] mvtnorm_1.1-1      gsheet_0.4.5       googlesheets_0.3.0 agricolae_1.3-3   
    #> [13] car_3.0-8          carData_3.0-4      nlme_3.1-148       stringi_1.4.6     
    #> [17] ggExtra_0.9        ggalt_0.4.0        reshape2_1.4.4     knitr_1.28        
    #> [21] qwraps2_0.4.2      cowplot_1.0.0      data.table_1.12.8  Rmisc_1.5         
    #> [25] plyr_1.8.6         lattice_0.20-41    tidyr_1.1.0        luzlogr_0.2.0     
    #> [29] stringr_1.4.0      lubridate_1.7.9    readr_1.3.1        ggplot2_3.3.2     
    #> [33] readxl_1.3.1      
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] colorspace_1.4-1   ellipsis_0.3.1     rio_0.5.16         rstudioapi_0.11   
    #>  [5] farver_2.0.3       fansi_0.4.1        codetools_0.2-16   splines_4.0.1     
    #>  [9] extrafont_0.17     Rttf2pt1_1.3.8     cluster_2.1.0      shiny_1.5.0       
    #> [13] compiler_4.0.1     backports_1.1.8    assertthat_0.2.1   Matrix_1.2-18     
    #> [17] fastmap_1.0.1      cli_2.0.2          later_1.1.0.1      prettyunits_1.1.1 
    #> [21] htmltools_0.5.0    tools_4.0.1        igraph_1.2.5       gtable_0.3.0      
    #> [25] glue_1.4.1         maps_3.3.0         Rcpp_1.0.4.6       cellranger_1.1.0  
    #> [29] vctrs_0.3.1        extrafontdb_1.0    xfun_0.15          openxlsx_4.1.5    
    #> [33] mime_0.9           miniUI_0.1.1.1     lifecycle_0.2.0    zoo_1.8-8         
    #> [37] scales_1.1.1       hms_0.5.3          promises_1.1.1     parallel_4.0.1    
    #> [41] proj4_1.0-10       sandwich_2.5-1     expm_0.999-4       RColorBrewer_1.1-2
    #> [45] yaml_2.2.1         curl_4.3           labelled_2.5.0     highr_0.8         
    #> [49] klaR_0.6-15        AlgDesign_1.2.0    filelock_1.0.2     boot_1.3-25       
    #> [53] zip_2.0.4          storr_1.2.1        rlang_0.4.6        pkgconfig_2.0.3   
    #> [57] evaluate_0.14      purrr_0.3.4        labeling_0.3       tidyselect_1.1.0  
    #> [61] magrittr_1.5       R6_2.4.1           generics_0.0.2     base64url_1.4     
    #> [65] combinat_0.0-8     txtq_0.2.3         pillar_1.4.4       haven_2.3.1       
    #> [69] foreign_0.8-80     withr_2.2.0        abind_1.4-5        ash_1.0-15        
    #> [73] tibble_3.0.1       crayon_1.3.4       questionr_0.7.1    KernSmooth_2.23-17
    #> [77] rmarkdown_2.3      progress_1.2.2     grid_4.0.1         forcats_0.5.0     
    #> [81] digest_0.6.25      xtable_1.8-4       httpuv_1.5.4       munsell_0.5.0

</details>
