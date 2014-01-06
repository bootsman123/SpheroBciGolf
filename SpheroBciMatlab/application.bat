set path=C:\Users\bootsman\Documents\MATLAB\Toolboxes\buffer_bci

:: Find Matlab path.
call "%path%\utilities\findMatlab.bat"

:: Start buffer.
call "%path%\dataAcq\startBuffer.bat"

:: Start signal proxy.
call "%path%\dataAcq\startSignalProxy.bat"

:: Start application buffer.
start "matlab" %matexe% -nodesktop -nosplash -minimize -singleCompThread -r "applicationBuffer;quit;"

:: Start application.
start "matlab" %matexe% -nodesktop -nosplash -minimize -singleCompThread -r "application;quit;"