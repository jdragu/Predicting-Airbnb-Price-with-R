# clear data from workspace

rm(list = ls())




# load packages in the current session

library("tidyverse")

library("rpart")

library("rpart.plot")

library("caret")

library("forecast")

library('FNN')

library('ggplot2')

library('fastDummies')




# load dataset

airbnb_sydney <- read_csv('listings_dec18.csv')



# list all variables
names(airbnb_sydney)



# remove irrelevant columns

airbnb_sydney <- airbnb_sydney[,-1:-26]
airbnb_sydney <- subset(airbnb_sydney, select=-c(host_thumbnail_url,host_picture_url,host_neighbourhood,host_verifications,
                                                       neighbourhood_group_cleansed,smart_location,country_code,country,
                                                       latitude,longitude,amenities,calendar_last_scraped,calendar_updated,
                                                       weekly_price,monthly_price,has_availability))


# check remaining columns for usefulness

unique(airbnb_sydney$state) #remove (Sydney is only in NSW)
unique(airbnb_sydney$market) #remove (market = Sydney)
unique(airbnb_sydney$neighbourhood) #remove (neighbourhood_cleansed more useful)
unique(airbnb_sydney$neighbourhood_cleansed) #keep
unique(airbnb_sydney$city) #remove (city = Sydney)
unique(airbnb_sydney$zipcode) #keep



# remove additional irrelevant columns (removing street because zipcode works)

airbnb_sydney <- subset(airbnb_sydney,select=-c(state,market,neighbourhood,city,street))




# impute missing values with zero

airbnb_sydney <- airbnb_sydney %>% 
  mutate_at(c('security_deposit','cleaning_fee','bathrooms','host_total_listings_count',
              'bedrooms','reviews_per_month','beds'), ~replace_na(.,0))



# check for NA in all other columns

colnames(airbnb_sydney)[ apply(airbnb_sydney, 2, anyNA) ]



# drop license, host_acceptance_rate/response_rate and jurisdiction names
## also first_review, last_review, square feet
### don't need both host_listings_count and host_total listings_count)

airbnb_sydney <- subset(airbnb_sydney,select=-c(license,jurisdiction_names,host_acceptance_rate,host_response_rate,
                                                      first_review,last_review,square_feet,host_listings_count))


# now we have dropped all columns which are not useful due to an overwhelming amount of NA
## next we will drop all rows of NA

airbnb_sydney <- drop_na(airbnb_sydney)



# check to ensure no more NAs
is.na(airbnb_sydney)
apply(airbnb_sydney, 2, function(x) any(is.na(x)))



# plot price distribution


ggplot(airbnb_sydney, aes(x=price)) +
  xlab("Price") +  labs(title= "Listings Price Distribution (2018)") +
  geom_histogram(binwidth=25, colour="black", fill="white") +
  geom_vline(aes(xintercept=mean(price, na.rm=T)),
             color="red", linetype="dashed", size=1) +
  xlim(0,1000)

mean(airbnb_sydney$price)


# create dummy variables

unique(airbnb_sydney$property_type)
unique(airbnb_sydney$room_type)
unique(airbnb_sydney$bed_type)
unique(airbnb_sydney$cancellation_policy)

airbnb_sydney <- airbnb_sydney %>%
  mutate(host_is_superhost = if_else(host_is_superhost == 'TRUE', 1, 0),
         host_has_profile_pic = if_else(host_has_profile_pic == 'TRUE', 1, 0),
         is_location_exact = if_else(is_location_exact == 'TRUE', 1, 0),
         room_type_private = if_else(room_type == 'Private room', 1, 0),
         room_type_entire = if_else(room_type == 'Entire home/apt', 1, 0),
         room_type_shared = if_else(room_type == 'Shared room', 1, 0),
         bed_type_real = if_else(bed_type == 'Real bed', 1, 0),
         bed_type_pullout = if_else(bed_type == 'Pull-out Sofa', 1, 0),
         bed_type_futon = if_else(bed_type == 'Futon', 1, 0),
         bed_type_airbed = if_else(bed_type == 'Airbed', 1, 0),
         bed_type_couch = if_else(bed_type == 'Couch', 1, 0),
         requires_license = if_else(requires_license == 'TRUE', 1, 0),
         instant_bookable = if_else(instant_bookable == 'TRUE', 1, 0),
         is_business_travel_ready = if_else(is_business_travel_ready == 'TRUE', 1, 0),
         require_guest_profile_picture = if_else(require_guest_profile_picture == 'TRUE', 1, 0),
         require_guest_phone_verification = if_else(require_guest_phone_verification == 'TRUE', 1, 0),
         host_identity_verified = if_else(host_identity_verified == 'TRUE', 1, 0),
         cancellation_policy_strict14 = if_else(cancellation_policy == 'strict_14_with_grace_period', 1, 0),
         cancellation_policy_moderate = if_else(cancellation_policy == 'moderate', 1, 0),
         cancellation_policy_flexible = if_else(cancellation_policy == 'flexible', 1, 0),
         cancellation_policy_sstrict30 = if_else(cancellation_policy == 'super_strict_30', 1, 0),
         cancellation_policy_sstrict60 = if_else(cancellation_policy == 'super_strict_60', 1, 0))

property_levels <- airbnb_sydney %>% 
  group_by(property_type) %>%
  summarise(no_rows = length(property_type))
# we will encode only most common property types then use 'other' category for the rest
## most common: 1. apartment, 2. house, 3. townhouse, 4. condo, 5. other

airbnb_sydney <- airbnb_sydney %>%
  mutate(property_type_apt = if_else(property_type == 'Apartment', 1, 0),
         property_type_house = if_else(property_type == 'House', 1, 0),
         property_type_townhouse = if_else(property_type == 'Townhouse', 1, 0),
         property_type_condo = if_else(property_type == 'Condominium', 1, 0),
         property_type_other = if_else(property_type != 'Apartment' | property_type != 'House' | property_type != 'Townhouse' | property_type != 'Condominium', 1, 0))


# we will also encode only most common neighbourhoods, grouping the rest in "other" bin
table(airbnb_sydney$neighbourhood_cleansed) 
# most common: 1. Sydney, 2. Waverley, 3. Randwick, 4. Manly, 5. Other
airbnb_sydney <- airbnb_sydney %>%
  mutate(neighbourhood_sydney = if_else(neighbourhood_cleansed == 'Sydney', 1, 0),
         neighbourhood_waverley = if_else(neighbourhood_cleansed == 'Waverley', 1, 0),
         neighbourhood_randwick = if_else(neighbourhood_cleansed == 'Randwick', 1, 0),
         neighbourhood_manly = if_else(neighbourhood_cleansed == 'Manly', 1, 0),
         neighbourhood_other = if_else(neighbourhood_cleansed != 'Sydney' | neighbourhood_cleansed != 'Waverley' | neighbourhood_cleansed != 'Randwick' | neighbourhood_cleansed != 'Manly', 1, 0))



# we will now encode zipcode

table(airbnb_sydney$zipcode)

airbnb_sydney$zipcode <- substr(airbnb_sydney$zipcode, 1, 3)

airbnb_sydney <- dummy_cols(airbnb_sydney, select_columns = 'zipcode')

airbnb_sydney <- select(airbnb_sydney, -zipcode)



airbnb_sydney <- subset(airbnb_sydney,select=-c(neighbourhood_cleansed,property_type,bed_type))


airbnb_sydney <- subset(airbnb_sydney,select=-c(room_type,cancellation_policy))




# backward elimination round 1

airbnb_sydney.mlr = lm(price ~., data = airbnb_sydney)

summary(airbnb_sydney.mlr)


airbnb_sydney <- subset(airbnb_sydney, select = -c(bed_type_pullout))



# backward elimination round 2

airbnb_sydney.mlr = lm(price ~., data = airbnb_sydney)

summary(airbnb_sydney.mlr)


airbnb_sydney <- subset(airbnb_sydney, select = -c(review_scores_accuracy))



# backward elimination round 3

airbnb_sydney.mlr = lm(price ~., data = airbnb_sydney)

summary(airbnb_sydney.mlr)


airbnb_sydney <- subset(airbnb_sydney, select = -c(zipcode_497))



# backward elimination round 4


airbnb_sydney.mlr = lm(price ~., data = airbnb_sydney)

summary(airbnb_sydney.mlr)



# backward elimination subsequent rounds:

airbnb_sydney.mlr = lm(price~host_total_listings_count + host_identity_verified + is_location_exact + accommodates + bathrooms + bathrooms + bedrooms + security_deposit + cleaning_fee + guests_included + maximum_nights + availability_30 + availability_365 + review_scores_rating + 
                         review_scores_location + review_scores_value + instant_bookable + calculated_host_listings_count + reviews_per_month + room_type_private + room_type_entire + cancellation_policy_flexible + cancellation_policy_sstrict30 + 
                        property_type_apt + property_type_house + property_type_townhouse + property_type_condo + neighbourhood_waverley + neighbourhood_manly + 
                          zipcode_201 + zipcode_202 + zipcode_203 + zipcode_204 + zipcode_205 + zipcode_206 + zipcode_207 + zipcode_209 + zipcode_211 + zipcode_212 + zipcode_213 + zipcode_214 + zipcode_215 + zipcode_216 + zipcode_217 + zipcode_219 + zipcode_220 + zipcode_221 + zipcode_222 + zipcode_223 + zipcode_256 + zipcode_257 + zipcode_274 + zipcode_275 + zipcode_276 + zipcode_277 + zipcode_277, data = airbnb_sydney)

summary(airbnb_sydney.mlr)




# create a new variable "id" that reflects the row number

airbnb_sydney <- airbnb_sydney %>%
  rename(price_actual = price)

airbnb_sydney <- airbnb_sydney %>% 
  mutate(id=1:nrow(airbnb_sydney))


####################### REGRESSION TREE ##################################


#### pruning a regression tree ####


### step 1: set the seed, data partition - train & validation

# set seed to 30

set.seed(30)


# randomly draw 70% of the data 
# assign it to an object "train"

train = airbnb_sydney %>%
  sample_frac(0.7)


# extract the remaining 30% of the main data
# assign it to an object "validation"

validation = airbnb_sydney %>%
  slice(setdiff(airbnb_sydney$id, train$id))



### step2 : run a tree with options cp = 0.001, minsplit = 5 or 10, xval = 5 or 10

airbnb_sydney.rt = rpart(price_actual~host_total_listings_count + host_identity_verified + is_location_exact + accommodates + bathrooms + bathrooms + bedrooms + security_deposit + cleaning_fee + guests_included + maximum_nights + availability_30 + availability_365 + review_scores_rating + 
                           review_scores_location + review_scores_value + instant_bookable + calculated_host_listings_count + reviews_per_month + room_type_private + room_type_entire + cancellation_policy_flexible + cancellation_policy_sstrict30 + 
                           property_type_apt + property_type_house + property_type_townhouse + property_type_condo + neighbourhood_waverley + neighbourhood_manly + 
                           zipcode_201 + zipcode_202 + zipcode_203 + zipcode_204 + zipcode_205 + zipcode_206 + zipcode_207 + zipcode_209 + zipcode_211 + zipcode_212 + zipcode_213 + zipcode_214 + zipcode_215 + zipcode_216 + zipcode_217 + zipcode_219 + zipcode_220 + zipcode_221 + zipcode_222 + zipcode_223 + zipcode_256 + zipcode_257 + zipcode_274 + zipcode_275 + zipcode_276 + zipcode_277 + zipcode_277, 
                         data = train, method = "anova", cp = 0.001, minsplit = 10, xval = 10)



### step 3: plot the cp or relative error

# choose the value for "size of the tree" where the relative error stabilizes

plotcp(airbnb_sydney.rt)

# error is dropping at first, rises a fractional amount, then stabilizes at ~16 splits



### step 4: find "nsplit" value and its associated cp value from chosen "size of the tree" value

cp.table = as_tibble(airbnb_sydney.rt$cptable)

# nsplit = size of tree - 1 
# store the cp value in an object "optimal.cp"

optimal.cp = cp.table %>%
  filter(nsplit == 21)



### step 5: prune the tree with the "optimal.cp" value

pruned.ct = prune(airbnb_sydney.rt, cp = optimal.cp$CP)


# plot of the pruned tree

prp(pruned.ct, type = 1, extra = 1, under = TRUE, split.font = 2, varlen = -10)



airbnb_sydney[sample(nrow(airbnb_sydney), 3), ]



### step 6: predict the price for validation data

prediction = predict(pruned.ct, validation, type = "vector")



### step 7: generate accuracy measures (ME, MAE, MPE, MAPE, RMSE)

# create a new variable "price_prediction" in the validation data
# price_prediction reflects the predicted price

validation = validation %>%
  mutate(price_prediction = prediction)


# accuracy measures

accuracy(validation$price_prediction, validation$price_actual)

