This is all the code necessary to create the figures in the manuscript:

**Optimal Control of an SIR Model with Noncompliance as a Social Contagion
by Chloe Ngo, Christian Parkinson, and Weinan Wang**

This was originally executed in MATLAB version 2024a, though it should
work in any relatively recent MATLAB version.

All code is commented so as to (hopefully) be human readable. 

Getting the figures from the manuscript requires manually changing the 
parameters inside the driver file.

Description of files: 

driver.m  	     - the driver file where you can choose parameters and run 
            	       the sequantial quadratic hamiltonian (SQH) method to solve the 
		               optimal control problem from the manuscript. 

solveSIR.m	     - a function which solves the state ODEs from the manuscript;
		           this is used in the driver as part of the FBSM, see 
		           Algorithm 1, step (i) in the manuscript

solveAdj.m           - a function which solves the adjoint ODEs from the manuscript;
		               this is used in the driver as part of the FBSM, see 
		               Algorithm 1, step (ii) in the manuscript

computeCost.m        - a function which takes in the results of a simulation, and 
		               and evaluated the total cost incurred 

plotSIR.m, plotControl.m, plotSIRandControls.m  	          - Three plotting functions that take in the results of a  simulation and produce the plots from the manuscript. 
  						NOTE: the actual plots that come out will be slightly 
		      		    different than certain ones in the manuscript, since 
		       		    some of plots required manually changing axes, legend 
		       		    location, titles and other minor formatting things.
