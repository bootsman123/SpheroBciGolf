call "C:\Users\bootsman\Documents\MATLAB\Toolboxes\buffer_bci\utilities\findMatlab.bat"

:: Start buffer.
:: ...

:: Start signal process buffer.
start "matlab" %matexe% -nodesktop -nosplash -minimize -singleCompThread -r "capFile='cap_tmsi_mobita_p300';startSigProcBuffer;quit;"

:: Start application.
start "matlab" %matexe% -nodesktop -nosplash -minimize -singleCompThread -r "application;quit;"