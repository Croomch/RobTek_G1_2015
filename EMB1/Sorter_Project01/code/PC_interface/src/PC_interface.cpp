
#include <boost/asio.hpp>
#include <iostream>
#include <string>

using namespace boost;
using namespace std;



//Function to write data in FPGA
void write_FPGA(string portname, string command)
{
	asio::io_service io;
	asio::serial_port port( io );

	port.open(portname);
	port.set_option(asio::serial_port_base::baud_rate(115200));

	//Write the command to access to memory
	asio::write(port, asio::buffer(command.c_str(), command.size()));

	string command2;	
	cout << "Set input data:" << endl;
	cin >> command2;


	asio::write(port, asio::buffer(command2.c_str(), command2.size()));

	port.close();

}


//Function to read data in FPGA
string read_FPGA(string portname, string command)
{	
	asio::io_service io;
	asio::serial_port port( io );

	port.open(portname);
	port.set_option(asio::serial_port_base::baud_rate(115200));
	
	asio::mutable_buffer read_buf;

	//Write the command to access to memory
	asio::write(port, asio::buffer(command.c_str(), command.size()));

	//Read the memory set and save it in char*
	asio::read(port, asio::buffer(read_buf));
	unsigned char* new_data = boost::asio::buffer_cast<unsigned char*>(read_buf);

	string new_data_str((char*) new_data);
	
	port.close();

	return new_data_str;

}


int main()
{
	string command = "r01";
	string portname;
	string data_;

	asio::mutable_buffer read_buf; 

	//asio::const_buffer command_buf = asio::buffer(command);
	//asio::const_buffers_1 command_buf;
	
//	asio::io_service io;
//	asio::serial_port port( io );



///////////////////////////////////////////////////////////////////////////////////////
// 	Port Configuration

	cout << "Set portname: " << endl;
	cin >> portname;


//////////////////////////////////////////////////////////////////////////////////////
// 	While Program, each time ask for a new command
	while(1){

	cout << "\rSelect command:" << endl;
	cin >> command;
	

	if(command[0] = 'r')
		data_ = read_FPGA(portname, command);

	if(command[0] = 'w')
		write_FPGA(portname, command);

	}



///////////////////////////////////////////////////////////////////////////////////////
// 	Test read on buffer
/*

	asio::write(port, asio::buffer(command.c_str(), command.size()));

	asio::read(port, asio::buffer(read_buf));
	unsigned char* p2 = boost::asio::buffer_cast<unsigned char*>(read_buf);

	cout << p2;
*/



}
