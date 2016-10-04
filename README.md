# Gender-Identification
MatLab Code used to develop a gender identification module. The module generates two GMMs of MFCCs. One for males and one for females from a set of training data (TIMIT database). The test cases are then compared to these GMMs to determine the probability of a male or female speaker.  


_________________________________________________________________
_________________________________________________________________

			PURPOSE OF CODE FILES

_________________________________________________________________

	- Important Files

1. CalculatePitch_GMM.m
	 - obtains male and female GMM from Training Data 
	 - Reguires YIN and DATA folders to run

2. Classifier_PITCH.m
	 - Final Pitch based Gender Classifier
	 - This requires the DATA and MATRICIES folders

3. Classifier_MFCC.m
	 - Final MFCC based Gender Classifier
	 - This requires DATA and VOICEBOX folders

4. Classifier_PITCHandMFCC.m
	 - Classification is done using both Pitch and MFCCs
	 - Slightly inpovered classification and computation preformance



	- Unimportant Files

1. CalculateAlternativeMFCC.m - Demonstares alternative code for calculateing MFCCs
2. CalculateVoiceboxMFCC.m    - Demonstrates calculationg of MFCCs using Voicebox
3. PlotPitchDistributions.m   - Plots pitch data histogram and GMM PDF
4. PlotPitchCDF.m             - Plots CDF of Pitch GMMs
5. PlotSingleMFCC.m           - Plots univariate MFCC GMM to display Seperability
6. PlotDoubleMFCC.m           - Plots bivariate MFCC GMM to display Seperability
7. ClassifierMFCC(Looped).m   - Same as Classifier_MFCC.m except loops code with 
				different number of components in mixture model
8. ClassifierMFCC(FixedGMM).m - Same as Classifier_MFCC excepts reads in saved GMMs 
				rather than caluclating them from stracth

_________________________________________________________________
_________________________________________________________________

			PURPOSE OF FOLDERS

_________________________________________________________________

1. DATA      - Contains addresses of TIMIT files for tets and training data
2. MATRICIES - Contains svaed GMMs
3. MFCC      - Code to calculate MFCCs of speech waveform
4. VOICEBOX  - Code to calculate MFCCs of speech waveform
5. YIN       - Code to calculate Pitch of speech Waveform
