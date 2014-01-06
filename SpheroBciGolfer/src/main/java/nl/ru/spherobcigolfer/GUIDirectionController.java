package nl.ru.spherobcigolfer;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionListener;
import java.awt.geom.Line2D;

import javax.swing.JPanel;
import javax.swing.event.MouseInputListener;


public class GUIDirectionController extends JPanel implements MouseMotionListener, MouseInputListener{

	private Point lastMousepointClicked; 
	private Point lastMousepointMoved;
	private static final Point sizeOfComponent = new Point(300,300);  
	WorldModel model; 
	private int maxDuration = 2500;
	public GUIDirectionController(WorldModel model)
	{
		super();
		this.model = model; 
		
		this.setPreferredSize(new Dimension(sizeOfComponent.x,sizeOfComponent.y));
		this.addMouseListener(this);
		this.addMouseMotionListener(this);
		this.lastMousepointClicked = new Point(0,0);
		this.lastMousepointMoved = new Point(0,0);
	}
	private static final long serialVersionUID = 1L;

        @Override
	public void paint(Graphics g){
		super.paint(g);
		Graphics2D g2 = (Graphics2D) g;
		g2.drawOval(0,0,sizeOfComponent.x,sizeOfComponent.y);
		
		g2.drawLine(sizeOfComponent.x/2,sizeOfComponent.y/2,lastMousepointMoved.x, lastMousepointMoved.y);
		g2.drawLine(sizeOfComponent.x/2,sizeOfComponent.y/2,lastMousepointClicked.x, lastMousepointClicked.y);
		
		
		
	}
	@Override
	public void mouseClicked(MouseEvent arg0) {
		this.lastMousepointClicked = arg0.getPoint();
		double angle = calcRotationAngleInDegrees(new Point(sizeOfComponent.x/2,sizeOfComponent.y/2), lastMousepointClicked);
		
		model.setHeading((int)angle);
		double percent = calculateLengthOfLine(new Point(sizeOfComponent.x/2,sizeOfComponent.y/2), lastMousepointClicked);
		int duration = (int) (maxDuration*percent);
		System.out.println("angle: " + angle + " duration: " + duration + " percent: " + percent);
		model.setVelocity(100);
		/**
		 * Possibly edit this to move the baseline of the Sphero. 
		 */
		model.setDuration(duration);
		model.executeCommandOnSphero();
		repaint();
	}

	@Override
	public void mouseEntered(MouseEvent arg0) {
		
	}

	@Override
	public void mouseExited(MouseEvent arg0) {
		
	}

	@Override
	public void mousePressed(MouseEvent arg0) {
		
	}

	@Override
	public void mouseReleased(MouseEvent arg0) {
		
		
	}
	@Override
	public void mouseDragged(MouseEvent arg0) {
		
	}
	@Override
	public void mouseMoved(MouseEvent arg0) {
		this.lastMousepointMoved = arg0.getPoint();
		repaint();
	}
	
	/**
	 * Calculates the angle from centerPt to targetPt in degrees.
	 * The return should range from [0,360), rotating CLOCKWISE, 
	 * 0 and 360 degrees represents NORTH,
	 * 90 degrees represents EAST, etc...
	 *
	 * Assumes all points are in the same coordinate space.  If they are not, 
	 * you will need to call SwingUtilities.convertPointToScreen or equivalent 
	 * on all arguments before passing them  to this function.
	 *
	 * @param centerPt   Point we are rotating around.
	 * @param targetPt   Point we want to calcuate the angle to.  
	 * @return angle in degrees.  This is the angle from centerPt to targetPt.
	 */
	public static double calcRotationAngleInDegrees(Point centerPt, Point targetPt)
	{
	    // calculate the angle theta from the deltaY and deltaX values
	    // (atan2 returns radians values from [-PI,PI])
	    // 0 currently points EAST.  
	    // NOTE: By preserving Y and X param order to atan2,  we are expecting 
	    // a CLOCKWISE angle direction.  
	    double theta = Math.atan2(targetPt.y - centerPt.y, targetPt.x - centerPt.x);

	    // rotate the theta angle clockwise by 90 degrees 
	    // (this makes 0 point NORTH)
	    // NOTE: adding to an angle rotates it clockwise.  
	    // subtracting would rotate it counter-clockwise
	    theta += Math.PI/2.0;

	    // convert from radians to degrees
	    // this will give you an angle from [0->270],[-180,0]
	    double angle = Math.toDegrees(theta);

	    // convert to positive range [0-360)
	    // since we want to prevent negative angles, adjust them now.
	    // we can assume that atan2 will not return a negative value
	    // greater than one partial rotation
	    if (angle < 0) {
	        angle += 360;
	    }

	    return angle;
	}

	public double calculateLengthOfLine(Point centerPt, Point targetPt)
	{

		double deltaX = Math.abs(centerPt.x - targetPt.x);
		double deltaY = Math.abs(centerPt.y - targetPt.y);
		double hypothenusa = hypot(deltaX, deltaY);
		double maxHypo = hypot(centerPt.x/2, centerPt.x/2)*2;
		double percent = hypothenusa/maxHypo;
		System.out.println("Hypo: " + hypothenusa + " max: " + maxHypo + " percent: " + percent);
		if (hypothenusa > maxHypo)
			hypothenusa = maxHypo;
		
		return hypothenusa/maxHypo;
	}
	public static double hypot(double side1, double side2)
    {
        return ((side1 * side1) + (side2 * side2));
    }

}
