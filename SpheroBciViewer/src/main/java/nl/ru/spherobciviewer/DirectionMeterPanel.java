/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package nl.ru.spherobciviewer;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.IOException;
import javax.imageio.ImageIO;
import javax.swing.JPanel;

/**
 *
 * @author bootsman
 */
public class DirectionMeterPanel extends JPanel
{
    public static final double PREFFERED_IMAGE_SIZE_OF_HEIGHT = 0.4; // In percentages.
    
    public static final int FOCUS_SIZE = 30;
    public static final Color FOCUS_COLOR = Color.red;
    
    private double rotation;
    private BufferedImage image;
    
    /**
     * Constructor.
     */
    public DirectionMeterPanel()
    {
        super();
        
        
        this.setRotation(135);
        
        try
        {
            this.image = ImageIO.read(this.getClass().getResourceAsStream("/images/arrow.png"));
        }
        catch(IOException e)
        {
        }
    }
    
    public void setRotation(double rotation)
    {
        this.rotation = rotation % 360;
    }
    
    public double getRotation()
    {
        return this.rotation;
    }
    
    @Override
    public void paintComponent(Graphics g)
    {
        super.paintComponent(g);
        
        Graphics2D g2d = (Graphics2D)g;
        
        // Draw focus.
        g2d.setColor(DirectionMeterPanel.FOCUS_COLOR);
        g2d.fillOval((this.getWidth() - DirectionMeterPanel.FOCUS_SIZE) / 2, (this.getHeight() - DirectionMeterPanel.FOCUS_SIZE) / 2, DirectionMeterPanel.FOCUS_SIZE, DirectionMeterPanel.FOCUS_SIZE);
        
        double rotationRequired = Math.toRadians(this.getRotation());
        double locationX = (this.getWidth() - image.getWidth()) / 2;
        double locationY = (this.getHeight() - image.getHeight()) / 2   ;
        AffineTransform transformRotate = AffineTransform.getRotateInstance(rotationRequired, locationX, locationY);
        AffineTransform transformScale = AffineTransform.getScaleInstance(0.5, 0.5);
        //AffineTransformOp op = new AffineTransformOp(tx, AffineTransformOp.TYPE_BILINEAR);
        transformScale.concatenate(transformRotate);

        // Drawing the rotated image at the required drawing locations
        g2d.drawImage(image, transformScale, null);
        
        //g2d.drawImage(image, op, (this.getWidth() - image.getWidth()) / 2, (this.getHeight() - image.getHeight()) / 2);
        
    }
}
