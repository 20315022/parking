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
		file parkingShapeFile <- file("../includes/test.shp");
		//file parkingShapeFile <- file("/Users/madaliou/Documents/qgis/parking/test.shp");
		file voitureImage <- image_file("../includes/data/voiture_image.png");
		//file route_shapefile <- file("../includes/lignes.shp");
		file route1_shapefile <- file("../includes/voies.shp");
		file place_shapefile <- file("../includes/place.shp");
		
		
		geometry shape <- envelope(parkingShapeFile);
		geometry shape1 <- envelope(route1_shapefile);
		
		int nombre_tour <- 90; //in degree
		int le_facteur <- 10;
		int x;
		float taille <- 2.0;
		int tense <- 500;
	    int intensity <- 2;
	    graph route1;
		
		geometry espace_libre;
		
		int nb_voiture <- 20;
		point dest1 <-{10,5};
		
		
		
		reflex NewCar when: every (tense/intensity){ 
         create Voiture number:1 {
	         location <- any_location_in(one_of(shape1));
	         //target <- any_location_in(one_of(entree));
	         but <- "Enter";
            }
         }
		
		
		init { 
			
		create Route from: route1_shapefile ;
		route1 <- as_edge_graph(Route);
		
		espace_libre <- copy(shape);
		
		create batiment from: parkingShapeFile {
			
			espace_libre <- espace_libre - (shape + taille);
		}
		
		espace_libre <- espace_libre simplification(1.0);
		
		create batiment number: 1 {
		
		} 
		create Place from: place_shapefile with: [type::string(read ("Taille"))] {
		    	
        }
		
		/*create Voiture number: 10 {
			set location <- dest1;
		} */		
		
	}
		 
		
}

species Route  {
	rgb color <- #red ;
	aspect base {
		draw shape color: color ;
	}
}


species batiment {
	
	
	aspect default {
		draw shape color: #black depth: 1;
	}
}

species name: Voiture skills: [driving]{
	
	/*aspect default {
		draw shape voitureImage;
		//draw circle(3.0) color: #yellow;*/
	//}
	
	int rayonObservation <- 5;
	float tailleVoiture <- 10.0+rnd(5.0);
	bool Garer <- false;
	//Place but <- nil;
	rgb color init: rgb('black');
	int dureeStationnement <- 0;
	int prix <- 0;
	point but <- nil;
	point target <- nil;
	
	reflex goEnter when: but="Enter" and target!=nil{
     		do goto target:target on:route1 speed:speed;
     		if(self.location=target){
     			target <- nil;	
     		
     		}
     		
     	}
	
	/*reflex patrolling{
		do action: wander amplitude:300;
	}*/
	
	aspect icon {
		draw voitureImage size: 15 color: rgb(255, 255, 250+rnd(5));
	}
	
	reflex chercherPlace when: (but = nil) {
		do goto target:target on:route1 speed:speed;
		
		//do action: wander amplitude:200;
		
		
		if (length(list (Place) where((self distance_to each) <= rayonObservation)) > 0){
			but <- first(list (Place) where((self distance_to each) <= rayonObservation) sort_by ((self distance_to each) ));
				
		}
		
		
	}
}

species Place  control:fsm{
	string type; 
	rgb color <- #gray  ;
	
	
	aspect base {
		draw shape color: color ;
	}
	
	state Free initial:true{
	}
	
	state Taken{
	}
}
		


experiment Parking type: gui {
	
	float le_cycle <- 0.04; 
	output {
		display tutoriel type: opengl {
			//species route refresh: false;
			species batiment;
			species Voiture aspect: icon;
			species Route aspect: base;
			species Place aspect: base;
			
			graphics "exit" refresh: false {
				//draw sphere(5) at: dest1 color: #black;
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