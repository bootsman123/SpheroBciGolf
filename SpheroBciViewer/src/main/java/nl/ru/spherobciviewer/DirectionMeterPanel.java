package nl.ru.spherobciviewer;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionListener;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.swing.JPanel;

/**
 * Direcion meter panel.
 * @author Bas Bootsma
 */
public class DirectionMeterPanel extends JPanel
{
    public static final Color ROTATION_FRAME_COLOR = Color.black;
    public static final double ROTATION_POINT_SIZE_FACTOR = 0.05;
    public static final double ROTATION_CIRCLE_SIZE_FACTOR = 0.9;
    public static final int ROTATION_CIRCLE_WIDTH = 5;
        
    public static final double ARROW_RATIO = 0.4;
    
    private double rotation;
    private BufferedImage arrowImage;
    private BufferedImage curvedArrowImage;
    
    private Point mousePoint;
    
    /**
     * Constructor.
     */
    public DirectionMeterPanel()
    {
        super();
        
        this.mousePoint = new Point();
        
        this.addMouseMotionListener(new MouseMotionListener()
        {
            public void mouseDragged(MouseEvent e)
            {
            }

            public void mouseMoved(MouseEvent e)
            {
                int deltaX = Math.round(e.getX() - getWidth() / 2);
                int deltaY = Math.round(e.getY() - getHeight() / 2);
                
                setRotation(Math.atan2(deltaY, deltaX));
                mousePoint = e.getPoint();
                repaint();
            }
        });
        
        this.setRotation(0);
        
        try
        {
            this.arrowImage = ImageIO.read(this.getClass().getResourceAsStream("/images/arrow.png"));
            this.curvedArrowImage = ImageIO.read(this.getClass().getResourceAsStream("/images/curved-arrow.png"));
        }
        catch(IOException e)
        {
        }
    }
    
    /**
     * Set the rotation in radians of the arrow.
     * @param rotation 
     */
    public void setRotation(double rotation)
    {
        this.rotation = rotation;
    }
    
    /**
     * Get the rotation in radians of the arrow.
     * @return 
     */
    public double getRotation()
    {
        return this.rotation;
    }
    
    @Override
    public void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        
        this.paintRotationFrame(g);
        this.paintArrow(g);
        
        g.setColor(Color.RED);
        g.drawLine((int)(0.5 * this.getWidth()), (int)(0.5 * this.getHeight()), this.mousePoint.x, this.mousePoint.y);
    }
    
    /**
     * Paint rotation frame, i.e. the point and the circle.
     * @param g 
     */
    private void paintRotationFrame(Graphics g)
    {
        Graphics2D g2d = (Graphics2D)g;
        int size = (this.getWidth() > this.getHeight()) ? this.getHeight() : this.getWidth();
        
        // Rotation point.
        double rotationPointPreferredSize = DirectionMeterPanel.ROTATION_POINT_SIZE_FACTOR * size;
        
        g2d.setColor(DirectionMeterPanel.ROTATION_FRAME_COLOR);
        g2d.fillOval((int)((this.getWidth() - rotationPointPreferredSize) / 2), (int)((this.getHeight() - rotationPointPreferredSize) / 2), (int)rotationPointPreferredSize, (int)rotationPointPreferredSize);
        
        // Rotation circle.
        double rotationCirclePreferredSize = DirectionMeterPanel.ROTATION_CIRCLE_SIZE_FACTOR * size;
        
        g2d.setColor(DirectionMeterPanel.ROTATION_FRAME_COLOR);
        g2d.setStroke(new BasicStroke(DirectionMeterPanel.ROTATION_CIRCLE_WIDTH));
        g2d.drawOval((int)((this.getWidth() - rotationCirclePreferredSize) / 2), (int)((this.getHeight() - rotationCirclePreferredSize) / 2), (int)rotationCirclePreferredSize, (int)rotationCirclePreferredSize);
    }
    
    /**
     * Paint arrow.
     * @param g 
     * http://stackoverflow.com/questions/2676719/calculating-the-angle-between-the-line-defined-by-two-points
     */
    private void paintArrow(Graphics g)
    {
        Graphics2D g2d = (Graphics2D)g;
        int size = (this.getWidth() > this.getHeight()) ? this.getHeight() : this.getWidth();
        
        // Arrow.
        double preferredSize = DirectionMeterPanel.ARROW_RATIO * size;
        double scaleFactor = (this.arrowImage.getWidth() > this.arrowImage.getHeight()) ? preferredSize / this.arrowImage.getWidth() : preferredSize / this.arrowImage.getHeight();

        AffineTransform transform = new AffineTransform();
        transform.scale(scaleFactor, scaleFactor);
        //transform.translate((this.getWidth() - this.arrowImage.getWidth()) / 2, (this.getHeight() - this.arrowImage.getHeight()) / 2);
        transform.rotate(this.getRotation(), this.arrowImage.getWidth() / 2, this.arrowImage.getHeight() / 2);
        
        AffineTransformOp operation = new AffineTransformOp(transform, AffineTransformOp.TYPE_BILINEAR);
        BufferedImage image = operation.filter(this.arrowImage, null);

        //double rotationPointX = (this.getWidth() - image.getWidth()) / 2;
        //double rotationPointY = (this.getHeight() - image.getHeight()) / 2;

        //g2d.drawImage(image, (int)rotationPointX, (int)rotationPointY, null);
        g2d.drawImage(image, 300, 300, null);
    }
}
