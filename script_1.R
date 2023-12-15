#Description of script: ---
##This script uses data from an excel file used to collate summary statistics from the literature (related to crop nutrient removal) and converts 
#it into a format suitable for uploading to the DRYAD repository. 

#The maize data are described in Ludemann et al (2022) Field Crops Research https://www.sciencedirect.com/science/article/pii/S0378429022001496?via%3Dihub
#But this dataset includes other crops as well. 

#The following people helped convert data into the excel file include: 
#Joost Krooshof, Bert Rijk, Tobias Bader, Victoria Miles-Hildago, Emil Löwik and Cameron Ludemann.

#This script was written in R version 4.1.0 with a 64-bit computer.

#Libraries----
library(readxl)
library(dplyr)
library(stringr)
library(openxlsx)#For convertToDateTime function.
library(fmtr)#For meta-data descriptions and dictionary
library(libr)#For meta-data descriptions and dictionary

#Settings----
#Ensure all values are decimals rather than scientific notation.
options(scipen = 999)

#Read files----
df <- read_excel("data/raw/Summary_statistics_data_from_articles15122023.xlsx", 
                      col_names = TRUE,
                      sheet = "Combined data",
                      skip = 5)

df_meta <- as.data.frame(df_meta<- read_excel("data/raw/Summary_statistics_data_from_articles15122023.xlsx", 
                     sheet = "Metadata list", range = "c35:g514"))

#Tidy data frames----+++++++
#df----
#Select only rows of interest by deleting extraneous rows. 
df <- df[-c(1),-c(1) ]

#Convert $ icons in headers to - to avoid R coding issues. 
names(df) <- gsub(x = names(df), pattern = "\\$", replacement = "_") 
names(df) <- gsub(x = names(df), pattern = "\\/", replacement = "_") 

#Delete extraneous columns
df <- df[-c(479:ncol(df))]

#Convert dates into numeric and then into date format. 
df$`Sowing_date_DD_MM_YY` <- as.numeric(df$`Sowing_date_DD_MM_YY`)
df$`Harvest_date_DD_MM_YY` <- as.numeric(df$`Harvest_date_DD_MM_YY`)
df$Date_sowing_YYYYMMDD <- convertToDateTime(df$`Sowing_date_DD_MM_YY`, origin = "1900-01-01")
df$Date_harvest_YYYYMMDD <- convertToDateTime(df$`Harvest_date_DD_MM_YY`, origin = "1900-01-01")

df <- dplyr::rename(df,
                         "Article_ID"="Article_ID_Seq_numbers",
                         "First_author_name"="1st_author_name_Last_name_1st_author",
                         "Second_author_name"="2nd_author_name_Last_name_2nd_author",
                         "Year_published"="Year_published_Year",
                         "Journal_title"="Journal_title_Title",
                         "Title_of_article"="Title_of_article_Title",
                         "Journal_vol"="Journal_vol_Volume",
                         "Journal_iss"="Journal_iss_Issue",
                         "Page_numbers"="Page_numbers_Numbers_x-y",
                         "Table_number"="Table_number_Number",
                         "Figure_number"="Figure_number_Number",
                         "DOI"="DOI_DOI",
                         "Website"="Website_Website",
                         "Data_type"="Data_type_Primary_Secondary",
                         "Article_quality"="Journal_quality_Number(1-3)",
                         "Experiment_Number"="Experiment_Number",
                         "Year_experiment"="Year_experiment_Year",
                         "Data_license_no"="Data_license_no_Number_code",
                         "Dataset_ID"="Dataset_ID_Number_code",
                         "Plot_area"="Plot_area_metres_square",
                         "Block"="Block_Number_code",
                         "Number_years_data"="Number_years_data_Number",
                         "Country"="Country_Name",
                         "Replicate_n"="Replicate_n_Number",
                         "Replicate_num"="Replicate_num_Number",
                         "Country"="Country_Name",
                         "State_province"="State_province_Name",
                         "Nearest_town_city"="Nearest_town_city_Name",
                         "GPS_coordinates_altitude"="GPS_coordinates_Coordinates",
                         "Latin_name"="Latin_name_Name",
                         "Crop_name"="Crop_name_Name",
                         "Crop_variety"="Crop_variety_Name",
                         "Crop_variety_other"="Crop_variety_other_Description",
                         "Sow_density_Seeds_m2"="Sow_density_Seeds_m2",
                         "Harvest_density_Plants_m2"="Harvest_density_Plants_m2",
                    "Crop_variety_release_Year"="Crop_variety_release_yr_Year")

#List columns that you want converted to numeric class
cols_num <- c("Year_published","Article_quality","Experiment_Number","Year_experiment",
              "Plot_area","Block","Number_years_data","Replicate_n",
              "Replicate_num","Annual_rainfall_mean_mm_year","Actual_rainfall_during trial_mm","Actual_irrigation_mm",
              "Soil_moisture_%_WHC","Soil_clay_%","Soil_silt_%","Soil_sand_%",
              "Soil_pH_H2O_1:1_Number","Soil_pH_H2O_1:2.5_Number","Soil_NC_Kjeldahl_g_N_kg","Soil_Carbon_Wakley_Black_g_C_kg",
              "Soil_N_(Parco2020)_kg_N_ha","Soil_P_Olsen_mg_kg","Soil_P_Bray_1_mg_P_kg","Soil_P_Mehlich-3_mg_P_kg",
              "Soil_K_exchangeable_mg_K_kg","Soil_K_(Mehlich-3)_mg_K_kg","Soil_pH_KCl_Number","Crop_variety_release_Year",
              "Sow_density_Seeds_m2","Harvest_density_Plants_m2","Fertiliser_N_kg_N_ha","Fertiliser_P_kg_P_ha",
              "Fertiliser_K_kg_K_ha","Fertiliser_S_kg_S_ha","Fertiliser_Ca_kg_Ca_ha","Fertiliser_Mg_kg_Mg_ha",
              "Fertiliser_B_kg_B_ha","Fertiliser_Cl_kg_Cl_ha","Fertiliser_Cu_kg_Cu_ha","Fertiliser_Fe_kg_Fe_ha",
              "Fertiliser_Mn_kg_Mn_ha","Fertiliser_Mo_kg_Mo_ha","Fertiliser_Zn_kg_Zn_ha",
              "CPY_mean_kg_fresh_ha","CPY_sd_kg_fresh_ha","CPY_SE_kg_fresh_ha",
              "CobY_mean_kg_fresh_ha","CobY_sd_kg_fresh_ha","CobY_SE_kg_fresh_ha",
              "CRY_mean_kg_fresh_ha","CRY_sd_kg_fresh_ha","CRY_SE_kg_fresh_ha",
              "AGY_mean_kg_fresh_ha","AGY_sd_kg_fresh_ha","AGY_SE_kg_fresh_ha",
              "CPY_mean_kg_DM_ha","CPY_sd_kg_DM_ha","CPY_SE_kg_DM_ha",
              "CobY_mean_kg_DM_ha","CobY_sd_kg_DM_ha","CobY_SE_kg_DM_ha",
              "CRY_mean_kg_DM_ha","CRY_sd_kg_DM_ha","CRY_SE_kg_DM_ha",
              "AGY_mean_kg_DM_ha","AGY_sd_kg_DM_ha","AGY_SE_kg_DM_ha",
              "HI_mean_Unitless","HI_sd_Unitless","HI_SE_Unitless",
              "CPCon_DM_mean_kg_DM_kg_fresh","CPCon_DM_sd_kg_DM_kg_fresh","CPCon_DM_SE_kg_DM_kg_fresh",
              "CPCon_Prot_mean_kg_kg_DM","CPCon_Prot_sd_kg_kg_DM","CPCon_Prot_SE_kg_kg_DM",
              "CPCon_N_mean_kg_kg_DM","CPCon_N_sd_kg_kg_DM","CPCon_N_SE_kg_kg_DM",
              "CPCon_P_mean_kg_kg_DM","CPCon_P_sd_kg_kg_DM","CPCon_P_SE_kg_kg_DM",
              "CPCon_K_mean_kg_kg_DM","CPCon_K_sd_kg_kg_DM","CPCon_K_SE_kg_kg_DM",
              "CPCon_S_mean_kg_kg_DM","CPCon_S_sd_kg_kg_DM","CPCon_S_SE_kg_kg_DM",
              "CRCon_Prot_mean_kg_kg_DM","CRCon_Prot_sd_kg_kg_DM","CRCon_Prot_SE_kg_kg_DM",
              "CRCon_N_mean_kg_kg_DM","CRCon_N_sd_kg_kg_DM","CRCon_N_SE_kg_kg_DM",
              "CRCon_P_mean_kg_kg_DM","CRCon_P_sd_kg_kg_DM","CRCon_P_SE_kg_kg_DM",
              "CRCon_K_mean_kg_kg_DM","CRCon_K_sd_kg_kg_DM","CRCon_K_SE_kg_kg_DM",
              "CRCon_S_mean_kg_kg_DM","CRCon_S_sd_kg_kg_DM","CRCon_S_SE_kg_kg_DM",
              "CP_Up_N_mean_kg_ha","CP_Up_N_sd_kg_ha","CP_Up_N_SE_kg_ha",
              "CP_Up_P_mean_kg_ha","CP_Up_P_sd_kg_ha","CP_Up_P_SE_kg_ha",
              "CP_Up_K_mean_kg_ha","CP_Up_K_sd_kg_ha","CP_Up_K_SE_kg_ha",
              "CP_Up_S_mean_kg_ha","CP_Up_S_sd_kg_ha","CP_Up_S_SE_kg_ha",
              "CR_Up_N_mean_kg_ha","CR_Up_N_sd_kg_ha","CR_Up_N_SE_kg_ha",
              "CR_Up_P_mean_kg_ha","CR_Up_P_sd_kg_ha","CR_Up_P_SE_kg_ha",
              "CR_Up_K_mean_kg_ha","CR_Up_K_sd_kg_ha","CR_Up_K_SE_kg_ha",
              "CR_Up_S_mean_kg_ha","CR_Up_S_sd_kg_ha","CR_Up_S_SE_kg_ha")

#Convert selected columns into numeric as desired. 
df[cols_num] <- sapply(df[cols_num],as.numeric)

#Convert GPS coordinates to decimalised latitude and longitude. 
#Delete unnecessary altitude characters from GPS columns (text including 'with' and following 'with)
df$GPS_DMS<- sub(", with.+", "", df$GPS_coordinates_altitude)

#Delete second sets of GPS coordinates (effectively ignore second set of coords as they 
#are generally nearby). This is so that we can extract one set of 'representative'
#GPS coordinates. See: https://stackoverflow.com/questions/60117387/delete-everything-after-second-comma-from-string
df$GPS_DMS<- sub("^([^,]*,[^,]*),.*", "\\1", df$GPS_DMS)

#Delete everything after the ";" as this is sometimes used to differentiate between two sets of codes. 
df$GPS_DMS<- sub(";.+", "", df$GPS_DMS)

#Convert GPS coordinates in Degrees Minutes Seconds (DSM) to Decimalised (DD)
df$GPS_DMS <- parzer::parse_llstr(df$GPS_DMS)
df$GPStester <- df$GPS_coordinates_altitude

df$GPS_lat_DD<- df$GPS_DMS[,1]
df$GPS_long_DD<- df$GPS_DMS[,2]

df <- rename(df, Crop_original="Crop_name")

#Create function to standardise crop names
Standardise_crop_names <- function (df,Crop_original){
  df <- df %>%
    mutate(Crop_standardised = case_when(
      str_detect(Crop_original, regex("corn|Corn|maize|Maize", ignore_case=TRUE)) ~ "Maize",
      str_detect(Crop_original, regex("rice|Rice", ignore_case=TRUE)) ~ "Rice",
      str_detect(Crop_original, regex("soy|Soy|Soybean|Soybeans|Glycine max", ignore_case=TRUE)) ~ "Soybeans",   
      str_detect(Crop_original, regex("wheat|Wheat|spelt", ignore_case=TRUE)) ~ "Wheat",  
      str_detect(Crop_original, regex("cotton|Cotton", ignore_case=TRUE)) ~ "Cotton", 
      str_detect(Crop_original, regex("barley|barely", ignore_case=TRUE)) ~ "Barley",  
      str_detect(Crop_original, regex("Rye", ignore_case=TRUE)) ~ "Rye",  
      str_detect(Crop_original, regex("Pea", ignore_case=TRUE)) ~ "Pea",        
      str_detect(Crop_original, regex("Sorghum", ignore_case=TRUE)) ~ "Sorghum",        
      str_detect(Crop_original, regex("Millet", ignore_case=TRUE)) ~ "Millet", 
      str_detect(Crop_original, regex("Canola|Rapeseed", ignore_case=TRUE)) ~ "Rapeseed",
      str_detect(Crop_original, regex("indian mustard", ignore_case=TRUE)) ~ "Indian mustard",      
      str_detect(Crop_original, regex("linola", ignore_case=TRUE)) ~ "Linseed flax",       
      TRUE ~ Crop_original))
  return(df)      
}

#Create Crop column with standardised names. 
df <-  Standardise_crop_names(df, Crop_original) 

#Remove unwanted columns----
df <- select(df,
             -Other_variable_40_undefined_units,
             -Other_variable_41_undefined_units,
             -Other_variable_42_undefined_units,
             -Other_variable_43_undefined_units,
             -Other_variable_44_undefined_units,
             -Other_variable_45_undefined_units,
             -Other_variable_46_undefined_units,
             -Other_variable_47_undefined_units,
             -Other_variable_48_undefined_units,
             -Other_variable_49_undefined_units,
             -Other_variable_50_undefined_units,
             -Other_variable_51_undefined_units,
             -Other_variable_52_undefined_units,
             -Other_variable_53_undefined_units,
             -Other_variable_54_undefined_units,
             -Other_variable_55_undefined_units,
             -Other_variable_56_undefined_units,
             -Other_variable_57_undefined_units,
             -Other_variable_58_undefined_units,
             -Other_variable_59_undefined_units,
             -Other_variable_60_undefined_units,
             -Other_variable_61_undefined_units,
             -Other_variable_62_undefined_units,
             -Other_variable_63_undefined_units,
             -Other_variable_64_undefined_units,
             -Other_variable_65_undefined_units,
             -Other_variable_66_undefined_units,
             -Other_variable_67_undefined_units,
             -GPStester, -GPS_DMS, -Other_info_3_NA, 
             -Other_info_4_NA)

#Relocate columns
df <- df %>% relocate(Date_sowing_YYYYMMDD:Date_harvest_YYYYMMDD, .after = Harvest_date_DD_MM_YY) %>% 
  relocate(GPS_lat_DD:GPS_long_DD, .after = GPS_coordinates_altitude) %>% 
  relocate(Crop_standardised, .after=Crop_original) %>% 
  relocate(N_fixation_kg_N_ha:'pc_Ndfa_%', .after=Fertiliser_Zn_kg_Zn_ha) %>% 
  relocate('Soil_pH_H2O_1:5_Number', .after=`Soil_pH_H2O_1:2.5_Number`)  %>% 
  relocate('Soil_N_Alkaline_permanganate_kg_N_ha':'Soil_K_(ammonium_acetate)_mg_kg', .after='Soil_OM_%') %>% 
  relocate(Soil_class_Name, .after=Soil_texture_Name)

#df_meta----
#Create meta-data file----
df_meta$AbbreviationUnits <- paste0(df_meta$Abbreviation,"_",
                                    df_meta$Units)

df_meta1 <- as.data.frame(dictionary(df)) %>% mutate(Order=1:n()) %>% 
  select(-Description)

df_meta2 <- merge(df_meta, df_meta1,by.x = "AbbreviationUnits", by.y = "Column")

df_meta3 <- merge(df_meta, df_meta1,by.x = "Abbreviation", by.y = "Column")

df_meta3$AbbreviationUnits <- df_meta3$Abbreviation

df_meta4 <- rbind(df_meta2,
                  df_meta3)

df_meta5 <- select(df_meta4, 
                   AbbreviationUnits, 
                   Variable_Number,
                   Units, 
                   Class, 
                   NAs, 
                   Variable_Number, 
                   `Notes for data inputter`)

df_meta1a <- select(df_meta1,
                    Column, Order)

df_meta <- merge(df_meta1a, df_meta5, all.x = TRUE, 
                    by.x="Column", 
                    by.y="AbbreviationUnits") %>% arrange(Order)

#Add info for rows with missing data----
df_meta_missing<-dplyr::filter(df_meta,is.na(Variable_Number)) %>% 
  select(-Class)

df_meta1 <- select(df_meta1, 
                   Column, Class, Order)


df_meta_missing <- merge(df_meta_missing, df_meta1, 
                         all.x=TRUE, 
                         by.x=c("Column","Order"), 
                         by.y=c("Column","Order")) %>% 
  select(Column,Order,Class)


#Create data frame with missing information----
df_meta_missing1 <- data.frame (Column  = c("Article_quality","Crop_original","Crop_standardised","Crop_variety_release_Year","Date_harvest_YYYYMMDD","Date_sowing_YYYYMMDD","First_author_name","GPS_coordinates_altitude","GPS_lat_DD","GPS_long_DD","Harvest_date_DD_MM_YY","Second_author_name","Sowing_date_DD_MM_YY"),
                                Units= c("numeric","character","character","numeric","date","date","character","character","numeric","numeric","date","character","date"),
                                Notes= c("Article quality subjectively assessed by reviewer on 1-3 scale with 1 being best quality","Name of crop originally used in article","Name of crop standardised","Year of 1st release of crop variety","Harvest date  in YYYYMMDD format","Sowing date  in YYYYMMDD format","Name of first author of article","Global Positioning System coordinates and altitude in metres above sea level","Global Positioning System, latitude, decimal degrees","Global Positioning System, longitude, decimal degrees","Original harvest date in DD MM YY format","Name of second author of article, or if more than 2 authors, use et al.","Original sowing date in DD MM YY format")
                                )

df_meta_missing <- select(df_meta_missing, Column, Order, Class)

df_meta_missing1 <- merge(df_meta_missing,df_meta_missing1, 
                          all.x=TRUE, 
                          by.x="Column", 
                          by.y="Column")

#Exclude data with NAs in Variable_number column so we can add missing information----
df_meta <- anti_join(df_meta, filter(df_meta, is.na(Variable_Number))) %>% 
 rename(Notes=`Notes for data inputter`) %>% 
   select(-NAs,-Variable_Number)

#Rbind together to fill in missing data.
df_meta <- rbind(df_meta, df_meta_missing1) %>% 
  arrange(Order) %>% 
  select(Order,Column,Units,Class,Notes)

#Save files as csv
write.csv(df,"./data/standardised/Summary_statistics_data_from_articles.csv",row.names= FALSE)
write.csv(df_meta,"./data/standardised/Meta_data_Summary_statistics_data_from_articles.csv",row.names= FALSE)