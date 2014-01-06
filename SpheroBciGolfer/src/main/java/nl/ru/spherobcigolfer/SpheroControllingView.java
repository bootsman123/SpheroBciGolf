package nl.ru.spherobcigolfer;
import java.util.Observable;
import java.util.Observer;

import nl.project.utils.BlueToothSphero;

import se.nicklasgavelin.sphero.Robot;
import se.nicklasgavelin.sphero.RobotListener;
import se.nicklasgavelin.sphero.command.CommandMessage;
import se.nicklasgavelin.sphero.exception.InvalidRobotAddressException;
import se.nicklasgavelin.sphero.exception.RobotBluetoothException;
import se.nicklasgavelin.sphero.response.InformationResponseMessage;
import se.nicklasgavelin.sphero.response.ResponseMessage;


public class SpheroControllingView implements Observer, RobotListener {
	private Robot robot;
	private BlueToothSphero ball ;
	private WorldModel model;
	public SpheroControllingView(WorldModel model) throws InvalidRobotAddressException, RobotBluetoothException{
		this.model = model ; 
		//robot.addListener(this);
		ball = new BlueToothSphero();
		ball.setHeading(0); 
		//ball.setVelocity(180);
		//ball.setDuration(2500); 
		
		//ball.move();
	}
	
	@Override
	public void update(Observable arg0, Object arg1) {
		System.out.println("Updating sphero controlling view");
		
		if(model.getShouldExecuteOnSphero()){
			ball.setHeading(model.getHeading());
			ball.setVelocity(model.getVelocity());
			ball.setDuration(model.getDuration());
			ball.move();
		}
		if(model.shouldChangeColor())
		{
			ball.setColor(model.getColor());
			ball.changeColor();
		}
		if (model.shouldExitProgram()){
			ball.disconnect();
		}
	}

	/**
	 * Robotlistener function
	 */
	@Override
	public void event(Robot arg0, EVENT_CODE arg1) {
		
	}
	/**
	 * Robotlistener function
	 */
	@Override
	public void informationResponseReceived(Robot arg0,
			InformationResponseMessage arg1) {
		
	}
	/**
	 * Robotlistener function
	 */
	@Override
	public void responseReceived(Robot arg0, ResponseMessage arg1,
			CommandMessage arg2) {
		
		
	}
}
