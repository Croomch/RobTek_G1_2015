
#include <boost/asio.hpp>
#include <iostream>
#include <string>

using namespace boost;
using namespace std;



//Function to write data in FPGA
void write_FPGA(asio::serial_port &port, string &command)
{

  cout << "Enter data:\n";
  string data_, full_command;
  cin >> data_;

  full_command = command + " " + data_;

  //Write the command to access to memory
  asio::write(port, asio::buffer(full_command.c_str(), full_command.size()));

}


//Function to read data in FPGA
void read_FPGA(asio::serial_port &port, string &command)
{

  char data[9] = {};
  //Write the command to access to memory
  asio::write(port, asio::buffer(command.c_str(), command.size()));

  //Read the memory set and save it in char*
  asio::read(port, asio::buffer(data,9));
  //unsigned char* new_data = boost::asio::buffer_cast<unsigned char*>(read_buf);

  //string new_data_str((char*) new_data);
  cout << "Data recieved was: " << data << "\n";

  //return data;
}


int main()
{
  string command = "r01";
  string portname;
  string data_;
  string inputdata;



  //	asio::mutable_buffer read_buf;

  //asio::const_buffer command_buf = asio::buffer(command);
  //asio::const_buffers_1 command_buf;

  //	asio::io_service io;
  //	asio::serial_port port( io );



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
  // 	While Program, each time ask for a new command
  while(1){

      cout << "\rSelect command:" << endl;
      cin >> command;
	

      if(command[0] == 'r'){

          cout << "Reading from port.\n";
          read_FPGA(port, command);

        } else if(command[0] == 'w'){

          cout << "Writing to port.\n";
          write_FPGA(port, command);

        }
    }


  port.close();

  ///////////////////////////////////////////////////////////////////////////////////////
  // 	Test read on buffer
  /*

        asio::write(port, asio::buffer(command.c_str(), command.size()));

        asio::read(port, asio::buffer(read_buf));
        unsigned char* p2 = boost::asio::buffer_cast<unsigned char*>(read_buf);

        cout << p2;
*/



}
