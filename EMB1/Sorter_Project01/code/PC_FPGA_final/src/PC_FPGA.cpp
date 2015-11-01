#include <boost/asio.hpp>
#include <iostream>
#include <sstream>
#include <string>
#include <math.h>



using namespace boost;
using namespace std;


//////////////////////////////////////////////////////////////////////////////
//Function to write data in FPGA
void write_FPGA(asio::serial_port &port, string &command, string &data)
{
  
  string full_command = command + " " + data;

  //Write the command to access to memory
  asio::write(port, asio::buffer(full_command.c_str(), full_command.size()));

}


//Function to read data in FPGA
string read_FPGA(asio::serial_port &port, string &command)
{

  char aux_char[9] = {};
  //Write the command to access to memory
  asio::write(port, asio::buffer(command.c_str(), command.size()));

  //Read the memory set and save it in char*
  asio::read(port, asio::buffer(aux_char,9));

  string data = aux_char;

  return data;
}


//////////////////////////////////////////////////////////////////////////////
// Hexadecimal string to integer converter
int HEX_2_int(string data)
{
  int value = 0;
  stringstream sstr;

  sstr << data;
  sstr >> hex >> data;

  for(int i=0; i<=8; i++)
  {
     char c = data[i];
     if(c >= '0' && c <= '9')
     { value = value*16 + (c-'0');
     }
     else if(c >= 'a' && c <= 'f')
     { value = value*16 + (c-'a'+10);
     }

  }
  
  return value;

}


//////////////////////////////////////////////////////////////////////////////
//	Treshold level configuration function.
void Setup_Tresholds(asio::serial_port &port, int* t_red, int* t_green, int* t_blue){

	stringstream sst_red_min, sst_red_max, sst_green_min, sst_green_max, sst_blue_min, sst_blue_max;

	string tstr_red_min, tstr_red_max, tstr_green_min, tstr_green_max, tstr_blue_min, tstr_blue_max;

	//////////////////////////////////////////////////////////////////////
	//Convert the integers into Hex characters

	int total;

	total = (t_red[0])*(pow(2,20)) + (t_red[2])*(pow(2,10)) + t_red[4];
	if(t_red[0] < 256)
		sst_red_min << 0;
	sst_red_min << hex << total;

	total = (t_green[0])*(pow(2,20)) + (t_green[2])*(pow(2,10)) + t_green[4];
	if(t_green[0] < 256)
		sst_green_min << 0;
	sst_green_min << hex << total;


	total = (t_blue[0])*(pow(2,20)) + (t_blue[2])*(pow(2,10)) + t_blue[4];
	if(t_blue[0] < 256)
		sst_blue_min << 0;
	sst_blue_min << hex << total;


	total = (t_red[1])*(pow(2,20)) + (t_red[3])*(pow(2,10)) + t_red[5];
	if(t_red[1] < 256)
		sst_red_max << 0;
	sst_red_max << hex << total;


	total = (t_green[1])*(pow(2,20)) + (t_green[3])*(pow(2,10)) + t_green[5];
	if(t_green[1] < 256)
		sst_green_max << 0;
	sst_green_max << hex << total;


	total = (t_blue[1])*(pow(2,20)) + (t_blue[3])*(pow(2,10)) + t_blue[5];
	if(t_blue[1] < 256)
		sst_blue_max << 0;
	sst_blue_max << hex << total;

	//////////////////////////////////////////////////////////////////////
	// Write the values in FPGA
	tstr_red_min = sst_red_min.str();
	tstr_green_min = sst_green_min.str();
	tstr_blue_min = sst_blue_min.str();
	tstr_red_max = sst_red_max.str();
	tstr_green_max = sst_green_max.str();
	tstr_blue_max = sst_blue_max.str();

	string st1 = "w14";
	string st2 = "w15";
	string st3 = "w16";
	string st4 = "w17";
	string st5 = "w24";
	string st6 = "w25";

	write_FPGA(port, st1, tstr_red_min);
	write_FPGA(port, st2, tstr_red_max);
	write_FPGA(port, st3, tstr_green_min);
	write_FPGA(port, st4, tstr_green_max);
	write_FPGA(port, st5, tstr_blue_min);
	write_FPGA(port, st6, tstr_blue_max);

}



//////////////////////////////////////////////////////////////////////////////
int main()
{
  string command = "r01";
  string portname;
  string data_;
  string inputdata;



  ///////////////////////////////////////////////////////////////////////////////////////
  // 	USB port configuration

  cout << "Select portname: " << endl;
  cin >> portname;

  //portname = "/dev/ttyUSB" + portname;
  asio::io_service io;
  asio::serial_port port( io );

  port.open(portname);
  port.set_option(asio::serial_port_base::baud_rate(115200));
  port.set_option(asio::serial_port_base::flow_control(asio::serial_port_base::flow_control::none));
  port.set_option(asio::serial_port_base::parity(asio::serial_port_base::parity::none));
  port.set_option(asio::serial_port_base::stop_bits(asio::serial_port_base::stop_bits::one));
  port.set_option(asio::serial_port_base::character_size(8));


//////////////////////////////////////////////////////////////////////////////////////
//Motor configuration

string pos1 = "w34";
string pos2 = "w35";
string pos3 = "w36";
string init = "w37";

string mot_pos1 = "000000c0";
string mot_pos2 = "00000136";
string mot_pos3 = "00000187";
string ff = "ffffffff";

// Write selected variables in fpga
write_FPGA(port, pos1, mot_pos1);
write_FPGA(port, pos2, mot_pos2);
write_FPGA(port, pos3, mot_pos3);
write_FPGA(port, init, ff);


//////////////////////////////////////////////////////////////////////////////////////
//Treshold level inicialization.

int t_red[6] = {	450, 	550, 	150, 	240,	330,	450};
int t_green[6] = {	120, 	230, 	280, 	390, 	400, 	500};
int t_blue[6] = {	120, 	230, 	200, 	300, 	580, 	680};
	

//int t_red[6] = {	440, 	680, 	140, 	300,	320,	500};
//int t_green[6] = {	120, 	300, 	260, 	500, 	380, 	580};
//int t_blue[6] = {	110, 	320, 	190, 	390, 	560, 	680};
	

Setup_Tresholds(port, t_red, t_green, t_blue);

//////////////////////////////////////////////////////////////////////////////////////
// 	While loop: Asks for command to write or read on the FPGA
//	Admited commands: 
//		- Any read / write command for uTosNet.
//		- "read_LED" : prints the intensity levels received for each color.
//	To write on FPGA: 1.- introduce write command (e.g. "w14").
//			  2.- introduce desired data (e.g. "00001010").
// 	
		

  while(1){
	
	//Command reading:
	cout << "Select command:" << endl;
	cin >> command;
	
	if(command == "read_LED"){ 
		for(int i = 0; i<=10; i++){
			//Read data from port 
			command = "r20";
			cout << "\rR2W0 (red): ";
			data_ = read_FPGA(port, command);
			//Convert data to integer
			cout << HEX_2_int(data_) << "\t\t";

			//Read data from port 
			command = "r21";
			cout << "R2W1 (green): ";
			data_ = read_FPGA(port, command);
			//Convert data to integer
			cout << HEX_2_int(data_) << "\t\t";

			//Read data from port 
			command = "r22";
			cout << "R2W2 (blue): ";
			data_ = read_FPGA(port, command);
			//Convert data to integer
			cout << HEX_2_int(data_) << endl;//<< "\t\t";
		}

	}else if(command[0] == 'r' && isdigit(command[1]) && command.size() == 3){

		  cout << "Reading from port.\n";
		  data_ = read_FPGA(port, command);
		  cout << data_ << endl;

		} else if(command[0] == 'w' && isdigit(command[1]) && command.size() == 3){
		  cout << "introduce data: ";
		  cin >> data_;
		  cout << "Writing to port.\n";
		  write_FPGA(port, command, data_);

		}
	


    }


  port.close();



}
