package nl.ru.spherobciviewer.buffer;

import nl.fcdonders.fieldtrip.BufferEvent;

/**
 *
 * @author bootsman
 */
public interface BufferEventListener
{
    public void onReceived(BufferEvent event);
}