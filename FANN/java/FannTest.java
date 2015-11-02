package com.googlecode.fannj;

//package com.sun;

import com.sun.jna.Native;

import java.io.IOException;

import java.io.File;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.List;


public class FannTest
{
    public static void main(String args[])
{
	System.setProperty("jna.library.path" , "jna-4.1.01.jar");
	System.setProperty("jna.library.path" , "fannj-0.6.jar");

	List<Layer> layerList = new ArrayList<Layer>();
	layerList.add(Layer.create(3, ActivationFunction.FANN_SIGMOID_SYMMETRIC, 0.01f));
	layerList.add(Layer.create(16, ActivationFunction.FANN_SIGMOID_SYMMETRIC, 0.01f));
	layerList.add(Layer.create(4, ActivationFunction.FANN_SIGMOID_SYMMETRIC, 0.01f));
	Fann fann = new Fann(layerList);



	//Fann fann = new Fann("/tmp/MySunSpots.net" );

	/*	
		Fann fann = new Fann("MySunSpots.net" );

		float[] inputs = new float[]{0.686470295f, 0.749375936f, 0.555167249f, 0.816774838f, 0.767848228f, 0.60908637f};
		float[] outputs = fann.run( inputs );
		fann.close();

		for (float f : outputs) 
		{
		System.out.print(f + ",");
		System.out.println("hello");
		}
	/*

	System.out.println( System.getProperty("jna.library.path") ); //maybe the path is malformed
	File file = new File(System.getProperty("jna.library.path") + "fannfloat.dll");
	System.out.println("Is the dll file there:" + file.exists());
	System.load(file.getAbsolutePath());*/
    }
}
