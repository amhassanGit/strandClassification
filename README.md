# strandClassification
Machine learning approach to the classification and curation of vectorized image data.

This is used to classify good and bad strands from Volumetric Image Data Analysis (VIDA) suite [http://www.jneurosci.org/content/29/46/14553].  After vectorization using VIDA, you can step through a subset of the strands to manually label them as 'good' or 'bad' using 01_stepThroughStrands.m.  You can then extract features relevant to those labeled strands with 02_featureExtraction.m.  FInally, you can use that labeled data to create a machine learning approach (logistic regression and AdaBoost) to automatically curate unseen data using 03_strandClassification.Rmd.
