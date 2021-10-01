NMR
================

------------------------------------------------------------------------

<details>
<summary>
Time Zero – click to open
</summary>

## Time Zero

Time Zero soils had mostly aliphatic groups, with &lt; 15 % aromatic

![](images-markdown-nmr/unnamed-chunk-1-1.png)<!-- -->

#### PERMANOVA

| term       |  df | SumsOfSqs |   MeanSqs |   F.Model |        R2 | p.value |
|:-----------|----:|----------:|----------:|----------:|----------:|--------:|
| Site       |   1 | 0.0138914 | 0.0138914 | 1.3125504 | 0.1019612 |   0.252 |
| depth      |   1 | 0.0056740 | 0.0056740 | 0.5361151 | 0.0416464 |   0.795 |
| Site:depth |   1 | 0.0214249 | 0.0214249 | 2.0243682 | 0.1572565 |   0.093 |
| Residuals  |   9 | 0.0952515 | 0.0105835 |        NA | 0.6991359 |      NA |
| Total      |  12 | 0.1362417 |        NA |        NA | 1.0000000 |      NA |

For time-zero samples, NMR-based composition did not differ by Site or
depth.

</details>

------------------------------------------------------------------------

<details>
<summary>
Drought Samples - Statistics
</summary>

In drought-incubated samples, NMR-based composition was significantly
influenced by saturation type, Site, and depth. Drought length or
drought intensity did not significantly influence WEOC composition.

Saturation type (instant chemistry vs. saturated) accounted for 13 % of
total variation (R2 value).

| term              |  df |  SumsOfSqs |   MeanSqs |    F.Model |        R2 | p.value |
|:------------------|----:|-----------:|----------:|-----------:|----------:|--------:|
| Site              |   1 |  0.7513240 | 0.7513240 |  6.5649800 | 0.0603183 |   0.003 |
| depth             |   1 |  0.9071001 | 0.9071001 |  7.9261327 | 0.0728244 |   0.002 |
| length            |   2 |  0.2405387 | 0.1202693 |  1.0508992 | 0.0193111 |   0.369 |
| saturation        |   1 |  1.6615818 | 1.6615818 | 14.5187040 | 0.1333963 |   0.001 |
| drying            |   1 |  0.0130453 | 0.0130453 |  0.1139882 | 0.0010473 |   0.904 |
| Site:depth        |   1 |  0.1581999 | 0.1581999 |  1.3823318 | 0.0127007 |   0.272 |
| Site:length       |   2 |  0.1040810 | 0.0520405 |  0.4547237 | 0.0083559 |   0.781 |
| Site:saturation   |   1 |  0.0941185 | 0.0941185 |  0.8223964 | 0.0075561 |   0.418 |
| Site:drying       |   1 |  0.0725830 | 0.0725830 |  0.6342220 | 0.0058272 |   0.527 |
| depth:length      |   2 |  0.1947432 | 0.0973716 |  0.8508213 | 0.0156345 |   0.491 |
| depth:saturation  |   1 |  0.8961739 | 0.8961739 |  7.8306609 | 0.0719473 |   0.002 |
| depth:drying      |   1 |  0.0285549 | 0.0285549 |  0.2495094 | 0.0022925 |   0.825 |
| length:saturation |   1 |  0.2006398 | 0.2006398 |  1.7531663 | 0.0161079 |   0.188 |
| length:drying     |   2 |  0.0991819 | 0.0495909 |  0.4333197 | 0.0079626 |   0.795 |
| saturation:drying |   1 |  0.0530204 | 0.0530204 |  0.4632863 | 0.0042566 |   0.655 |
| Residuals         |  61 |  6.9810974 | 0.1144442 |         NA | 0.5604613 |      NA |
| Total             |  80 | 12.4559837 |        NA |         NA | 1.0000000 |      NA |

**0-5cm only**

Saturation type (instant chemistry vs. saturated) accounted for 25 % of
total variation (R2 value).

Site (CPCRW vs. SR) accounted for 5 % of total variation (R2 value).

| term              |  df | SumsOfSqs |   MeanSqs |    F.Model |        R2 | p.value |
|:------------------|----:|----------:|----------:|-----------:|----------:|--------:|
| Site              |   1 | 0.4956366 | 0.4956366 |  3.7667171 | 0.0581444 |   0.023 |
| length            |   2 | 0.3460398 | 0.1730199 |  1.3149091 | 0.0405948 |   0.258 |
| saturation        |   1 | 2.1657786 | 2.1657786 | 16.4593898 | 0.2540730 |   0.001 |
| drying            |   1 | 0.0395842 | 0.0395842 |  0.3008303 | 0.0046437 |   0.761 |
| Site:length       |   2 | 0.1347059 | 0.0673530 |  0.5118661 | 0.0158027 |   0.725 |
| Site:saturation   |   1 | 0.0172503 | 0.0172503 |  0.1310982 | 0.0020237 |   0.902 |
| Site:drying       |   1 | 0.0413629 | 0.0413629 |  0.3143478 | 0.0048524 |   0.749 |
| length:saturation |   1 | 0.2069065 | 0.2069065 |  1.5724391 | 0.0242727 |   0.216 |
| length:drying     |   2 | 0.1156152 | 0.0578076 |  0.4393235 | 0.0135631 |   0.775 |
| saturation:drying |   1 | 0.0927792 | 0.0927792 |  0.7050996 | 0.0108842 |   0.491 |
| Residuals         |  37 | 4.8685771 | 0.1315832 |         NA | 0.5711453 |      NA |
| Total             |  50 | 8.5242363 |        NA |         NA | 1.0000000 |      NA |

</details>

------------------------------------------------------------------------

<details>
<summary>
PCA
</summary>

#### Including Time Zero samples

![](images-markdown-nmr/unnamed-chunk-5-1.png)<!-- -->

Time-zero samples had a greater contribution of aliphatic groups.
Instant-rewet samples had a greater contribution of aliphatic, alpha-H
and amide groups. Saturated soils had a greater contribution of aromatic
groups.

#### Only drought samples (no Time Zero)

![](images-markdown-nmr/unnamed-chunk-6-1.png)<!-- -->

</details>

------------------------------------------------------------------------

<details>
<summary>
Relative abundance bar plots
</summary>

![](images-markdown-nmr/unnamed-chunk-7-1.png)<!-- -->

### All samples

![](images-markdown-nmr/unnamed-chunk-8-1.png)<!-- -->

![](images-markdown-nmr/unnamed-chunk-9-1.png)<!-- -->

![](images-markdown-nmr/unnamed-chunk-10-1.png)<!-- -->

</details>

------------------------------------------------------------------------

<details>
<summary>
NMR Spectra
</summary>

    #> $spectra_tzero

![](images-markdown-nmr/unnamed-chunk-11-1.png)<!-- -->

    #> 
    #> $spectra_cpcrw

![](images-markdown-nmr/unnamed-chunk-11-2.png)<!-- -->

    #> 
    #> $spectra_sr

![](images-markdown-nmr/unnamed-chunk-11-3.png)<!-- -->

</details>

------------------------------------------------------------------------

------------------------------------------------------------------------

<details>
<summary>
Session Info
</summary>

date run: 2021-10-01

    #> R version 4.1.1 (2021-08-10)
    #> Platform: x86_64-apple-darwin17.0 (64-bit)
    #> Running under: macOS Catalina 10.15.7
    #> 
    #> Matrix products: default
    #> BLAS:   /System/Library/Frameworks/Accelerate.framework/Versions/A/Frameworks/vecLib.framework/Versions/A/libBLAS.dylib
    #> LAPACK: /Library/Frameworks/R.framework/Versions/4.1/Resources/lib/libRlapack.dylib
    #> 
    #> locale:
    #> [1] en_US.UTF-8/en_US.UTF-8/en_US.UTF-8/C/en_US.UTF-8/en_US.UTF-8
    #> 
    #> attached base packages:
    #> [1] stats     graphics  grDevices utils     datasets  methods  
    #> [7] base     
    #> 
    #> other attached packages:
    #>  [1] vegan_2.5-7        lattice_0.20-44    permute_0.9-5     
    #>  [4] picarro.data_0.1.1 forcats_0.5.1      stringr_1.4.0     
    #>  [7] dplyr_1.0.7        purrr_0.3.4        readr_2.0.1       
    #> [10] tidyr_1.1.3        tibble_3.1.4       tidyverse_1.3.1   
    #> [13] drake_7.13.2       ggbiplot_0.55      agricolae_1.3-5   
    #> [16] car_3.0-11         carData_3.0-4      nlme_3.1-152      
    #> [19] stringi_1.7.3      ggExtra_0.9        ggalt_0.4.0       
    #> [22] ggplot2_3.3.5      lubridate_1.7.10   readxl_1.3.1      
    #> 
    #> loaded via a namespace (and not attached):
    #>  [1] colorspace_2.0-2   ellipsis_0.3.2     rio_0.5.27        
    #>  [4] fs_1.5.0           rstudioapi_0.13    farver_2.1.0      
    #>  [7] bit64_4.0.5        fansi_0.5.0        xml2_1.3.2        
    #> [10] splines_4.1.1      extrafont_0.17     knitr_1.33        
    #> [13] jsonlite_1.7.2     broom_0.7.9        Rttf2pt1_1.3.9    
    #> [16] cluster_2.1.2      dbplyr_2.1.1       shiny_1.6.0       
    #> [19] compiler_4.1.1     httr_1.4.2         backports_1.2.1   
    #> [22] Matrix_1.3-4       assertthat_0.2.1   fastmap_1.1.0     
    #> [25] cli_3.0.1          later_1.3.0        htmltools_0.5.1.1 
    #> [28] prettyunits_1.1.1  tools_4.1.1        igraph_1.2.6      
    #> [31] gtable_0.3.0       glue_1.4.2         maps_3.3.0        
    #> [34] tinytex_0.33       Rcpp_1.0.7         cellranger_1.1.0  
    #> [37] vctrs_0.3.8        extrafontdb_1.0    xfun_0.25         
    #> [40] openxlsx_4.2.4     rvest_1.0.1        mime_0.11         
    #> [43] miniUI_0.1.1.1     lifecycle_1.0.0    MASS_7.3-54       
    #> [46] scales_1.1.1       vroom_1.5.4        hms_1.1.0         
    #> [49] promises_1.2.0.1   parallel_4.1.1     proj4_1.0-10.1    
    #> [52] RColorBrewer_1.1-2 yaml_2.2.1         curl_4.3.2        
    #> [55] labelled_2.8.0     highr_0.9          klaR_0.6-15       
    #> [58] AlgDesign_1.2.0    filelock_1.0.2     zip_2.2.0         
    #> [61] storr_1.2.5        rlang_0.4.11       pkgconfig_2.0.3   
    #> [64] evaluate_0.14      labeling_0.4.2     cowplot_1.1.1     
    #> [67] bit_4.0.4          tidyselect_1.1.1   plyr_1.8.6        
    #> [70] magrittr_2.0.1     R6_2.5.1           generics_0.1.0    
    #> [73] base64url_1.4      combinat_0.0-8     txtq_0.2.4        
    #> [76] DBI_1.1.1          mgcv_1.8-36        pillar_1.6.2      
    #> [79] haven_2.4.3        foreign_0.8-81     withr_2.4.2       
    #> [82] abind_1.4-5        ash_1.0-15         modelr_0.1.8      
    #> [85] crayon_1.4.1       questionr_0.7.4    KernSmooth_2.23-20
    #> [88] utf8_1.2.2         tzdb_0.1.2         rmarkdown_2.10    
    #> [91] progress_1.2.2     grid_4.1.1         data.table_1.14.0 
    #> [94] reprex_2.0.1       digest_0.6.27      xtable_1.8-4      
    #> [97] httpuv_1.6.2       munsell_0.5.0

</details>
