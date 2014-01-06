package nl.ru.spherobcigolfer;
import se.nicklasgavelin.sphero.exception.InvalidRobotAddressException;
import se.nicklasgavelin.sphero.exception.RobotBluetoothException;



public class SperoControllerMain {
	public static void main(String[] args) throws InvalidRobotAddressException, RobotBluetoothException{
		WorldModel model = new WorldModel();
		
		GUIFrame view = new GUIFrame(model); //View of the program
		
		SpheroControllingView controller = new SpheroControllingView(model); //View of the sphero
                
		MATLABController matlabController = new MATLABController(model);
		
		model.addObserver(view);
		model.addObserver(controller);
		//model.addObserver(matlabController);
		
		
		
		  
	}


}
