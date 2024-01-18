EA_ImObs_SPINS_SPASD
===============================================

This repo contains code for Empathic Accuracy (EA) and Imitate Observe (ImObs) task fMRI analyses in SPINS and SPIN-ASD samples, including group-based and transdiagnostic analyses across autism, schizophrenia spectrum disorders (SSDs), and typically developing controls (TDCs). Social cognitive performance is also compared and related to task-based brain activity.

Created by Lindsay Oliver (lindsay.oliver@camh.ca) and Iska Moxon-Emre


Project Organization
-----------------------------------

    .
    ├── README.md          <- The top-level README
    ├── .gitignore         <- Files to not upload to github - by default includes /data
    ├── data
    │   ├── processed      <- The final dataset (can include subfolders etc)
    │   └── raw            <- The original dataset, generally a link to minimally preprocessed data
    │
    ├── notebooks          <- R notebooks for analysis workflow 
    │
    ├── docs               <- Data dictionaries, manuals, and other explanatory materials
    │
    ├── paper              <- Manuscript drafts 
    │
    ├── results
    │
    ├── PALM               <- PALM (Permutation Analysis of Linear Models) scripts for EA and ImObs tasks
    │
    
    

## notebooks:  
**ImObs_MRIQC_and_QC.Rmd** - quality control script for ImObs data  
**EA_SPIN_ASD_QC.Rmd** - quality control script for EA data  
**SPIN_ASD_trans_factor_scores.R** - script to generate the social cognitive mentalizing and simulation factor scores  
**ImObs_participant_characteristics.Rmd** - script characterizing the ImObs sample and comparing demographics and social cognitive performance  
**EA_participant_characteristics.Rmd** - script characterizing the EA sample and comparing demographics and social cognitive performance  
**beta_weights_mentalizing_simulation.Rmd** - script with the exploratory transdiagnostic correlations between EA brain activity (beta weights) and social cognitive performance (mentalizing and simulation scores)  

## PALM:  
### ea_PALM_1_group and imobs_PALM_1_group contain the single group analyses for autism (ASD), SSDs, and TDCs  
ea_1_group_pmod_cov_age_sex - full task  
neg_ea_1_group_pmod_cov_age_sex - negative valence  
pos_ea_1_group_pmod_cov_age_sex - positive valence  

imobs_1_group_cov_age_sex - full task  
neg_imobs_1_group_cov_age_sex - negative valence  
pos_imobs_1_group_cov_age_sex - positive valence  

### ea_PALM_2_group and imobs_PALM_2_group contain the two group analyses for ASD vs SSDs, ASD vs TDCs, and SSDs vs TDCs  
ea_2_group_pmod_cov_age_sex - full task  
neg_ea_2_group_pmod_cov_age_sex - negative valence  
pos_ea_2_group_pmod_cov_age_sex - positive valence  

imobs_2_group_cov_age_sex - full task  
neg_imobs_2_group_cov_age_sex - negative valence  
pos_imobs_2_group_cov_age_sex - positive valence  

### ea_PALM_transdiag and imobs_PALM_transdiag contain transdiagnostic analyses  
ea_transdiag_NONpmod_mentalizing_cov_age_sex - including mentalizing scores   
ea_transdiag_NONpmod_simulation_cov_age_sex - including simulation scores   

imobs_transdiag_mentalizing_cov_age_sex - including mentalizing scores  
imobs_transdiag_simulation_cov_age_sex - including simulation scores  

### Within each of these directories:  
**code** contains the PALM scripts   
**con_design** contains the design matrices (*_design_*.csv) and contrast files (*_contrast_*.csv)  
**filelists** contains the input file lists for PALM analyses  
**subids** contains the participant ID lists for each group  


