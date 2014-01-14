package nl.ru.spherobcigolfer;
import se.nicklasgavelin.sphero.exception.InvalidRobotAddressException;
import se.nicklasgavelin.sphero.exception.RobotBluetoothException;



public class SperoControllerMain
{
    public static void main(String[] args) throws InvalidRobotAddressException, RobotBluetoothException
    {
        WorldModel model = new WorldModel();

        GUIFrame view = new GUIFrame(model);
        SpheroControllingView controller = new SpheroControllingView(model);
        
        MATLABController matlabController = (args.length > 0) ? new MATLABController(model, args[0], Integer.valueOf(args[1])) : new MATLABController(model); 

        model.addObserver(view);
        model.addObserver(controller); 
    }
}
