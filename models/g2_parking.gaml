/**
* Name: MyParking
* Based on the internal empty template. 
* Author: madaliou
* Tags: 
*/


model g2_parking

/* Insert your model definition here */

global{
	int nbrDeVoiture <- 2 parameter: 'Nombre de voitures après un temps' category: 'Voiture' min:2 max:10;
	
	file parkingShapeFile <- file("../includes/test.shp");
	file voitureImage <- image_file("../includes/data/voiture_rotate.png");
	file route1_shapefile <- file("../includes/oneRoad.shp");
	file route2_shapefile <- file("../includes/ligneRetour.shp");
	file place_shapefile <- file("../includes/places.shp");
	file controlPoint <- image_file("../includes/data/border1.png");
	//file pointControl_shapefile <- file("../includes/controlPoint.shp");
	
	geometry shape <- envelope(parkingShapeFile);
	geometry shape1 <- envelope(route1_shapefile);
	int temps <- 500;
	graph route1;
    graph route2;
    int placesDisponibles <- 12;
    int montantTotal <- 0;
    point pointDEntree <-{10,0};
	point pointDeSortie <-{35,-10};
	float hour <- 3600 #s;
	int yield <- 0;
	
	init { 
			create Route from: route1_shapefile ;
			route1 <- as_edge_graph(Route);
			
			create Route from: route2_shapefile;
			route2 <- as_edge_graph(Route);
		
			create Place from: place_shapefile with: [type::int(read ("Poids"))] {
				//write location;
			}
			
			create PointDeControl number:1 {}
		    	
		create Parking from: parkingShapeFile {
			
		}
				
		}
		reflex caclul when:every(hour){
         	yield <- montantTotal;
         	//availablePlaceTo <- availablePlaceTo+ availablePlace;
         	montantTotal <- 0;
         }
		
}
species Parking {
	
	aspect default {
		draw shape color: #black depth: 0;
	}
}


species Route  {
	rgb color <- #green ;
	aspect base {
		draw shape color: color ;
	}
}

species Place {
	int type; 
	rgb color <- #gray  ;
	bool occupe init: false;
	
	aspect base {
		draw shape color: color ;
	}
	
}


species name: Voiture skills: [moving]{
	
	rgb color init:rgb(rnd(255), rnd(255), 100+rnd(155));
	point target <- nil;
	Place but init: nil;
	//int size init: 5+rnd(5);
	int size init: 10+rnd(8);
	int pauseTime <- 800 + rnd(300);
	int amount <- 0;
    int count <- 0;
    
    //Reflexe qui permet de diriger la voiture vers le point de stationnement adéquat
	reflex Entrer when: target!=nil {
		
		list neighbour1 <- list(Place) where(each.occupe=false and each.type>=self.size) group_by ((each.type));
		list<Place> neighbour;
		if(length(neighbour1) > 0){
			neighbour <- neighbour1 at 0 sort_by (self distance_to each);
		}
		
		if(length(neighbour) > 0){
			target <- first(neighbour);
			if(first(neighbour).occupe = false){
				do goto target:first(neighbour) on:route1;
	 			but <- target;
			}
	 		
	 	if(location = target.location){
	 			
	 			ask but{
	 				set occupe <- true;
	 				myself.target <- nil;
	 			}
	 			placesDisponibles <- placesDisponibles - 1;
	 			write('monitoring');
	 			write(placesDisponibles);
	 			
	 		}
		}
		else{
			do goto target:pointDeSortie on:route2;
		}
 		
	}
	
	 //Reflexe qui permet à la voiture de repartir du parking après un temps donné
     reflex SortirParking {
     	count <- count+1;
		if(count > pauseTime){
     		do goto target: pointDeSortie on:route2;
     		
 			ask but{
 				set occupe <- false;
 				
 			}
 			placesDisponibles <- placesDisponibles + 1;
	 		write(placesDisponibles);
     		
     		if(self.location = pointDeSortie){
     			do die;
     		}
     	}
     }
	
	reflex Payer when: count > pauseTime {
		
		let montantAPayer;
		ask but{
			
			montantAPayer <- type*myself.pauseTime*myself.size;
		}
		//montantAPayer <- size*pauseTime;
		amount <- montantAPayer;
     	montantTotal <- montantTotal+amount;
     	write(montantTotal);
	}
	
	aspect icon {
		draw voitureImage size: size color: color rotate:heading;
	}
	
}
 

species PointDeControl{
	
	int size <- 30;
	point location init: pointDeSortie;
	
	aspect icon {
		draw controlPoint size: size color: color;
	}
	
	reflex NewCarAfterCheck when: every (temps/nbrDeVoiture) and length(list(Place) where(each.occupe=false)) > 0{ 
		
		list neighbour <- list(Place) where(each.occupe=false);
		if(length(neighbour) > 0){
         	create Voiture number:1 {
         	location <- pointDEntree;
         	target <-first(neighbour);
	        }
         }
         
        }
	
}

experiment g2_parking type: gui {
	
	output {
		display MyParking type: opengl {
			species Parking;
			//species Route aspect: base;
			species Place aspect: base;
			species Voiture aspect: icon;
			species PointDeControl aspect:icon;
		}
		display My_chart refresh:every(3600#s){
         chart "diagram" type:series size: {1, 0.5} position: {0, 0}{
            data "Revenu par heure" value:montantTotal style: line color: #green ;
   
	        }    
         }
	}
}
