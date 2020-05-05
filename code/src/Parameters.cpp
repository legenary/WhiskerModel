
#include "Parameters.hpp"

// set default parameter values
Parameters::Parameters(){
	// input arguments for simulator
	DEBUG = 0;			// enable debug mode
	TIME_STEP = 0.01;// set time step, this is related to output video's FPS
	NUM_STEP_INT = 100;	// set internal time step
	TIME_STOP = 5.;		// set overall simulation time
    PRINT = 0;			// set to PRINT=1 to kinematics/dynamics realtime, set to PRINT = 2 to print simulation time
	SAVE = 1;			// save results to csv file
	SAVE_VIDEO = 1;		// save video when running main_opengl.cpp

	// collision object type
	OBJECT = 4;			// 0: nothing
						// 1: peg
						// 2: wall
						// 3: create object from 3D scan
						// 4: a prism

	// specify whisker configuration parameters
	WHISKER_NAMES = {"LA0", "RA0", "LC1", "RC1"}; // select whiskers to simulate
    WHISKER_INDEX = {31, 0, 42, 11};			  // indices for these whiskers based on a 30-whisker indexing plan
	BLOW = 1;				// increase whisker diameter for better visualization (will affect dynamics!!)
	NO_CURVATURE = 0;		// disable curvature
	NO_MASS = 0;			// disable mass of bodies
	NO_WHISKERS = 0;		// disable whiskers
	NUM_LINKS = 20;			// set number of links
	RHO_BASE = 1260.0;		// set densidy at whisker base
	RHO_TIP = 1690.0;		// set density at whisker tip
	E = 5e9;				// set young's modulus (GPa) at whisker base
	ZETA = 0.32;			// set damping coefficient zeta at whisker base

	// enable/disable whisking mode for added whiskers
	// Note: the whisking trajectory is pre-specified by user.
	ACTIVE = 1;				
	dir_param_bp_angles = ACTIVE?"../data/whisking_init_angle_sample.csv":"../data/param_bp_angles.csv";
	// dir_param_bp_angles = ACTIVE?"../data/param_angles.csv":"../data/param_angles.csv";

	// enable/disable exploring mode for rat head
	// Note: the head trajectory is 
	EXPLORING = 0;

	// parameters for peg (OBJECT = 1)
	PEG_LOC = btVector3(10, 10, 0);
	PEG_SPEED = 10;	

	// rat position/orientation parameters
	RATHEAD_LOC = {0,0,0}; 			// set position of rathead
	RATHEAD_ORIENT = {0,0,0}; 		// set initial heading of rathead

	// camera parameters for visualization
	CPOS = btVector3(0, 20, 20);	// set camera pos relative to rathead
	CDIST=50;						// set camera distance
	CPITCH=-89;						// set camera pitch
	CYAW=0;							// set camera yaw

	// input/output file paths
	dir_out = "../output/test";
	file_video = "../output/video_test.mp4";
	file_env = "../data/3D_data/rat_habitat/drain_pipe.obj";
	file_prism = "../../../cube1mm.obj";

}

// create a vector with same value
std::vector<float> get_vector(float value, int N){
	std::vector<float> vect;
	for(int i=0; i<N; i++){
		vect.push_back(value);
	}
	return vect;
}

// convert string to float vector - not used I think
std::vector<float> stringToFloatVect(std::vector<std::string> vect_string){
	std::string::size_type sz;
	std::vector<float> vect_float;
	for(int i=0; i<vect_string.size(); i++){
		vect_float.push_back(std::stof(vect_string[i],&sz));
	}
	return vect_float;
}

