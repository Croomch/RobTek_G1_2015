#include <boost/asio.hpp>
#include <iostream>
#include <string>

using namespace boost;
using namespace std;



//Function to write data in FPGA
void write_FPGA(asio::serial_port &port, string &command)
{

  cout << "Enter data:\n";
  string data, full_command;
  cin >> data;

  full_command = command + " " + data;

  //Write the command to access to memory
  asio::write(port, asio::buffer(full_command.c_str(), full_command.size()));

}


//Function to read data in FPGA
string read_FPGA(asio::serial_port &port, string &command)
{

  char data[9] = {};
  //Write the command to access to memory
  asio::write(port, asio::buffer(command.c_str(), command.size()));

  //Read the memory set and save it in char*
  asio::read(port, asio::buffer(data,9));

  //cout << "Data recieved was: " << data;// << "\n";

  return data;
}

int HEX_2_int(string data)
{
  int value = 0;

  for(int i=0; i<=7; i++)
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

int main()
{
  string command = "r01";
  string portname;
  string data_;
  string inputdata;



  ///////////////////////////////////////////////////////////////////////////////////////
  // 	Port Configuration

  cout << "Set portname: " << endl;
  cin >> portname;


  asio::io_service io;
  asio::serial_port port( io );

  port.open(portname);
  port.set_option(asio::serial_port_base::baud_rate(115200));
  port.set_option(asio::serial_port_base::flow_control(asio::serial_port_base::flow_control::none));
  port.set_option(asio::serial_port_base::parity(asio::serial_port_base::parity::none));
  port.set_option(asio::serial_port_base::stop_bits(asio::serial_port_base::stop_bits::one));
  port.set_option(asio::serial_port_base::character_size(8));


  //////////////////////////////////////////////////////////////////////////////////////
  // 	While loop, ask for port to read and print it constatntly

//  cout << "Select port to read" << endl;
//  cin >> command;	
  while(1){

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
	  cout << HEX_2_int(data_);




    }


  port.close();



}
