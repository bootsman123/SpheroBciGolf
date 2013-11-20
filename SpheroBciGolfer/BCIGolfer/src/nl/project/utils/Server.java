package nl.project.utils;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.SocketException;


public class Server {
	
	private DatagramSocket skt;
	private int portServer;
	private int portClient = 0;
	private InetAddress ipClient = null;
	
	public Server(int portServer){
		this.portServer = portServer;
		initConnection (portServer);
	}
	
	public void initConnection(int portServer){
		try {
			skt = new DatagramSocket(portServer);
		} catch (SocketException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if(!skt.isClosed())
		{
			System.out.println("Server socket is open at port: "+portServer);
		}
		String initString = reveiveString();
//		System.out.println("Received string from client: "+initString);
		if(initString.equals("MatLabSpeaking")){
			System.out.println("MatLab client is found at: " + ipClient.toString() +" (port: "+portClient+")");
			System.out.println("Sending test message to MatLab client..");
			sendData("JavaSpeaking");
			System.out.println("Server is ready to send/recieve messages.");
		}
//		System.out.println("Client ip: " + ipClient.toString() +"\t Client port: "+portClient);
	}
	
	public String reveiveString(){
		byte[] receiveData = new byte[1024];
		while(true){
			DatagramPacket receivePacket = new DatagramPacket(receiveData, receiveData.length);
			try {
				skt.receive(receivePacket);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			String message = new String( receivePacket.getData(), 0, receivePacket.getLength() );
//			System.out.println("Received message: "+message);
			if(portClient == 0){
				ipClient = receivePacket.getAddress();
				portClient = receivePacket.getPort();
			}
			return message;
		}
	}
	
	public void sendData(String message){
		byte[] sendData = new byte[1024];
			sendData = message.getBytes();
//			System.out.println("Sending message: "+message);
			DatagramPacket sendPacket =
					new DatagramPacket(sendData, sendData.length, ipClient, portClient);
			try {
				skt.send(sendPacket);
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
	}
	
	public void closeSocket(){
		System.out.println("Server socket at port " + skt.getPort() + " will now close");
		skt.close();
	}
}

