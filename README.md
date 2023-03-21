# Predicting-Airbnb-Price-with-R
Predictive Modelling with R class project based on Kaggle dataset https://www.kaggle.com/datasets/tylerx/sydney-airbnb-open-data

INTRODUCTION
Airbnb is a major vacation rental company which offers the service of connecting hosts to guests from all over the world. Guests can search through a wide database of listings and pick the homestay which best fits their holiday dream. One major decision-making factor is price, which varies by season and by market conditions.
With such a large database, each listing must stand out in terms of amenities and pricing in order to attract its target customers. A host must be able to evaluate their homestay based on its neighborhood, location, floorplan, and amenities, among other factors, in order to determine the ideal pricing point. Now, with the InsideAirbnb initiative, hosts, guests, and researchers alike have access to global Airbnb data in order to evaluate their pricing and market position.

PROBLEM DESCRIPTION
The housing market across Australia has remained unsteady over the past five years, particularly since the pandemic. In January 2023, the number of new owner-occupier first home buyer loans fell to 8.1%, which is the lowest level since February 2017. This month, March 2023, Australian property prices finally seemed to stabilize. It is not known whether prices will continue to stabilize, but this certainly opens up the opportunity for more buyers to enter the market. For those looking to buy a property for short-term renting, such as with Airbnb, it will be imperative to evaluate the market and set pricing accordingly so that the host may not only successfully enter the market but also make a profit.
	Using InsideAirbnb’s data, which was organized and posted to Kaggle by user Tyler Xie, we have built a series of machine learning models to answer the question, “Which factors affect Airbnb listing prices in Sydney, Australia?” where “factors” span variables such as zip code, number of bedrooms, and beyond.

APPROACH
Since we are predicting housing prices based on various features of an Airbnb listing, our approach is Regression. This is because price is a continuous value. As such, our machine learning models include 1. KNN Regression (Donovan Muniz), 2. Linear Regression (Zheng Pen), and 3. Regression Tree (Julia Dragu).
	Before beginning our models, we explored the price distribution of our dataset2. The price distribution is skewed with a mean price of $182.95 per night.

DATA ANALYSIS
For this project the group used a dataset from Kaggle that was based on the listings of Airbnbs in Sydney Australia2 for the year of 2018. This data set consisted of  36,662 observations and 96 variables in total. Prior to running our models, Julia first cleaned the data. As stated, the dataset had 96 columns, many of which were identifying values such as host_id, which were removed as they are irrelevant to a price prediction model. In addition, there were some columns which were clearly intended for use in Airbnb global data such as city and market, which all referred only to Sydney, Australia.
We removed blank rows and imputed NA values with zeros where relevant, such as in the case of security_deposit and number of bathrooms. Finally, we encoded categorical variables using a number of methods such as one-hot encoding, dummy encoding, and feature binning. For zip code, we took the first three characters of each zip code and then used fastDummies to dummy encode the variable. Then, to select features significant to our outcome variable (price per night), we used the backwards elimination method until all predictor variables were significant and relevant to the outcome. Our final Multiple R-squared was 0.4399 and our Adjusted R-squared 0.4386.
For the first model, Donovan built a K-nearest-neighbor regression model for the airbnb data looking at price as the output variable. After running a for loop with all the possible values that K could take it was determined that a K = 1923 was the optimal K to choose for this data set. This determination of the optimal K was based on the RMSE of the KNN regression. Specifically the KNN regression with a value of K that gave the lowest RMSE value. 
Second, Zheng built a multiple linear regression model for the airbnb data. We used the backwards elimination method until all predictor variables were significant and relevant to the outcome. Through the summary of  the multiple linear regression model, the p-value of 
F-statistic is less than 0.05, indicating that the significance test is passed at the level of P=0.05, this is the regression as a whole significant. Based on the data, it appears that several factors have a statistically significant effect on Airbnb listing prices in Sydney, Australia. Some of these factors include the number of listings a host has, whether the host’s identity has been verified, and the number of people the listing can accommodate. Other significant factors include the number of bathrooms and bedrooms, the security deposit and cleaning fee amounts, and whether instant booking is available. The type of room (private or entire home) and the cancellation policy also appear to have significant effects on listing prices.
Thirdly, Julia built a Regression Tree with 21 splits, splitting the train and validation data by 70-30. Upon plotting and evaluating the complexity parameter of the model, it was determined that the complexity error plateaus at 21 splits, which we used for the model.



RESULTS
The results for the K-nearest-neighbor regression are as follows: The K value that results with the highest accuracy measures is a K value of 1923. Mean Error 0.156; Root Mean Square Error 100.49; Mean Absolute Error 69.42.
The results for the Multiple linear regression are as follows: Mean Error -0.8352; Root Mean Square Error 151.0281; Mean Absolute Error 68.6182. In this model, we omit the Mean Absolute Percentage Error, as the result is inconclusive (infinity). 
The results for the Regression Tree are as follows: Mean Error -4.1067; Root Mean Square Error 183.1683; Mean Absolute Error 68.7431. In this model, we omit the Mean Absolute Percentage Error, as the result is inconclusive (infinity). 
A summary of the results can be found below:
FIGURE 4: Results Comparison
Algorithm
ME
RMSE
MAE
KNN Regression 
K = 1923
0.156
100.49
69.42
Linear Regression
-0.8352
151.0281
68.6182
Regression Tree
-4.1067
183.1683
68.7431

INFERENCE
Some key considerations to keep in mind while drawing inferences relate to the limitations of the dataset. For example, the model’s low R-squared could have been improved by the addition of variables such as proximity to key locations like the waterfront and city center, condition/age of the property, when the property was last updated/renovated, square footage, and amenities offered. 
In addition, the Kaggle data is not current—in fact, the data is from 2018. For more accurate price predictions, the data would span all the most recent data available. With more time, it would be possible to download and clean the data straight from the InsideAirbnb initiative itself, which was last updated on December 10, 2022.
Finally, the pricing is somewhat skewed, which may cause inaccuracies in the predictions. Further analysis would need to be conducted to ensure that the skew does not affect the accuracy of the sample used for the model.
With all that being said it is clear to see that the Knn Regression model as it had the lowest RMSE measures when compared to the multiple linear regression and regression tree models and therefore the best model for predicting the price of the Airbnbs from this dataset. 

CONCLUSIONS
Regardless of the model’s limitations, the intent was to explore the feature importance and prediction accuracy of the data in relation to Airbnb listing prices in Sydney. As found in the model, Airbnb hosts can charge more according to the number of bedrooms and maximum occupancy, which, in the model, is referred to as the variable “accommodation.” In addition, if the room type is private, for example, a host can also reasonably charge more per night.
	Another conclusion which can be drawn from the model is in regards to availability: the more bookings a listing has, the more expensive a listing can afford to be. However, this observation must be taken with consideration; further analysis could be done to determine the ideal pricing by season and how much to price last-minute bookings. As seen in the Regression Tree, a listing with more bedrooms is the primary determinant in the listing’s price. This is also supported by the multiple linear regression model, as the bedroom variable has a positive significant effect on the price of an Airbnb and something that an Airbnb owner should take into account when pricing their place. These models help to outline some of the important factors that affect Airbnb prices in Sydney. However, moving forward it will be imperative to improve on these models and input even more predictor variables to retain the highest accuracy when predicting price per night in this area. 

RECOMMENDATIONS
Upon analyzing the models, the recommendations are that: (1) Airbnb hosts in Sydney, Australia take into account the number of bedrooms as they price their listings; (2) hosts keep in mind the total pricing when the security deposit is taken into account; (3) efforts should be made to increase the maximum number of occupants (“accommodates”) by adding more beds, etc; and (4) additional analyses and research should be done to determine the ideal pricing strategy in relation to availability and seasonality of the Sydney market. 
