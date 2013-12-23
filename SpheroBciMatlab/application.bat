call "C:\Users\bootsman\Documents\MATLAB\Toolboxes\buffer_bci\utilities\findMatlab.bat"

:: Start buffer.
:: ...

:: Start application buffer.
start "matlab" %matexe% -nodesktop -nosplash -minimize -singleCompThread -r "applicationBuffer;quit;"

:: Start application.
start "matlab" %matexe% -nodesktop -nosplash -minimize -singleCompThread -r "application;quit;"