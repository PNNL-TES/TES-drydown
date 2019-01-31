
<!-- README.md is generated from README.Rmd. Please edit that file -->
TES-drydown
===========

![](README-unnamed-chunk-1-1.png)

    #>    Min. 1st Qu.  Median    Mean 3rd Qu.    Max. 
    #> -2.6967 -0.7200 -0.1292 -0.4164 -0.0325  0.1300

Currently cores' median mass change is -0.1 g/day:

``` r
ggplot(tibble(x = core_chg), aes(x = x)) + 
  geom_histogram(bins = 25) +
  xlab("Mass loss (g) per day")
```

![](README-unnamed-chunk-2-1.png)
