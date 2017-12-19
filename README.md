# Cards Against Humanity Weighting
In 2017, Cards Against Humanity (CAH) published data from several dual framed nationally representative telephone surveys. The data from their surveys can be found [here](https://thepulseofthenation.com/#future).

Traditional polling data usually has corresponding survey weights to adjust for sampling design and nonresponse bias. These weights were not available as of writing this program, so to improve the representativeness of the data, I calculated weights that post-stratify to the 2016 Census Estimates of the adult US population based on Age, Race and Gender.

This program creates both population weights (*pop_weight*) and scaled weights (*scaled_weight*) and outputs this into a CSV file. Since there are no unique IDs, weights are in order they are found in the raw data. This assume, the data provided by CAH remains the same as the data I used to create these weights (i.e., in the same order).


