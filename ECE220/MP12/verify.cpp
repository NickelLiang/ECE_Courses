#include "check.hpp"


int main(int argc, char *argv[]){
	if(argc != 2) {
    	cerr << "USAGE: ./verify_mp12 input.txt" << endl; 
    	return -1;
  	}
	cout << " \n\n ------------------- Begin Verifying MP12 ---------------------" << endl;
	int name_p = CheckGetName();
	int rec_p = CheckRec();
	int cir_p = CheckCircle();	
	int s_p = CheckSphere();
	int rp_p = CheckRectprism();
	int ma_p = CheckMaxArea(argv[1]);
	int mv_p = CheckMaxVolume(argv[1]);
	//int create_p = CheckCreateshapes(argv[1]);
	cout << "getName() " << name_p << "/16" << endl;	
	cout << "Rectangle: " << rec_p << "/16" << endl;
	cout << "Circle: " << cir_p << "/16" << endl;
	cout << "Sphere: " << s_p << "/16" << endl;
	cout << "RectPrism: " << rp_p << "/16" << endl;
	//cout << "CreateShape(): " << create_p << "/16/" << endl;
	cout << "MaxArea(): " << ma_p << "/10" << endl;
	cout << "MaxVolume(): " << mv_p << "/10" << endl;
	cout << "Your total Socre for MP12: " << mv_p + ma_p + name_p + rec_p + cir_p + s_p + rp_p << "/100" << endl;
	cout << "-------------------- End Verifying MP12 ----------------------" << endl << endl << endl;
	
	return 0;
}
