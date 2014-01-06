package nl.project.utils;
import se.nicklasgavelin.sphero.Robot;
import se.nicklasgavelin.sphero.RobotListener;
import se.nicklasgavelin.sphero.command.CommandMessage;
import se.nicklasgavelin.sphero.response.InformationResponseMessage;
import se.nicklasgavelin.sphero.response.ResponseMessage;


public class SpheroListener implements RobotListener{

	@Override
	public void event(Robot arg0, EVENT_CODE arg1) {
		System.out.println("SpheroListener.event: Event");
		
	}

	@Override
	public void informationResponseReceived(Robot arg0,
			InformationResponseMessage arg1) {
		System.out.println("SpheroListener.infoRespnse:Received InformationResponse");
		
	}

	@Override
	public void responseReceived(Robot arg0, ResponseMessage arg1,
			CommandMessage arg2) {
		System.out.println("SpheroListener.response: Received Response");
		
	}

}
