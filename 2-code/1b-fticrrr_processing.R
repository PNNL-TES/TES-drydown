# PROCESSING ----
## META ----

#' applies filter to report
#' @import dplyr
#' @export
fticr_apply_peak_filters = function(report){
  # report %>%
  #   # filter appropriate mass range
  #   filter(Mass>200 & Mass<900) %>%
  #   # remove isotopes
  #   filter(C13==0) %>%
  #   # remove peaks without C assignment
  #   filter(C>0)
  
  report2 = report[report$Mass > 200 & report$Mass < 900, ]
  report3 = report2[report2$C13 == 0, ]
  report4 = report3[report3$C > 0, ]
  report4
}

#' computes indices
#' @import dplyr
#' @export
fticr_compute_indices = function(dat){
  
  # dat =
  # dat %>%
  #   dplyr::select(Mass, C:P) %>%
  #   dplyr::mutate(AImod2 = round((1+C-(0.5*O)-S-(0.5*(N+P+H)))/(C-(0.5*O)-S-N-P),4),
  #                 NOSC =  round(4-(((4*C)+H-(3*N)-(2*O)-(2*S))/C),4),
  #                 HC = round(H/C,2),
  #                 OC = round(O/C,2),
  #                 DBE_AI = 1+C-O-S-0.5*(N+P+H),
  #                 DBE =  1 + ((2*C-H + N + P))/2,
  #                 DBE_C = round(DBE_AI/C,4)) %>%
  #   dplyr::select(-c(C:P))
  
  dat = dat[, c("Mass", "C", "H", "O", "N", "S", "P")]
  dat$AImod = round((1+dat$C-(0.5*dat$O)-dat$S-(0.5*(dat$N+dat$P+dat$H)))/(dat$C-(0.5*dat$O)-dat$S-dat$N-dat$P),4)
  dat$NOSC =  round(4-(((4*dat$C)+dat$H-(3*dat$N)-(2*dat$O)-(2*dat$S))/dat$C),4)
  dat$HC = round(dat$H/dat$C,2)
  dat$OC = round(dat$O/dat$C,2)
  dat$DBE_AI = 1+dat$C-dat$O-dat$S-0.5*(dat$N+dat$P+dat$H)
  dat$DBE =  1 + ((2*dat$C-dat$H + dat$N + dat$P))/2
  dat$DBE_C = round(dat$DBE_AI/dat$C,4)
  dat = dat[, !names(dat) %in% c("C", "H", "O", "N", "S", "P")]
  
}

#' computes molecular formula
#' @import dplyr
#' @export
fticr_compute_mol_formula = function(dat){
  dat %>%
    dplyr::select(Mass, C:P) %>%
    dplyr::mutate(formula_c = if_else(C>0,paste0("C",C),as.character(NA)),
                  formula_h = if_else(H>0,paste0("H",H),as.character(NA)),
                  formula_o = if_else(O>0,paste0("O",O),as.character(NA)),
                  formula_n = if_else(N>0,paste0("N",N),as.character(NA)),
                  formula_s = if_else(S>0,paste0("S",S),as.character(NA)),
                  formula_p = if_else(P>0,paste0("P",P),as.character(NA)),
                  formula = paste0(formula_c,formula_h, formula_o, formula_n, formula_s, formula_p),
                  formula = str_replace_all(formula,"NA","")) %>%
    dplyr::select(Mass, formula)
}

#' assigns seidel classes
#' @import dplyr
#' @export
fticr_assign_class_seidel = function(meta_clean, meta_indices){
  meta_clean %>%
    left_join(meta_indices, by = "Mass") %>%
    mutate(Class = case_when(AImod>0.66 ~ "condensed aromatic",
                             AImod<=0.66 & AImod > 0.50 ~ "aromatic",
                             AImod <= 0.50 & HC < 1.5 ~ "unsaturated/lignin",
                             HC >= 1.5 ~ "aliphatic"),
           Class = replace_na(Class, "other"),
           Class_detailed = case_when(AImod>0.66 ~ "condensed aromatic",
                                      AImod<=0.66 & AImod > 0.50 ~ "aromatic",
                                      AImod <= 0.50 & HC < 1.5 ~ "unsaturated/lignin",
                                      HC >= 2.0 & OC >= 0.9 ~ "carbohydrate",
                                      HC >= 2.0 & OC < 0.9 ~ "lipid",
                                      HC < 2.0 & HC >= 1.5 & N==0 ~ "aliphatic",
                                      HC < 2.0 & HC >= 1.5 & N > 0 ~ "aliphatic+N")) %>%
    dplyr::select(Mass, EMSL_class, Class, Class_detailed)
}

#' makes meta
#' @import dplyr
#' @import stringr
#' @import tidyr
#' @import tibble
#' @export
fticr_make_metadata = function(report){
  fticr_report = (fticr_apply_peak_filters(report))
  
  meta_clean =
    fticr_report %>%
    # select only the relevant columns for the formula assignments
    dplyr::select(Mass, C, H, O, N, S, P, El_comp, Class) %>%
    rename(EMSL_class = Class)
  
  meta_indices = fticr_compute_indices(meta_clean)
  meta_formula = fticr_compute_mol_formula(meta_clean)
  meta_class = fticr_assign_class_seidel(meta_clean, meta_indices)
  
  # output
  meta2 = meta_formula %>%
    left_join(meta_class, by = "Mass") %>%
    left_join(meta_indices, by = "Mass") %>% dplyr::select(-Mass) %>% distinct(.)
  
  
  list(meta2 = meta2,
       meta_formula = meta_formula)
}


## DATA ----

fticr_compute_presence = function(dat){
  dat %>% 
    replace(is.na(.), 0) %>% 
    pivot_longer(-("Mass"), values_to = "presence") %>% 
    # convert intensities to presence==1/absence==0  
    dplyr::mutate(presence = if_else(presence>0,1,0)) %>% 
    # keep only peaks present
    filter(presence>0)
}
fticr_apply_replication_filter = function(data_long_key, ...){
  max_replicates = 
    data_long_key %>% 
    ungroup() %>% 
    group_by(...) %>% 
    distinct(coreID) %>% 
    dplyr::summarise(reps = n())
  
  
  # second, join the `reps` file to the long_key file
  # and then use the replication filter  
  data_long_key %>% 
    group_by(formula, ...) %>% 
    dplyr::mutate(n = n()) %>% 
    left_join(max_replicates) %>% 
    ungroup() %>% 
    mutate(keep = n >= (2/3)*reps) %>% 
    filter(keep) %>% 
    dplyr::select(-keep, -reps)
  
}

## RELABUND


# GRAPHS ----
## van krevelen
gg_vankrev <- function(data,mapping){
  ggplot(data,mapping) +
    # plot points
    geom_point(size=0.5, alpha = 0.5) + # set size and transparency
    # axis labels
    ylab("H/C") +
    xlab("O/C") +
    # axis limits
    xlim(0,1.25) +
    ylim(0,2.5) +
    # add boundary lines for Van Krevelen regions
    geom_segment(x = 0.0, y = 1.5, xend = 1.2, yend = 1.5,color="black",linetype="longdash") +
    geom_segment(x = 0.0, y = 0.7, xend = 1.2, yend = 0.4,color="black",linetype="longdash") +
    geom_segment(x = 0.0, y = 1.06, xend = 1.2, yend = 0.51,color="black",linetype="longdash") +
    guides(colour = guide_legend(override.aes = list(alpha=1, size = 1)))
}
