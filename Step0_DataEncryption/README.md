# Step 0. Data Encryption

The scripts in this directory provide you with tools to encrypt your patient data for analysis. They
share no dependencies with the rest of the analysis and use only standard Python 3 libraries. They 
have been designed to be run by an agent with access to the identifyable data. The agent can then
provide the encrypted patient dataset to you to perform the remaining analysis allowing you to run
the relationships extraction without having to expose identifyable patient details. 

This step is completely optional. The code will run on the identifyable patient data as well. Further,
your institution can, if they wish to, use/write their own tools for building a encrypted dataset. In
that case, we recommend reading through the following paragraphs that explain how the nammes, addresses,
and phone numbers are normalized to maximize the chances of a match. 

## 

---
Remember to always respect patient privacy.
