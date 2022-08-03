/**
* Name: Parking
* Based on the internal empty template. 
* Author: madaliou
* Tags: 
*/


model Parking

/* Insert your model definition here */

/* Insert your model definition here */

global{
		file parkingShapeFile <- file("../includes/pk.shp");
		file voitureImage <- image_file("../includes/data/voiture_image.png");
		geometry shape <- envelope(parkingShapeFile);
		int nombre_tour <- 90; //in degree
		int le_facteur <- 10;
		int x;
		float taille <- 2.0;
		
		geometry espace_libre;
		
		int nb_voiture <- 20;
		
		init { 
		
		espace_libre <- copy(shape);
		
		create batiment from: parkingShapeFile {
			
			espace_libre <- espace_libre - (shape + taille);
		}
		
		espace_libre <- espace_libre simplification(1.0);
		
		create batiment number: 1 {
		
		} 
		
		create voiture number: 10 {
		
		} 
	}
		 
		
}


species batiment {
	
	
	aspect default {
		draw shape color: #black depth: 1;
	}
}

species name: voiture skills: [driving]{
	/*aspect default {
		draw shape voitureImage;
		//draw circle(3.0) color: #yellow;*/
	//}
	
	reflex patrolling{
		do action: wander amplitude:300;
	}
	
	aspect icon {
		draw voitureImage size: 15 color: rgb(255, 255, 250+rnd(5));
	}
}

		


experiment Parking type: gui {
	
	float le_cycle <- 0.04; 
	output {
		display tutoriel type: opengl {
			//species route refresh: false;
			species batiment;
			species voiture aspect: icon;
			
			graphics "exit" refresh: false {
				/* 
				draw sphere(3) at: dest_1 color: #red;	
				draw sphere(3) at: dest_2 color: #red;	
				draw sphere(3) at: dest_3 color: #red;	
				draw sphere(3) at: dest_4 color: #red;
				
				draw sphere(3) at: init_1 color: #blue;	
				draw sphere(3) at: init_2 color: #blue;	
				draw sphere(3) at: init_3 color: #blue;	
				draw sphere(3) at: init_4 color: #blue;	*/
			}
		}
	}
}