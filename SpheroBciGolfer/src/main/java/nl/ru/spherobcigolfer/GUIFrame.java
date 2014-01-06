package nl.ru.spherobcigolfer;
import java.awt.Color;
import java.awt.Container;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Observable;
import java.util.Observer;

import javax.swing.JButton;
import javax.swing.JColorChooser;
import javax.swing.JFrame;
import javax.swing.JTextField;
import javax.swing.event.ChangeEvent;
import javax.swing.event.ChangeListener;

import se.nicklasgavelin.sphero.exception.InvalidRobotAddressException;
import se.nicklasgavelin.sphero.exception.RobotBluetoothException;


public class GUIFrame extends JFrame implements ActionListener, Observer, ChangeListener{
	private static final long serialVersionUID = 1L;

	JTextField headingField;
	JTextField velocityField;
	JTextField durationField;
	JButton exitButton ;
	JButton startMovingButton ;
	WorldModel model;
	JColorChooser colorChooser; 
	GUIDirectionController directionController;
	public GUIFrame(WorldModel model) throws InvalidRobotAddressException, RobotBluetoothException{
		super("Sphero controller");
		this.model = model ; 
		
		Container contentPane = getContentPane();
		contentPane.setLayout(new FlowLayout());
		
		exitButton = new JButton("Exit");
		startMovingButton = new JButton("Start moving");
		headingField = new JTextField("Heading");
		velocityField = new JTextField("velocity");
		durationField = new JTextField("duration");
		colorChooser = new JColorChooser();
		directionController = new GUIDirectionController(model);
		
		exitButton.addActionListener(this);
		startMovingButton.addActionListener(this);
		headingField.addActionListener(this);
		velocityField.addActionListener(this);
		durationField.addActionListener(this);
		colorChooser.getSelectionModel().addChangeListener(this);
		
		
		contentPane.add(exitButton);
		contentPane.add(startMovingButton);
		contentPane.add(headingField);
		contentPane.add(velocityField);
		contentPane.add(durationField);
		contentPane.add(colorChooser);
		contentPane.add(directionController);
		
		this.setVisible(true);
		this.pack();
		addWindowListener(new java.awt.event.WindowAdapter() {
            public void windowClosing(java.awt.event.WindowEvent e) {
                //Exit program and stop the sphero
            	
            	System.exit(0);
            }
        });
		
	
	}

	
	public void stateChanged(ChangeEvent e) {
		Color c = colorChooser.getColor();
    	model.setColor(c);
	}

	@Override
	public void actionPerformed(ActionEvent e) {
		Object o = e.getSource();
        if (o instanceof JTextField) {
            JTextField textField = (JTextField)o;
            
            if (textField == headingField)
            {
            	System.out.println("Heading field");
            	try{
            		Integer heading = Integer.parseInt(textField.getText());
            		model.setHeading(heading);
            	}
            	catch(Exception exception){
            		exception.printStackTrace();
            	}
            }
            else if (textField == velocityField){
            	try{
            		Integer velocity = Integer.parseInt(textField.getText());
            		model.setVelocity(velocity);
            	}
            	catch(Exception exception){
            		exception.printStackTrace();
            	}
            }
            else if (textField == durationField){
            	try{
            		Integer duration = Integer.parseInt(textField.getText());
            		model.setDuration(duration);
            	}
            	catch(Exception exception){
            		exception.printStackTrace();
            	}
            }
            else{
            	System.err.println("Unknown field");
            }
        }
        if (o instanceof JButton) {
            JButton button = (JButton)o;
            
            if (button== exitButton)
            {
            	System.out.println("Trying to exit");
            	model.exitProgram();
            }
            else if (button == startMovingButton){
            	Color c = colorChooser.getColor();
            	model.setColor(c);
            	model.executeCommandOnSphero();
            	System.out.println("Starting moving");
            }
            else{
            	System.err.println("Unknown button");
            }
        }
		System.out.println(e.getActionCommand());
	}


	


	@Override
	public void update(Observable o, Object arg) {
		this.velocityField.setText(""+model.getVelocity());
		this.headingField.setText(""+model.getHeading());
		this.durationField.setText(""+model.getDuration());
	}
	
}
