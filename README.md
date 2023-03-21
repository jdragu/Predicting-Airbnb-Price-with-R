# Predicting-Airbnb-Price-with-R
Predictive Modelling with R class project based on Kaggle dataset https://www.kaggle.com/datasets/tylerx/sydney-airbnb-open-data

INTRODUCTION
Airbnb is a major vacation rental company which offers the service of connecting hosts to guests from all over the world. Guests can search through a wide database of listings and pick the homestay which best fits their holiday dream. One major decision-making factor is price, which varies by season and by market conditions.
With such a large database, each listing must stand out in terms of amenities and pricing in order to attract its target customers. A host must be able to evaluate their homestay based on its neighborhood, location, floorplan, and amenities, among other factors, in order to determine the ideal pricing point. Now, with the InsideAirbnb initiative, hosts, guests, and researchers alike have access to global Airbnb data in order to evaluate their pricing and market position.

DATA CLEANING + SETUP
For this project the group used a dataset from Kaggle that was based on the listings of Airbnbs in Sydney Australia2 for the year of 2018. This data set consisted of  36,662 observations and 96 variables in total. Prior to running our models, we first cleaned the data. As stated, the dataset had 96 columns, many of which were identifying values such as host_id, which were removed as they are irrelevant to a price prediction model. In addition, there were some columns which were clearly intended for use in Airbnb global data such as city and market, which all referred only to Sydney, Australia.

We removed blank rows and imputed NA values with zeros where relevant, such as in the case of security_deposit and number of bathrooms. Finally, we encoded categorical variables using a number of methods such as one-hot encoding, dummy encoding, and feature binning. For zip code, we took the first three characters of each zip code and then used fastDummies to dummy encode the variable. Then, to select features significant to our outcome variable (price per night), we used the backwards elimination method until all predictor variables were significant and relevant to the outcome. Our final Multiple R-squared was 0.4399 and our Adjusted R-squared 0.4386.

This was done within the scope of a Predictive Modelling with R undergraduate-level course. Further data and model exploration is recommended for graduate-level projects and beyond. 
