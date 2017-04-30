# Learning of Stochastic Portfolio Selection Models for Quarterly Asset Rebalancing on the S&P 500

## Abstract
We consider the problem of developing a flexible framework for analyzing portfolio behavior and equity market structure. This is important in a variety of problem settings where investment management practitioners wish to learn an optimal portfolio selection strategy. One approach to this is to use stochastic methods that attempt to explain observable phenomena that take place in equity markets without the strong normative assumptions of the Modern Portfolio Theory of Dynamic Asset Pricing (DAP) introduced by Harry Markowitz. However, the descriptive methods of Robert Fernholz’ Stochastic Portfolio Theory (SPT) are not concerned with expected utility maximization. We describe a method for “unifying” several second-order stochastic dominance models that achieve state-of-the-art performance not only with each other but also with classical portfolio theory methods. Namely, we show that a neural network can be trained to identify the optimal portfolio selection method, given certain descriptors of a money-market’s economic condition and the trailing performance of all strategies under consideration. We show our machine learning approach combines portfolio selection models in such that existing individual strategies are out performed while assuming less risk.

To read our full paper, please see [SPT_Learning.pdf](SPT_Learning.pdf).

## Structure 
1. *model_master_script.m*
	* Master script for running and testing the model, calling helper functions 2-6 (detailed below).
	* Use *targetAlpha* to set the risk-averseness of the strategy to train.
	* Run this script to evaluate performance!
2. *calc_features.m*
	* Script for calculating and returning the predictor variables.
3. *calc_r_squared.m*
	* Calculates the statistical measure of how close the data are to the fitted regression line
4. *calc_response.m*
	* Calculates the response variable in accordance with the user's weekly alpha target.
5. *calc_returns.m*
	* Calculates the returns of all models under consideration.
6. *train_neural_net.m*
	* Script to train and initialize the neural network.

## Built With

* [MATLAB 2017a](https://www.mathworks.com/products/matlab/whatsnew.html) - The language used
* [Neural Network Toolbox](https://www.mathworks.com/products/matlab/whatsnew.html) - The toolbox used to train neural networks

## License
This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## Authors
* **Brett Whitford**  - OSU Department of Electrical and Computer Engineering - [github](https://github.com/brett-whitford)
* **Noah H. Bayindirli**  - OSU Department of Electrical and Computer Engineering - [github](https://github.com/nbayindirli)
