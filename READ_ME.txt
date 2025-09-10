This is all the code necessary to create the figures in the manuscript:

Optimal Control of an SIR Model with Noncompliance as a Social Contagion
by Chloe Ngo, Christian Parkinson, and Weinan Wang

This was originally executes in MATLAB version 2024a, though it should
work in any relatively recent MATLAB version.

To run the code simply save all files to a common directory, navigate to 
directory and MATLAB and run the script "driver.m" - with no other changes,
this will produce the images from Figure 3 of the manuscript. To get the 
images from other figures, change which parameter file is loaded on line
29 of driver.m

All code is commented so as to (hopefully) be human readable. 

Description of files: 

driver.m  	     - the driver file where you can choose parameters and run 
            	       the forward-backward-sweep method (FBSM) to solve the 
		       optimal control problem from the manuscript. 

solveSIR.m	     - a function which solves the state ODEs from the manuscript;
		       this is used in the driver as part of the FBSM, see 
		       Algorithm 1, step (i) in the manuscript

solveAdj.m           - a function which solves the adjoint ODEs from the manuscript;
		       this is used in the driver as part of the FBSM, see 
		       Algorithm 1, step (ii) in the manuscript

computeCost.m        - a function which takes in the results of a simulation, and 
		       and evaluated the total cost incurred (i.e. computes 
		       J(x,u) from equation (3.2) in the manuscript)

plotSIR.m	     - Three plotting functions that take in the results of a		
plotControlandR0.m     simulation and produce the plots from the manuscript. 
plotSIRandControls.m   NOTE: the actual plots that come out will be slightly 
		       different than certain ones in the manuscript, since 
		       some of plots required manually changing axes, legend 
		       location, titles and other minor formatting things.

FigureXparams.mat    - MATLAB data files containing the parameter values for 
		       the different figures in the manuscript. 

