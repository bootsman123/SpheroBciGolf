package nl.ru.spherobciviewer;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.geom.Ellipse2D;
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
    public static final double ROTATION_CIRCLE_SIZE_FACTOR = 0.9;
    public static final int ROTATION_CIRCLE_WIDTH = 5;
        
    public static final double ARROW_RATIO = 0.9;
    
    private BufferedImage arrowImage;
    private BufferedImage curvedArrowImage;
    
    private Meter meter;
    
    /**
     * Constructor.
     * @param meter 
     */
    public DirectionMeterPanel(Meter meter)
    {
        super();
        
        this.meter = meter;
        this.meter.addListener(new MeterListener()
        {
            public void onDirectionChanged(double direction)
            {
                repaint();
            }

            public void onPowerChanged(int power)
            {
            }
        });
        
        try
        {
            this.arrowImage = ImageIO.read(this.getClass().getResourceAsStream("/images/arrow.png"));
            this.curvedArrowImage = ImageIO.read(this.getClass().getResourceAsStream("/images/curved-arrow.png"));
        }
        catch(IOException e)
        {
        }
    }
    
    @Override
    public void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        
        this.paintRotationFrame(g);
        this.paintArrow(g);
    }
    
    /**
     * Paint rotation frame, i.e. the point and the circle.
     * @param g 
     */
    private void paintRotationFrame(Graphics g)
    {
        Graphics2D g2d = (Graphics2D)g;
        int size = (this.getWidth() > this.getHeight()) ? this.getHeight() : this.getWidth();
        
        // Rotation circle.
        double rotationCirclePreferredSize = DirectionMeterPanel.ROTATION_CIRCLE_SIZE_FACTOR * size;
        
        g2d.setColor(DirectionMeterPanel.ROTATION_FRAME_COLOR);
        g2d.setStroke(new BasicStroke(DirectionMeterPanel.ROTATION_CIRCLE_WIDTH));
        g2d.draw(new Ellipse2D.Double((this.getWidth() - rotationCirclePreferredSize) / 2,
                                      (this.getHeight() - rotationCirclePreferredSize) / 2,
                                      rotationCirclePreferredSize,
                                      rotationCirclePreferredSize));
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
        double imagePreferredSize = DirectionMeterPanel.ARROW_RATIO * size;
        double imageScaleFactor = (this.arrowImage.getWidth() > this.arrowImage.getHeight()) ? imagePreferredSize / this.arrowImage.getWidth() : imagePreferredSize / this.arrowImage.getHeight();
        int imageWidth = this.arrowImage.getWidth();
        int imageHeight = this.arrowImage.getHeight();
           
        double rotationSin = Math.abs(Math.sin(this.meter.getDirection()));
        double rotationCos = Math.abs(Math.cos(this.meter.getDirection()));
        int imageNewWidth = (int)Math.floor(imageWidth * rotationCos + imageHeight * rotationSin);
        int imageNewHeight = (int)Math.floor(imageHeight * rotationCos + imageWidth * rotationSin);
        
        AffineTransform transform = new AffineTransform();
        transform.scale(imageScaleFactor, imageScaleFactor);
        transform.translate((imageNewWidth - this.arrowImage.getWidth()) / 2, (imageNewHeight - this.arrowImage.getHeight()) / 2);
        transform.rotate(this.meter.getDirection(), this.arrowImage.getWidth() / 2, this.arrowImage.getHeight() / 2);
        
        AffineTransformOp operation = new AffineTransformOp(transform, AffineTransformOp.TYPE_BILINEAR);
        BufferedImage image = operation.filter(this.arrowImage, null);

        g2d.drawImage(image, (int)((this.getWidth() - image.getWidth()) / 2), (int)((this.getHeight() - image.getHeight()) / 2), null);
    }
}


        /*
        private Point mousePoint;
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
        * 
        * 
        
        g.setColor(Color.RED);
        g.drawLine((int)(0.5 * this.getWidth()), (int)(0.5 * this.getHeight()), this.mousePoint.x, this.mousePoint.y);
        * */